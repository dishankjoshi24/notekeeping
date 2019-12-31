class Note < ApplicationRecord
  attr_accessor :readers, :contributors

  resourcify
  belongs_to :user

  validates_associated :user
  validates :title, :body, presence: true
end
