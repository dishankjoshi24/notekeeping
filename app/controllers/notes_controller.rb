class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :check_auth, only: [:edit, :update]
  before_action :check_reader, only: [:show]
  # GET /notes
  # GET /notes.json
  def index
    ids = Note.with_roles([:onwer, :reader, :contributor])
              .where(user: current_user).map(&:id).uniq
    @notes = Note.where(id: ids)
  end

  # GET /notes/1
  # GET /notes/1.json
  def show

  end

  # GET /notes/new
  def new
    @note = Note.new
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes
  # POST /notes.json
  def share

  end

  def create
    @note = Note.new(note_params)
    @note.user = current_user
    respond_to do |format|
      if @note.save
        binding.pry
        current_user.add_role :onwer, @note
        format.html { redirect_to @note, notice: 'Note was successfully created.' }
        format.json { render :show, status: :created, location: @note }
      else
        format.html { render :new }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notes/1
  # PATCH/PUT /notes/1.json
  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note, notice: 'Note was successfully updated.' }
        format.json { render :show, status: :ok, location: @note }
      else
        format.html { render :edit }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_url, notice: 'Note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def check_auth
    unless contributor? || onwer?
      redirect_back fallback_location: "/", alert: "Not allowed"
    end
  end

  def check_reader
    unless reader? || onwer? || contributor?
      redirect_back fallback_location: "/", alert: "Not allowed"
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
end
