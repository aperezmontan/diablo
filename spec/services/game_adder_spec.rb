require 'rails_helper'

describe GameAdder do
  describe '#execute' do
    subject { described_class.execute(pool: pool) }

    context 'when the service executes correctly' do
      let(:pool) { create(:pool, year: 0, week: 0) }
      let!(:relevant_games) { create_list(:game, 5, week: 0, year: 0) }
      let!(:irrelevant_games) do
        create_list(:game, 2, week: 1, year: 0) +
        create_list(:game, 2, week: 0, year: 1)
      end

      it 'adds all relevant games' do
        expect(Game.count).to eq(9)
        expect{ subject }.to change{ pool.games.count }.from(0).to(5)
        expect(pool.games).to eq(relevant_games)
      end
    end

    context 'when the service executes incorrectly' do
      context 'when pool is nil' do
        let(:pool) { nil }

        it 'returns an GameAdder error' do
          expect{ subject }.to raise_error(GameAdderError, 'Expecting Pool, received nil')
        end
      end

      context 'when pool is not a Pool' do
        let(:pool) { create(:game) }

        it 'returns an GameAdder error' do
          expect{ subject }.to raise_error(GameAdderError, 'Expecting Pool, received Game')
        end
      end
    end
  end
end