# Adds frab-ms's own demo content on top of the frab demo dataset (conferences,
# tracks, classifiers, review metrics, and speaker/crew accounts are seeded by
# frab's own `rails demo:seed` task in the parent app and shared via the same
# database - see /frab/lib/tasks/demo.rake).
#
# The parent demo data currently has zero events of the types this app's
# review logic understands (Paper::ACADEMIC_CONST / PRACTICAL_CONST), so no
# one has anything to review yet. This adds a batch of real reviewable papers
# to the active conference so the peer-review flow has genuine pending work.
# Idempotent: safe to run more than once.

conference = Conference.find_by(acronym: "demo2026")

if conference.nil?
  puts "No 'demo2026' conference found - run frab's demo:seed task first. Skipping frab-ms demo content."
else
  tracks = Track.where(conference_id: conference.id).index_by(&:name)
  classifiers = Classifier.where(conference_id: conference.id).index_by(&:name)

  speaker_emails = (1..10).map { |n| "speaker#{n}@example.org" }
  speakers = User.where(email: speaker_emails).index_by(&:email)

  # Every user should have a UserAdapter (normally lazily created on first
  # login by ApplicationController#user_adapter; pre-creating it keeps
  # aggregate admin views and console/testing usage consistent even for
  # accounts that haven't logged in yet).
  User.find_each do |user|
    next if user.user_adapter
    UserAdapter.create!(user: user, paid: false)
  end

  # Drop UserAdapter rows left pointing at users that no longer exist (e.g.
  # from a previous frab demo:seed reset, which reassigns user ids).
  UserAdapter.where.not(user_id: User.select(:id)).destroy_all

  papers_to_create = [
    {
      title: "Formal verification of consensus protocols at scale",
      subtitle: "Model-checking Raft variants used in production",
      abstract: "We apply TLA+ model checking to three production Raft implementations and report the classes of bugs found.",
      description: "A full write-up of the methodology, tooling, and the seven correctness bugs uncovered across three open-source consensus libraries, with fixes upstreamed.",
      event_type: "Paper Presentation", track: tracks["Backend"], state: "review",
      submitter_email: "speaker1@example.org", classifier_names: ["Streaming ok"],
    },
    {
      title: "Post-quantum migration: a systematic review of TLS deployments",
      subtitle: "What 500 scanned endpoints tell us about hybrid key exchange rollout",
      abstract: "A survey of hybrid post-quantum TLS adoption across the public internet, comparing certificate authorities, CDNs, and self-hosted stacks.",
      description: "We scanned 500 TLS endpoints monthly for a year and classify adoption patterns of hybrid key exchanges, with recommendations for migration order.",
      event_type: "Paper Presentation", track: tracks["Security"], state: "new",
      submitter_email: "speaker2@example.org", classifier_names: ["Needs translation"],
    },
    {
      title: "Measuring flakiness: a year of CI data from 200 repositories",
      subtitle: "A large-scale empirical study of flaky test root causes",
      abstract: "We mined a year of CI runs from 200 open-source repositories to classify flaky test root causes and their fix rates.",
      description: "Root causes are bucketed into concurrency, network, and test-order dependency categories; only 40% of flaky tests are ever fixed rather than quarantined.",
      event_type: "Paper Presentation", track: tracks["DevOps"], state: "review",
      submitter_email: "speaker3@example.org", classifier_names: [],
    },
    {
      title: "Special session: sustaining open source maintainers",
      subtitle: "A working session on funding models that actually reach maintainers",
      abstract: "An open discussion session comparing sponsorship, foundation grants, and paid support contracts as sustainability models for solo maintainers.",
      description: "Structured as a moderated panel followed by breakout tables; outcomes will be written up and shared with the Community track afterwards.",
      event_type: "Special Session", track: tracks["Community"], state: "new",
      submitter_email: "speaker4@example.org", classifier_names: [],
    },
    {
      title: "Special session: accessibility regressions in modern JS frameworks",
      subtitle: "Why upgrading your framework can silently break screen readers",
      abstract: "A hands-on session walking through three real regressions introduced by framework upgrades, and how to catch them in CI.",
      description: "Attendees will audit a sample app with axe-core and a screen reader, then compare results before and after a staged framework upgrade.",
      event_type: "Special Session", track: tracks["Frontend"], state: "review",
      submitter_email: "speaker5@example.org", classifier_names: ["Streaming ok"],
    },
    {
      title: "Industry track: zero-downtime database migrations at scale",
      subtitle: "Lessons from migrating a 40TB Postgres cluster live",
      abstract: "A practitioner report on migrating a sharded Postgres cluster to a new schema without downtime, including the tooling built to make it repeatable.",
      description: "Covers dual-writing, backfill throttling, and the verification pass used before cutover, plus the two incidents caused by getting throttling wrong.",
      event_type: "Non-academic Session", track: tracks["DevOps"], state: "new",
      submitter_email: "speaker6@example.org", classifier_names: [],
    },
    {
      title: "Cold start latency in serverless runtimes: a comparative study",
      subtitle: "Benchmarking cold starts across four managed platforms",
      abstract: "We benchmark cold-start latency across four managed serverless platforms under varying memory and language runtime configurations.",
      description: "Includes a reproducible benchmarking harness and raw data; language runtime matters more than memory allocation for cold-start latency in three of four platforms.",
      event_type: "Paper Presentation", track: tracks["Backend"], state: "review",
      submitter_email: "speaker7@example.org", classifier_names: ["Needs translation"],
    },
    {
      title: "Industry track: incident response lessons from a supply-chain breach",
      subtitle: "A postmortem of a compromised build dependency",
      abstract: "A postmortem of a compromised transitive build dependency, the detection gap, and the response process that followed.",
      description: "Walks through the six-hour detection gap, the containment steps taken, and the build-provenance tooling adopted afterwards to prevent recurrence.",
      event_type: "Non-academic Session", track: tracks["Security"], state: "new",
      submitter_email: "speaker8@example.org", classifier_names: ["Streaming ok"],
    },
  ]

  created_events = {}

  papers_to_create.each do |attrs|
    event = Event.find_by(conference: conference, title: attrs[:title])
    if event.nil?
      event = Event.create!(
        conference: conference,
        track: attrs[:track],
        title: attrs[:title],
        subtitle: attrs[:subtitle],
        abstract: attrs[:abstract],
        description: attrs[:description],
        event_type: attrs[:event_type],
        state: attrs[:state],
        language: "en",
        public: true,
      )
      Paper.create!(event: event)

      submitter = speakers.fetch(attrs[:submitter_email])
      EventPerson.create!(event: event, person: submitter.person, event_role: "submitter")

      attrs[:classifier_names].each do |name|
        classifier = classifiers[name]
        next unless classifier
        EventClassifier.create!(event: event, classifier: classifier, value: 1)
      end
    end

    created_events[attrs[:title]] = event
  end

  # A couple of papers already have one peer review in progress, so the
  # review queue shows a realistic mix of untouched and partially-reviewed
  # papers (both stay under the 3-review threshold, so they remain open).
  partial_reviews = {
    "Formal verification of consensus protocols at scale" => { reviewer: "speaker9@example.org", rating: 7.5,
      comment: "Solid methodology, would like to see more detail on the evaluation setup." },
    "Measuring flakiness: a year of CI data from 200 repositories" => { reviewer: "speaker10@example.org", rating: 8.5,
      comment: "Great dataset. The fix-rate breakdown by category is the most useful part." },
    "Post-quantum migration: a systematic review of TLS deployments" => { reviewer: "speaker1@example.org", rating: 8.5,
      comment: "Clear methodology and the migration-order recommendations are actionable. Would benefit from a short discussion of cost overhead." },
  }

  partial_reviews.each do |title, info|
    event = created_events[title]
    reviewer = User.find_by(email: info[:reviewer])
    next if event.nil? || reviewer.nil?
    next if EventRating.exists?(event: event, person_id: reviewer.person.id, peer: true)

    paper = event.paper
    EventRating.create!(event: event, person: reviewer.person, peer: true, rating: info[:rating], comment: info[:comment])
    adapter = reviewer.user_adapter || UserAdapter.create!(user: reviewer)
    adapter.update!(
      papers_evaluated: (adapter.papers_evaluated + [paper.id]).uniq,
      accepted: (adapter.accepted + [paper.id]).uniq,
    )
  end

  # Payment / solidarity-fee demo content: a realistic mix of not-started,
  # requested, and completed payments across submitters and crew.
  payment_seed = {
    "speaker1@example.org"  => { country: "HR", request_date: 5.days.ago,  solidarity_fee: false, paid: true },
    "speaker2@example.org"  => { country: "DE", request_date: 2.days.ago,  solidarity_fee: false, paid: false },
    "speaker3@example.org"  => { country: "KSO", request_date: 10.days.ago, solidarity_fee: true, paid: true },
    "speaker4@example.org"  => { country: "ES", request_date: nil,         solidarity_fee: false, paid: false },
    "speaker5@example.org"  => { country: "FR", request_date: 1.day.ago,   solidarity_fee: false, paid: false },
    "speaker6@example.org"  => { country: "IT", request_date: 20.days.ago, solidarity_fee: false, paid: true },
    "orga@example.org"      => { country: "HR", request_date: nil,         solidarity_fee: false, paid: true },
    "reviewer@example.org"  => { country: "HR", request_date: 3.days.ago,  solidarity_fee: false, paid: false },
  }

  payment_seed.each do |email, attrs|
    user = User.find_by(email: email)
    next if user.nil?

    payment = user.payment || Payment.create!(user: user)
    payment.update!(country: attrs[:country], request_date: attrs[:request_date], solidarity_fee: attrs[:solidarity_fee])

    adapter = user.user_adapter || UserAdapter.create!(user: user)
    adapter.update!(paid: attrs[:paid])
  end

  puts "frab-ms demo content ready: #{papers_to_create.size} reviewable papers in #{conference.title}."
end
