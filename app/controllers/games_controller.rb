class GamesController < ApplicationController
  before_action :admin?
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  before_action :convert_teams, only: [:create, :update]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def admin?
    unauthorized_response unless current_user&.admin?
  end

  def convert_teams
    params[:game][:away_team] = Game.away_teams[params[:game][:away_team]] if params[:game][:away_team]
    params[:game][:home_team] = Game.home_teams[params[:game][:home_team]] if params[:game][:home_team]
    params[:game][:loser] = Game.losers[params[:game][:loser]] if params[:game][:loser]
    params[:game][:winner] = Game.winners[params[:game][:winner]] if params[:game][:winner]
  end

  def game_params
    params.require(:game).permit(:home_team, :away_team, :status, :winner, :loser, :week, :year)
  end

  def set_game
    @game = Game.find(params[:id])
  end

  def unauthorized_response
    render json: {}, status: :unauthorized
  end
end
