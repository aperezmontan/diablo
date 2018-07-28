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
#

require 'rails_helper'

describe Game do
  describe 'associations' do
    it { is_expected.to belong_to(:pool) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:home_team) }
    it { is_expected.to validate_presence_of(:away_team) }
    it { is_expected.to validate_presence_of(:status) }

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
          'ari' => 0,
          'atl' => 1,
          'bal' => 2,
          'buf' => 3,
          'car' => 4,
          'chi' => 5,
          'cin' => 6,
          'cle' => 7,
          'dal' => 8,
          'den' => 9,
          'det' => 10,
          'gb' => 11,
          'hou' => 12,
          'ind' => 13,
          'jax' => 14,
          'kc' => 15,
          'lac' => 16,
          'lar' => 17,
          'mia' => 18,
          'min' => 19,
          'ne' => 20,
          'no' => 21,
          'nyg' => 22,
          'nyj' => 23,
          'oak' => 24,
          'phi' => 25,
          'pit' => 26,
          'sea' => 27,
          'sf' => 28,
          'tb' => 29,
          'ten' => 30,
          'was' => 31
        }
      end

      its(:home_teams) { is_expected.to eq teams }
      its(:away_teams) { is_expected.to eq teams }
      its(:winners) { is_expected.to eq teams.merge('no_winner' => 32) }
    end

    context 'when home and away teams are the same' do
      it 'fails validations' do
        expect { create(:game, home_team: 0, away_team: 0) }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Away team can't be the same as Home team")
      end
    end
  end
end
