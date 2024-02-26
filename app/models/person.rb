class Person < ApplicationRecord
  belongs_to :user
  has_many :event_people
  has_many :event_ratings
  has_many :events, -> { distinct }, through: :event_people
end
