class PoolUpdater
  include Service

  attr_reader :pools

  def initialize(pools:, game: nil)
    @pools = pools
    @game = game
  end

  def execute
    binding.pry
    return nil
    update_pools
  end

  private

  attr_reader :game, :message

  def pools_week_and_year
    pools.attributes.slice('week', 'year')
  end

  def invalid_game
    @invalid_game ||= game.reject{ |k, _v| pools.attribute_names.include?(k.to_s) }
  end

  def invalid_game_message
    @invalid_game_message ||= begin
      return nil unless invalid_game

      "Invalid attributes: #{invalid_game}"
    end
  end

  def non_updateable_game
    @non_updateable_game ||= begin
      return nil unless pools.status == "active" || pools.status == "finished"

      game.keys.reject{ |attr| ["winner", "loser"].include?(attr) }
    end
  end

  def non_updateable_game_message
    @invalid_game_message ||= begin
      return nil unless non_updateable_game

      "Invalid attributes: attempted to change #{non_updateable_game.join(',')} but pools is active"
    end
  end

  def update_pools
    raise GameUpdaterError.new(input: pools) unless pools.class == Game
    raise GameUpdaterError.new(input: pools, message: invalid_game_message) unless invalid_game_message
    raise GameUpdaterError.new(input: pools, message: non_updateable_game_message) unless non_updateable_game_message

    pools.update!(game)
  end
end