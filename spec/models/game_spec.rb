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

require 'rails_helper'

describe Game do
  describe 'associations' do
    it { is_expected.to have_many(:game_pools) }
    it { is_expected.to have_many(:pools).through(:game_pools) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:home_team) }
    it { is_expected.to validate_presence_of(:away_team) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:week) }
    it { is_expected.to validate_presence_of(:year) }

    context 'status enum values' do
      subject { described_class }

      let(:statuses) do
        {
          'pending' => 0,
          'finished' => 1
        }
      end

      its(:statuses) { is_expected.to eq statuses }
    end

    context 'home_team, away_team and winner enum values' do
      subject { described_class }

      let(:teams) do
        {
          'Arizona Cardinals' => 0,
          'Atlanta Falcons' => 1,
          'Baltimore Ravens' => 2,
          'Buffalo Bills' => 3,
          'Carolina Panthers' => 4,
          'Chicago Bears' => 5,
          'Cincinnati Bengals' => 6,
          'Cleveland Browns' => 7,
          'Dallas Cowboys' => 8,
          'Denver Broncos' => 9,
          'Detroit Lions' => 10,
          'Green Bay Packers' => 11,
          'Houston Texans' => 12,
          'Indianapolis Colts' => 13,
          'Jacksonville Jaguars' => 14,
          'Kansas City Chiefs' => 15,
          'Los Angeles Chargers' => 16,
          'Los Angeles Rams' => 17,
          'Miami Dolphins' => 18,
          'Minnesota Vikings' => 19,
          'New England Patriots' => 20,
          'New Orleans Saints' => 21,
          'New York Giants' => 22,
          'New York Jets' => 23,
          'Oakland Raiders' => 24,
          'Philadelphia Eagles' => 25,
          'Pittsburgh Steelers' => 26,
          'Seattle Seahawks' => 27,
          'San Francisco 49ers' => 28,
          'Tampa Bay Buccaneers' => 29,
          'Tennessee Titans' => 30,
          'Washington Redskins' => 31
        }
      end

      its(:home_teams) { is_expected.to eq teams }
      its(:away_teams) { is_expected.to eq teams }
      its(:winners) { is_expected.to eq teams.merge('no_winner' => 32) }
      its(:losers) { is_expected.to eq teams }
    end

    context 'when home and away teams are the same' do
      it 'fails validations' do
        expect { create(:game, home_team: 0, away_team: 0, week: 0, year: 0) }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Away team can't be the same as Home team")
      end
    end
  end
end
