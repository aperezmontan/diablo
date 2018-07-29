# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :set_entries
  before_action :set_entry, only: %i[show edit update destroy]
  before_action :admin_or_resource_owner?, only: %i[edit update destroy]

  # GET pools/1/entries
  def index; end

  # GET pools/1/entries/1
  def show; end

  # GET pools/1/entries/new
  def new
    @entry = @pool.entries.build
  end

  # GET pools/1/entries/1/edit
  def edit; end

  # POST pools/1/entries
  def create
    @entry = @pool.entries.build(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to @pool, notice: 'Entry was successfully created.' }
        format.json { render @entry, status: :created }
      else
        format.html { render :new }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT pools/1/entries/1
  def update
    respond_to do |format|
      if @entry.update_attributes(entry_params)
        format.html { redirect_to @entry.pool, notice: 'Entry was successfully updated.' }
        format.json { render @entry, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE pools/1/entries/1
  def destroy
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to pool_entries_url(@pool), notice: 'Entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def admin?
    current_user&.admin?
  end

  def admin_or_resource_owner?
    unauthorized_response unless admin? || resource_owner
  end

  def entry_params
    params[:entry][:teams] ||= []
    params.require(:entry).permit(:pool_id, :user_id, :name, :status, teams: [])
  end

  def resource_owner
    @resource_owner ||= @entry.user == current_user
  end

  def set_entries
    @pool = Pool.find(params[:pool_id])
  end

  def set_entry
    @entry = @pool.entries.find(params[:id])
  end

  def unauthorized_response
    render json: {}, status: :unauthorized
  end
end
