# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

FRAB Microservice ("frab-ms") is a standalone Rails 5.1 app that provides paper/talk review, grading, and payment (solidarity fee) workflows for a conference run on [frab](https://github.com/Slobodna-domena/frab). It is **not** a frab fork or engine — it is a separate Rails app that connects to and extends an *existing* frab PostgreSQL database.

This has a major consequence for how the schema is organized:

- `db/schema.rb` contains dozens of tables (`conferences`, `events`, `people`, `tracks`, `rooms`, `event_ratings`, `classifiers`, etc.) that belong to frab. These are **not owned by this app** — do not write migrations that alter or drop them, and treat their structure as a read/extend contract with the upstream frab schema.
- `db/migrate/` only contains migrations this app actually authored: `papers`, `user_adapters`, `grades`, `payments`, and small column additions on top of the existing `users`/`user_adapter` tables. When adding a migration, follow this pattern — only touch tables this app owns, or add narrowly-scoped columns to existing frab tables (e.g. `role` on `users`).
- `config/database.yml` is intentionally empty in this repo and must be populated locally to point at a frab database before running anything that touches ActiveRecord.

Models for frab-owned tables (`Conference`, `Event`, `Person`, `Track`, `EventRating`, `EventClassifier`, `Classifier`, `CallForParticipation`) are thin — they expose only what this app needs, not the full frab domain model. Do not assume associations/columns exist just because frab itself has them; check `db/schema.rb` first.

## Commands

```bash
bin/setup                 # bundle install, prepare db, clear logs (standard Rails setup script)
bin/rails server           # Rails app on :3000 (also: `foreman start` via Procfile runs server + webpack-dev-server)
bin/webpack-dev-server      # asset/JS dev server (webpacker + react-rails)

bin/rails test                                  # full test suite (Minitest)
bin/rails test test/models/paper_test.rb        # single file
bin/rails test test/models/paper_test.rb:12     # single test at line

bin/rails db:migrate       # run this app's own migrations (see caveat above)
bin/rails db:test:prepare  # sync test db schema before running tests

yarn install               # JS deps (react, uppy, @material/*, jquery/selectize for legacy assets)
```

There is no linter/formatter configured (no Rubocop, ESLint, etc.) — don't add one unless asked.

## Architecture

**Two authentication/payment modes, toggled by `Payment::PAYMENT_ENABLED`** (`app/models/payment.rb`): this constant fans out into `ApplicationController#login_with_frab`, `ConferenceController#show_people`, and `PapersController#check_if_review_done`, changing both the SSO handshake and which reviewers see which people/papers. When touching auth or reviewer-visibility logic, check both branches, not just the current value of the flag.

**SSO from frab**: `login_with_frab` (routed as `/users/login`) is how users arrive authenticated from the main frab site — either via a signed `q`/`r`/`t` param scheme (legacy, `PAYMENT_ENABLED == false` path) or a simpler `q`-encodes-user-id scheme (current path). There is no local login form for regular users (only Devise's confirmation/password/unlock views survive from the generator).

**Review/grading domain** (`Paper` → `Event` → `EventRating`): a `Paper` is a thin wrapper around a frab `Event`; almost all of its displayed attributes (`title`, `abstract`, `description`, `language`, `classifiers`, `documents`, `links`) are delegated straight to `self.event`. Grading state (accepted/skipped/evaluated paper IDs) is **not** stored on `EventRating` — it lives in `UserAdapter`'s three integer-array columns (`accepted`, `skipped`, `papers_evaluated`), keyed by paper id, one `UserAdapter` per `User`. `EventRating#before_destroy` keeps those arrays in sync when a rating is removed. `User#get_related_papers` is the recommendation engine that decides which unreviewed papers to surface to a given reviewer per conference (weighted by shared `Classifier`s, capped at 3x their own submitted-paper count) — read it fully before changing reviewer-assignment behavior, it's stateful and easy to break subtly.

**Payment flow** (`PaymentController`, `app/models/payment.rb`): one `Payment` per `User`, created lazily on first visit to `/payment`. Country handling uses the `countries` gem plus a manually-registered `Kosovo` entry (`config/initializers/countries.rb`) because ISO3166 doesn't ship one. `Payment#document` is a `carrierwave`-mounted upload (`FileUploader`) for proof-of-payment/solidarity images.

**Views not backed by controllers**: `app/views/documents/`, `app/views/customer_groups/`, and `app/views/dashboard/` exist but have no matching controller or route — leftover/in-progress scaffolding. Don't assume they're reachable; check `config/routes.rb` before relying on a view existing as evidence a feature works.

**Frontend**: mixed old/new — Sprockets (`app/assets`, sass, the bundled `_materialize` CSS/JS) alongside Webpacker-managed packs (`app/javascript/packs`) using `react-rails`/`react_ujs` and `@uppy/*` for uploads. New interactive UI should go through the webpacker/React path; `app/assets` is effectively legacy.
