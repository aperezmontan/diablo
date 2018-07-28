# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  pool_id    :integer
#  user_id    :integer
#  name       :string
#  teams      :integer          default([]), not null, is an Array
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

require 'rails_helper'

describe Entry do
  describe 'associations' do
    it { is_expected.to belong_to(:pool) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:status) }

    context 'status enum values' do
      subject { described_class }

      let(:statuses) do
        {
          'pending' => 0,
          'active' => 1,
          'winner' => 2,
          "loser" => 3
        }
      end

      its(:statuses) { is_expected.to eq statuses }
    end

    context 'when entry is active' do
      context 'when teams has less than 6 entries' do
        it 'fails validations' do
          expect { create(:entry, status: :active, teams: [0,1,2,3,4]) }
            .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Teams haven't picked enough")
        end
      end

      context 'when trying to change teams' do
        let(:entry) { create(:entry, status: :active, teams: [0,1,2,3,4,5]) }

        it 'fails validation' do
          # binding.pry
          expect{ entry.update!(teams: [0,1,2,3,4,6]) }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Teams can't be changed, active Entry")
        end
      end
    end

    context 'when teams has more than 6 entries' do
      it 'fails validations' do
        expect { create(:entry, teams: [0,1,2,3,4,5,6]) }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Teams picked too many")
      end
    end

    context 'when teams has duplicate entries' do
      it 'fails validations' do
        expect { create(:entry, teams: [0,0,1,2,3,4]) }
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Teams can only be picked once")
      end
    end
  end

  describe '#calculate' do
    context 'when a new entry is made' do
      let(:entry) { create(:entry, teams: [0,1,2,3,4,5]) }
      let(:data) do
        {
          0 => "pending",
          1 => "pending",
          2 => "pending",
          3 => "pending",
          4 => "pending",
          5 => "pending"
        }
      end

      let(:game_no_op) { create(:game, home_team: 9, away_team: 10, winner: 9, loser: 10)}
      let(:game_winner) { create(:game, home_team: 6, away_team: 1, winner: 1, loser: 6) }
      let(:game_loser) { create(:game, home_team: 5, away_team: 6, winner: 6, loser: 5)}

      it 'generates data correctly' do
        entry.calculate!
        entry.reload
        expect(entry.data).to eq(data)

        entry.calculate!(game_no_op)
        entry.reload
        expect(entry.data).to eq(data)

        entry.calculate!(game_winner)
        entry.reload
        expect(entry.data).to eq(data.merge!(1 => "winner"))

        entry.calculate!(game_loser)
        entry.reload
        expect(entry.data).to eq(data.merge!(5 => "loser"))
      end

      it 'calculates a winner' do
        entry.send("data=", {
          0 => "winner",
          1 => "pending",
          2 => "winner",
          3 => "winner",
          4 => "winner",
          5 => "winner"
        })

        entry.calculate!(game_winner)
        entry.reload
        expect(entry.status).to eq("winner")
      end

      it 'calculates a loser' do
        entry.calculate!(game_loser)
        entry.reload
        expect(entry.status).to eq("loser")
      end

      it 'takes no action' do
        entry.calculate!(game_no_op)
        entry.reload
        expect(entry.status).to eq("pending")
      end
    end
  end

  describe '#data' do
    context 'when trying to write to it' do
      let(:entry) { create(:entry) }

      it 'raises an error' do
        expect{ entry.data = 'foo' }.to raise_error(NoMethodError)
      end
    end
  end
end
