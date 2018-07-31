class PoolAdder
  include Service

  attr_reader :game

  def initialize(game:)
    @game = game
  end

  def execute
    add_pools_to_game
  end

  private

  def add_pools_to_game
    raise PoolAdderError.new(input: game) unless game.class == Game

    game.pools << Pool.where(game_week_and_year)
  end

  def game_week_and_year
    game.attributes.slice('week', 'year')
  end
end