class ConferenceUser < ApplicationRecord
  belongs_to :conference
  belongs_to :user
  has_one :person, through: :user
end
