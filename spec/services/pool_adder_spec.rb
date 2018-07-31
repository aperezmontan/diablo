require 'rails_helper'

describe PoolAdder do
  describe '#execute' do
    subject { described_class.execute(game: game) }

    context 'when the service executes correctly' do
      let(:game) { create(:game, year: 0, week: 0) }
      let!(:relevant_pools) { create_list(:pool, 5, week: 0, year: 0) }
      let!(:irrelevant_pools) do
        create_list(:pool, 2, week: 1, year: 0) +
        create_list(:pool, 2, week: 0, year: 1)
      end

      it 'adds all relevant pools' do
        expect(Pool.count).to eq(9)
        expect{ subject }.to change{ game.pools.count }.from(0).to(5)
        expect(game.pools).to eq(relevant_pools)
      end
    end

    context 'when the service executes incorrectly' do
      context 'when game is nil' do
        let(:game) { nil }

        it 'returns an PoolAdder error' do
          expect{ subject }.to raise_error(PoolAdderError, 'Expecting Game, received nil')
        end
      end

      context 'when game is not a Pool' do
        let(:game) { create(:pool) }

        it 'returns an PoolAdder error' do
          expect{ subject }.to raise_error(PoolAdderError, 'Expecting Game, received Pool')
        end
      end
    end
  end
end