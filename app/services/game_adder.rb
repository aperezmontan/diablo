class GameAdder
  include Service

  attr_reader :pool

  def initialize(pool:)
    @pool = pool
  end

  def execute
    add_games_to_pool
  end

  private

  def add_games_to_pool
    raise GameAdderError.new(input: pool) unless pool.class == Pool

    pool.games << Game.where(pool_week_and_year)
  end

  def pool_week_and_year
    pool.attributes.slice('week', 'year')
  end
end