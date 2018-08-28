require 'rails_helper'

describe GameUpdater do
  describe '#execute' do
    subject { described_class.execute(game: game, attrs: attrs) }

    let!(:game) { create(:game, :with_pools) }
    let(:home_team_name) { "New York Jets" }
    let(:attrs) { { home_team: Game.home_teams[home_team_name] } }
    let!(:irrelevant_pools) { create_list(:pool, 2) }

    context 'when the service executes correctly' do
      it 'updates the relevant game' do
        old_home_team = game.home_team
        expect{ subject }.to change{ game.home_team }.from(old_home_team).to("New York Jets")
      end

      context 'when updating game with a result' do
        let(:attrs) { { winner: game.home_team_before_type_cast } }

        it 'calls PoolUpdater with relevant pools' do
          expect(Pool.count).to eq(4)
          expect(PoolUpdater).to receive(:execute).with(pools: game.pools, game: game).and_call_original

          subject
        end
      end

      context 'when updating game with anything besides a result' do
        it 'does not call PoolUpdater' do
          expect(Pool.count).to eq(4)
          expect(PoolUpdater).to_not receive(:execute)

          subject
        end
      end
    end

    context 'when the service executes incorrectly' do
      context 'when game is active so changes can only be made to winner/loser' do
        let(:game) { create(:game, home_team: Game.home_teams[home_team_name], status: 1) }
        let(:home_team_name) { "New York Giants" }

        it 'returns an GameUpdater error' do
          expect{ subject }.to raise_error(GameUpdaterError, 'Invalid attributes: attempted to change home_team but game is active')
        end
      end

      context 'when it has bad parameters' do
        context 'when parameters are not available on game' do
          let(:attrs) { {home_team: 'New York Giants', bar: 'yuuurrr'} }

          it 'returns an GameUpdater error' do
            expect{ subject }.to raise_error(GameUpdaterError, 'Invalid attributes: {:bar=>"yuuurrr"}')
          end
        end

        context 'when game is nil' do
          let(:game) { nil }

          it 'returns an GameUpdater error' do
            expect{ subject }.to raise_error(GameUpdaterError, 'Expecting Game, received nil')
          end
        end

        context 'when game is not a Game' do
          let(:game) { create(:pool) }

          it 'returns an GameUpdater error' do
            expect{ subject }.to raise_error(GameUpdaterError, 'Expecting Game, received Pool')
          end
        end
      end
    end
  end
end