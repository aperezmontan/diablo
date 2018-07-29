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
#  pool_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  loser      :integer
#

class Game < ApplicationRecord
  # ASSOCIATIONS
  belongs_to :pool

  # VALIDATIONS
  validates_presence_of :home_team
  validates_presence_of :away_team
  validates_presence_of :status

  validates_numericality_of :home_team
  validates_numericality_of :away_team
  validates_numericality_of :status
  validates_numericality_of :winner, allow_blank: true
  validates_numericality_of :loser, allow_blank: true

  validate :home_and_away_teams

  enum home_team: TEAMS.keys, _prefix: true
  enum away_team: TEAMS.keys, _prefix: true
  enum status: %i[pending finished]
  enum winner: TEAMS.keys.push(:no_winner), _prefix: true
  enum loser: TEAMS.keys, _prefix: true

  private

  def home_and_away_teams
    errors.add(:away_team, "can't be the same as Home team") if home_team == away_team
  end
end
