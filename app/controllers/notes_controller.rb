class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :check_auth, only: [:edit, :update]
  before_action :check_reader, only: [:show]
  # GET /notes
  # GET /notes.json
  def index
    @notes = Note.with_roles([:onwer, :reader, :contributor], current_user)
  end

  # GET /notes/1
  # GET /notes/1.json
  def show

  end

  # GET /notes/new
  def new
    @note = current_user.notes.new
    user.add_role :onwer, @note
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

    respond_to do |format|
      if @note.save
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
    unless contributor? || owner?
      redirect_back fallback_location: "/", alert: "Not allowed"
    end
  end

  def check_reader
    unless contributor? || owner? || reader?
      redirect_back fallback_location: "/", alert: "Not allowed"
    end        
  end

  def note_params
    params.require(:note).permit(:title, :body, :user_id)
  end
end
