class EventRating < ApplicationRecord
  belongs_to :event
  belongs_to :person

  after_create do |resource|
    resource.event.recalculate_average_rating!
  end

  before_destroy do |resource|
    user_adapter = resource.person.user.user_adapter
    if user_adapter
      skipped = user_adapter.skipped - [resource.event.paper.id]
      accepted = user_adapter.accepted - [resource.event.paper.id]
      papers_evaluated = user_adapter.papers_evaluated - [resource.event.paper.id]

      user_adapter.update(skipped: skipped, accepted: accepted, papers_evaluated: papers_evaluated)
      resource.event.recalculate_average_rating!
    end

  end

end
