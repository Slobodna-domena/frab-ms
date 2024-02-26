class Grade < ApplicationRecord
  belongs_to :user
  belongs_to :paper
end
