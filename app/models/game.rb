# frozen_string_literal: true

# == Schema Information
#
# Table name: games
#
#  id         :integer          not null, primary key
#  home_team  :integer
#  away_team  :integer
#  status     :integer
#  winner     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  loser      :integer
#  week       :integer
#  year       :integer
#

class Game < ApplicationRecord
  IMMUTABLE_ON_ACTIVE = %w[home_team away_team week year].freeze

  # ASSOCIATIONS
  has_many :game_pools
  has_many :pools, through: :game_pools

  # VALIDATIONS
  validates_presence_of :home_team
  validates_presence_of :away_team
  validates_presence_of :status
  validates_presence_of :week
  validates_presence_of :year

  validates_numericality_of :home_team
  validates_numericality_of :away_team
  validates_numericality_of :status
  validates_numericality_of :winner, allow_blank: true
  validates_numericality_of :loser, allow_blank: true

  validate :force_immutable
  validate :home_and_away_teams

  enum home_team: TEAMS.values, _prefix: true
  enum away_team: TEAMS.values, _prefix: true
  enum winner: TEAMS.values.push(:no_winner), _prefix: true
  enum loser: TEAMS.values, _prefix: true
  enum status: %i[pending active finished]

  attribute :status, :integer, default: -> { 0 }

  private

  def force_immutable
    IMMUTABLE_ON_ACTIVE.each do |attr|
      changed.include?(attr) &&
        errors.add(attr, "can't be changed, active Game") &&
        self[attr] = changed_attributes[attr]
    end if active?
  end

  def home_and_away_teams
    errors.add(:away_team, "can't be the same as Home team") if home_team == away_team
  end
end
