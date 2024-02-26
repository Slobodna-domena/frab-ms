class EventClassifier < ApplicationRecord
  belongs_to :event
  belongs_to :classifier
end
