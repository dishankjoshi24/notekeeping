# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user, note)
    if user
      if user.has_role? :onwer, note
        can :manage, note
      elsif user.has_role? :contributor, note
        can :update, note
        can :read, note
      elsif user.has_role? :guest, note
        can :read, note
      end
    else
      redirect_to new_user_session_path
    end
  end
end
