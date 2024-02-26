class Conference < ApplicationRecord
  has_many :events
  has_many :conference_users
  has_one :call_for_participation
  has_many :review_metrics

  def number_of_people
    self.events.map{|event| event.event_people.pluck(:person_id)}.flatten.uniq.size
  end

  def number_of_papers
    Paper.all.select{|p| p.event && p.event.conference_id == self.id}.uniq.size
  end

  def number_of_graded_papers
    Paper.all.select{|p| p.event && p.event.conference_id == self.id && p.event.event_ratings.size > 0}.uniq
  end

  def cfp_ended
    self.call_for_participation.end_date < DateTime.now
  end

  def number_of_finished_papers
    Paper.all.select{|p| p.finished?}.size
  end

end
