# frozen_string_literal: true

# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  pool_id    :integer
#  user_id    :integer
#  name       :string
#  teams      :integer          default([]), is an Array
#  status     :integer
#  data       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (pool_id => pools.id)
#  fk_rails_...  (user_id => users.id)
#

class Entry < ApplicationRecord
  IMMUTABLE_ON_ACTIVE = %w[teams].freeze

  # ASSOCIATIONS
  belongs_to :pool
  belongs_to :user

  delegate :games, to: :pool

  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :status

  validate :teams_ok
  validate :force_immutable

  enum status: %i[pending active winner loser]

  attribute :status, :integer, default: -> { 0 }

  attr_reader :data

  def calculate!(game = nil)
    return if game.nil? && data.present?

    calc_and_save(game: game) if valid?
  end

  private

  attr_writer :data

  def all_teams_playing_check
    teams_hash = games
                 .inject({}) do |hash, game|
      hash[game.home_team_before_type_cast] = game.home_team
      hash.merge!(game.away_team_before_type_cast => game.away_team)
    end

    teams_not_playing = calc_teams_not_playing(hash: teams_hash)
    errors.add(:teams, "#{teams_not_playing} have been picked but aren't playing") if teams_not_playing.present?
  end

  def calc_and_save(game:)
    calculate_default_data if data.nil?
    calculate_data(game: game) if game.present?
    save!
  end

  def calc_teams_not_playing(hash:)
    teams.select { |team| hash[team].nil? }.map { |team| Game.home_teams.key(team) }
  end

  def calculate_data(game:)
    winner(game: game) if data.dig(game.winner_before_type_cast)
    loser(game: game) if data.dig(game.loser_before_type_cast)
  end

  def calculate_default_data
    self.data = teams.inject({}) do |hash, team|
      hash.merge!(team => 'pending')
    end
  end

  def force_immutable
    IMMUTABLE_ON_ACTIVE.each do |attr|
      changed.include?(attr) &&
        errors.add(attr, "can't be changed, active Entry") &&
        self[attr] = changed_attributes[attr]
    end if active?
  end

  def loser(game:)
    data[game.loser_before_type_cast] = 'loser'
    self.status = :loser
  end

  def not_enough_teams_check
    return unless teams.size < 6
    errors.add(:teams, "haven't picked enough")
    raise ActiveRecord::RecordInvalid, self
  end

  def teams_ok
    too_many_teams_check
    teams_not_unique_check
    all_teams_playing_check
    teams_not_playing_each_other_check
    not_enough_teams_check if active?
  end

  def teams_not_unique_check
    errors.add(:teams, 'can only be picked once') if teams.size == 6 && teams.uniq.size < 6
  end

  def too_many_teams_check
    errors.add(:teams, 'picked too many') if teams.size > 6
  end

  def teams_not_playing_each_other_check
    # rubocop:disable all
    teams_playing_each_other = games
      .select{ |game| ([game.home_team_before_type_cast, game.away_team_before_type_cast] - teams).empty? }
      .map{ |game| [game.home_team, game.away_team] }
    errors.add(:teams, "#{teams_playing_each_other} are playing each other") if teams_playing_each_other.present?
    # rubocop:enable all
  end

  def winner(game:)
    data[game.winner_before_type_cast] = 'winner'
    self.status = :winner if winner?
  end

  def winner?
    return false if data.value?('pending') || data.value?('loser')
    true
  end
end
