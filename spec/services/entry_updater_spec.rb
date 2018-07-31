# describe EntryUpdater do
#   describe '#execute' do
#     subject { described_class.execute(game: game) }

#     context 'when the service executes correctly' do
#       let(:home_team) { "New York Giants" }
#       let(:away_team) { "Dallas Cowboys" }
#       let(:game) { create(:game, :with_pools, home_team: home_team, away_team: away_team) }

#       let(:random_teams) { TEAMS.keys.sample(5) }

#       let(:relevant_pools) { game.pools }
#       let(:relevant_teams) { [TEAMS.keys[home_team], TEAMS.keys[away_team]] }
#       let(:selection_with_relevant_team) { random_teams.push(relevant_teams.sample) }
#       let(:irrelevant_pool) { create(:pool) }

#       let!(:one_more_team_to_win_entry) do
#         create(:entry, :with_data, team: TEAMS.keys[home_team], )
#       end

#       let!(:relevant_entries) do
#         e = []
#         5.times do
#           create(:entry, teams: selection_with_relevant_team, pool: relevant_pools.sample)
#         end
#         e
#       end
#       let!(:irrelevant_entries) do
#         e = []
#         2.times do
#           e << create(:entry, teams: selection_with_relevant_team, pool: irrelevant_pool)
#           e << create(:entry, teams: irrelevant_teams, pool: relevant_pools.sample)
#         end
#         e
#       end

#       it 'updates all of the relevant entries' do
#         expect(Entry.count).to eq(9)
#         expect{ subject }.to change{ pool.games.count }.from(0).to(5)
#         expect(pool.games).to eq(relevant_games)
#       end

#       it 'updates entry to :winner' do

#       end

#       it 'updates entry to :loser' do

#       end
#     end

#     context 'when the service executes incorrectly' do
#       context 'when it has bad parameters' do
#         it 'returns an EntryUpdater error' do

#         end
#       end
#     end
#   end
# end