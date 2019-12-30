class Note < ApplicationRecord
  resourcify
  belongs_to :user
  validates_associated :user
end
