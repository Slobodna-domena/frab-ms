class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :confirmable, :lockable

  has_one :person
  has_one :user_adapter
  has_many :conference_users
  has_one :payment
  #has_many :grades

  def as_json(options={})
    super(:methods => [:papers_evaluated,:missing_evaluations, :skipped])
  end

  def full_name
    return self.person.public_name unless self.person.public_name.blank?
    return "#{self.person.first_name} #{self.person.last_name}" unless (self.person.first_name.blank? && self.person.last_name.blank?)
    return ""
  end

  def get_related_papers
    return if admin?
    conference_map = Hash.new
    self.conferences.each do |conf|
      if self.role == "crew"
        accepted_papers = self.user_adapter.accepted
        self.user_adapter.accepted.each do |ac|
          if !EventRating.find_by(person_id: self.id,peer: false, event_id: Paper.find(ac).event.id).nil?
            accepted_papers = accepted_papers - [ac]
          end
        end
        self.user_adapter.update_column(:accepted,accepted_papers)
      end
      user_papers = self.get_papers(conf.id)
      paper_types = self.get_paper_types(conf.id)
      papers = self.user_adapter.papers_evaluated.map{|e| Paper.find(e)}.select{|p| p.event.conference_id == conf.id}
      papers = (papers + self.user_adapter.accepted.map{|a| Paper.find(a)}).flatten.uniq.select{|p| p.event.conference_id == conf.id}
      if self.role == "crew"
        papers = papers.select{|paper| paper.event.event_ratings.where(person_id: self.id, peer: false).blank?}
      end
      if self.get_user_classifiers(conf.id).blank?
        related_papers = []
        unrelated_papers = Paper.all.select{|paper|
          paper.check_paper(conf,self) &&
          !papers.include?(paper) &&
          paper.event.event_ratings.where(person_id: self.id, peer: false).blank? &&
          !user_papers.include?(paper.event) &&
          paper.event.state != "rejected" &&
          paper.user_not_coauthor?(self)
        }
      else
        related_papers_by_classifier = self.get_user_classifiers(conf.id).
          map{|c| c.event_classifiers.map{|ec| ec.event.paper}}.
            flatten.
              uniq.
                compact
        related_papers = related_papers_by_classifier.select{|paper|
           paper.check_paper(conf,self) &&
           !user_papers.include?(paper.event) &&
           paper.event.event_ratings.where(person_id: self.id, peer: false).blank? &&
           !papers.include?(paper) &&
           paper.event.state != "rejected" &&
           paper.user_not_coauthor?(self)
         }
        unrelated_papers = Paper.all.select{|paper|
          paper.check_paper(conf,self) &&
          !related_papers_by_classifier.include?(paper) &&
          paper.event.event_ratings.where(person_id: self.id, peer: false).blank? &&
          !user_papers.include?(paper.event) &&
          !papers.include?(paper) &&
          paper.event.state != "rejected" &&
          paper.user_not_coauthor?(self)
        }
      end
      non_academic_related_papers = related_papers.select{|p| p.event_type.in?(Paper::PRACTICAL_CONST)}
      academic_related_papers = related_papers.select{|p| p.event_type.in?(Paper::ACADEMIC_CONST)}

      non_academic_unrelated_papers = unrelated_papers.select{|p| p.event_type.in?(Paper::PRACTICAL_CONST)}
      academic_unrelated_papers = unrelated_papers.select{|p| p.event_type.in?(Paper::ACADEMIC_CONST)}


      i = 0
      while papers.size < user_papers.size*3 && non_academic_related_papers[i]
        papers << non_academic_related_papers[i]
        i = i + 1
      end

      i = 0
      while papers.size < user_papers.size*3 && non_academic_unrelated_papers[i]
        papers << non_academic_unrelated_papers[i]
        i = i + 1
      end


      i = 0
      while papers.size < user_papers.size*3 && academic_related_papers[i]
        papers << academic_related_papers[i]
        i = i + 1
      end

      i = 0
      while papers.size < user_papers.size*3 && academic_unrelated_papers[i]
        papers << academic_unrelated_papers[i]
        i = i + 1
      end

      conference_map[conf.id] = papers.reject(&:blank?)
    end
    return conference_map
  end

  def get_user_classifiers(conf)
    papers = self.get_papers(conf)
    return papers.map{|paper| paper.event_classifiers}.flatten.uniq.map{|ec| ec.classifier}
  end

  def get_paper_types(conf)
    self.person.events.where(conference_id: conf).map{|p| p.event_type}.flatten.uniq
  end

  def get_all_papers
    self.person.events
  end

  def get_papers(conf)
    self.person.events.where(conference_id: conf).joins(:event_people).where("event_people.event_role ilike 'submitter'")#.where.not(coauthor_1: self.email).where.not(coauthor_2: self.email).where.not(coauthor_3: self.email).where.not(coauthor_4: self.email).where.not(coauthor_5: self.email)
  end

  def grades
    self.person.event_ratings
  end

  def papers_evaluated(conference)
    self.grades.select{|g| g.event.conference.id == conference}.size
  end

  def admin?
    self.role == "admin" || (self.role == "crew" && !Conference.all.map{|c| c.conference_users}.flatten.select{|cu| cu.role == "orga" && cu.user_id == self.id}.blank?)
  end

  def grades
    self.person.event_ratings.where(peer: true)
  end

  def conferences
    if admin?
      Conference.all
    else
      self.get_all_papers.map{|e| e.conference}.flatten.uniq#.select{|c| !c.conference_users.map{|cu| cu.user}.flatten.uniq.include?(self)}.flatten.uniq
    end
  end

  def skipped
    self.user_adapter.skipped.map{|s| Paper.find_by(id: s)}.select{|p| !p.nil?}
  end

  def missing_evaluations(conference)
    self.get_papers(conference).size*3 - papers_evaluated(conference)
  end

  def accepted?(paper)
    self.user_adapter && self.user_adapter.accepted.include?(paper.id)
  end

  def skipped?(paper)
    self.user_adapter && self.user_adapter.skipped.include?(paper)
  end

  def can_accept?(conf)
    self.user_adapter && self.user_adapter.accepted.map{|e| Paper.find(e)}.select{|p| p.event.conference_id == conf}.size < self.get_papers(conf).size*3
  end

  def graded?(paper)
    self.user_adapter && self.user_adapter.papers_evaluated.include?(paper.id)
  end

end
