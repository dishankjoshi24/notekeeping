class Note < ApplicationRecord
  resourcify
  belongs_to :user
  validates_associated :user

  private
  
  def onwer?
    current_user.has_role? :onwer, @note
  end
  
  def contributor?
    current_user.has_role? :contributor, @note
  end

  def reader?
    current_user.has_role? :reader, @note
  end
end
