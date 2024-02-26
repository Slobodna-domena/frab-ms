class Event < ApplicationRecord
  has_many :event_classifiers
  has_many :event_people
  has_one  :paper
  has_many :event_attachments
  has_many :links, as: :linkable
  has_many :event_ratings
  belongs_to :track

  PRACTICAL_CONST = ["Non-academic Session"]
  ACADEMIC_CONST = ["Paper Presentation", "Special Session"]

  belongs_to :conference

  def recalculate_average_rating!
    update(average_rating: average_of_nonzeros(event_ratings.pluck(:rating)), event_ratings_count: event_ratings.where.not(rating: [nil, 0]).count )
  end

  def allowed_to_be_graded?
    self.event_type.in?(ACADEMIC_CONST) || (!self.event_type.in?(ACADEMIC_CONST) && self.event_ratings.size < 3)
  end

  def average_of_nonzeros(list)
    if self.event_type.in?(ACADEMIC_CONST)
      peer = self.event_ratings.where(peer: true)
      pro = self.event_ratings.where(peer: false)
      peer = peer.map{|p| p.rating}
      pro = pro.map{|p| p.rating}
      peers = peer.reduce(:+).to_f / peer.size
      pros = pro.reduce(:+).to_f / pro.size
      if peer.size == 0
        return pros
      elsif pro.size == 0
        return peers
      else
        return ((peers+pros)/2.0).to_f
      end
    else
      return nil unless list
      list=list.select{ |x| x && x>0 }
      return nil if list.empty?
      list.reduce(:+).to_f / list.size
    end
  end
end
