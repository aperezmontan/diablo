class EntriesController < ApplicationController
  before_action :set_entries
  before_action :set_entry, only: [:show, :edit, :update, :destroy]

  # GET pools/1/entries
  def index
    @entries = @pool.entries
  end

  # GET pools/1/entries/1
  def show
  end

  # GET pools/1/entries/new
  def new
    @entry = @pool.entries.build
  end

  # GET pools/1/entries/1/edit
  def edit
  end

  # POST pools/1/entries
  def create
    @entry = @pool.entries.build(entry_params)

    if @entry.save
      redirect_to([@entry.pool, @entry], notice: 'Entry was successfully created.')
    else
      render action: 'new'
    end
  end

  # PUT pools/1/entries/1
  def update
    if @entry.update_attributes(entry_params)
      redirect_to([@entry.pool, @entry], notice: 'Entry was successfully updated.')
    else
      render action: 'edit'
    end
  end

  # DELETE pools/1/entries/1
  def destroy
    @entry.destroy

    redirect_to pool_entries_url(@pool)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entries
      @pool = Pool.find(params[:pool_id])
    end

    def set_entry
      @entry = @pool.entries.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def entry_params
      params.require(:entry).permit(:pool_id, :user_id, :name, :teams, :status)
    end
end
