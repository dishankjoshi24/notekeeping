class Note < ApplicationRecord
  resourcify
  belongs_to :user

  validates_associated :user
  validates :title, :body, presence: true
end
