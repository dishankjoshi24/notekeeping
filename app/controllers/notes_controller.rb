class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :check_auth, only: [:edit, :update]
  before_action :check_reader, only: [:show]

  def index
    @notes = Note.with_roles([:onwer, :reader, :contributor], current_user)
  end

  def show
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(note_params)
    @note.user = current_user
    respond_to do |format|
      if @note.save
        add_onwer
        manage_role
        format.html { redirect_to @note, notice: 'Note was successfully created.' }
        format.json { render :show, status: :created, location: @note }
      else
        format.html { render :new }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if onwer? || contributor?
        if @note.update(note_params)
          manage_role if onwer?
          format.html { redirect_to @note, notice: 'Note was successfully updated.' }
          format.json { render :show, status: :ok, location: @note }
        else
          format.html { render :edit }
          format.json { render json: @note.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to notes_url, notice: 'Access Denied.' }
        format.json { head :no_content }
      end  
    end
  end

  def destroy
    respond_to do |format|
      if onwer?
        @note.destroy
        format.html { redirect_to notes_url, notice: 'Note was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to notes_url, notice: 'Access Denied.' }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def add_reader
    reader_ids = role_params['readers'].delete_if(&:blank?)
    readers = User.where(email: reader_ids)
    readers.each do |reader|
      reader.add_role :reader, @note
    end    
  end

  def add_contributor
    contributor_ids = role_params['contributors'].delete_if(&:blank?)
    contributors = User.where(email: contributor_ids)
    contributors.each do |contributor|
      contributor.add_role :contributor, @note
    end
  end

  def manage_role
    add_reader
    add_contributor
  end

  def add_onwer
    current_user.add_role :onwer, @note
  end

  def check_auth
    unless contributor? || onwer?
      redirect_back fallback_location: "/", notice: "Not allowed"
    end
  end

  def check_reader
    unless reader? || onwer? || contributor?
      redirect_back fallback_location: "/", notice: "Not allowed"
    end
  end

  def onwer?
    current_user.has_role? :onwer, @note
  end
  
  def contributor?
    current_user.has_role? :contributor, @note
  end

  def reader?
    current_user.has_role? :reader, @note
  end

  def note_params
    params.require(:note).permit(:title, :body)
  end

  def role_params
    params.require(:note).permit(readers: [], contributors: [])
  end
end
