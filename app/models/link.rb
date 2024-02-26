class Link < ApplicationRecord
  belongs_to :linkable, polymorphic: true, optional: true
end
