class GameUpdater
  include Service

  attr_reader :game

  def initialize(game:, attrs:)
    @game = game
    @attrs = attrs
  end

  def execute
    update_game
  end

  private

  attr_reader :attrs, :message

  def game_week_and_year
    game.attributes.slice('week', 'year')
  end

  def invalid_attrs
    @invalid_attrs ||= attrs.reject{ |k, _v| game.attribute_names.include?(k.to_s) }.presence
  end

  def invalid_attrs_message
    @invalid_attrs_message ||= begin
      return nil unless invalid_attrs

      "Invalid attributes: #{invalid_attrs}"
    end
  end

  def non_updateable_attrs
    @non_updateable_attrs ||= begin
      return nil unless game.status == "active" || game.status == "finished"

      attrs.keys.reject{ |attr| ["winner", "loser"].include?(attr) }
    end
  end

  def non_updateable_attrs_message
    @non_updateable_attrs_message ||= begin
      return nil unless non_updateable_attrs

      "Invalid attributes: attempted to change #{non_updateable_attrs.join(',')} but game is active"
    end
  end

  def update_game
    raise GameUpdaterError.new(input: game) unless game.class == Game
    raise GameUpdaterError.new(input: game, message: invalid_attrs_message) if invalid_attrs_message
    raise GameUpdaterError.new(input: game, message: non_updateable_attrs_message) if non_updateable_attrs_message

    game.update!(attrs)

    PoolUpdater.execute(pools: game.pools, game: game) if update_pool?
    game
  end

  def update_pool_statuses
    ['status', 'winner', 'loser']
  end

  def update_pool?
    update_pool_statuses.detect { |status| game.attribute_previously_changed?(status) }
  end
end