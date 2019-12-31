module NotesHelper
  def read?(note)
    (current_user.has_role? :onwer, note) ||
    (current_user.has_role? :reader, note) ||
    (current_user.has_role? :contributor, note)
  end

  def update?(note)
    (current_user.has_role? :onwer, note) ||
    (current_user.has_role? :contributor, note)
  end

  def delete?(note)
    #binding.pry
    current_user.has_role? :onwer, note
  end
end
