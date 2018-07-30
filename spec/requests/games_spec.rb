# frozen_string_literal: true

require 'rails_helper'

shared_examples 'an admin user endpoint' do
  let(:non_admin_user) { create(:user) }
  let(:result) do
    return subject unless subject.class == Fixnum # rubocop:disable Lint/UnifiedInteger
    response
  end

  before(:each) { sign_out :user }

  context 'when the user is not an admin user' do
    it 'fails with Unauthorized' do
      sign_in non_admin_user
      expect(result).to have_http_status(401)
    end
  end

  context 'when the user is an admin user' do
    it 'succeeds' do
      sign_in user
      expect(result).to_not have_http_status(401)
    end
  end
end

describe 'Game', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, role: 'admin') }
  let(:game) { create(:game) }
  let(:random_game) { create(:game) }
  let(:headers) { nil }

  subject do
    request
    response
  end

  before(:each) { sign_in user }

  describe 'GET /games/new' do
    let(:request) { get new_game_path }

    it_behaves_like 'an admin user endpoint'

    it "displays the new Game's page" do
      expect(subject).to have_http_status(200)
      expect(subject.content_type).to eq('text/html')
      expect(subject.body).to include('New Game')
    end
  end

  describe 'GET /games/1/edit' do
    let(:request) { get edit_game_path(game) }

    it_behaves_like 'an admin user endpoint'

    it "displays the new Game's page" do
      expect(subject).to have_http_status(200)
      expect(subject.content_type).to eq('text/html')
      expect(subject.body).to include('Editing Game')
    end
  end

  describe 'GET /games' do
    let(:request) { get games_path, headers: headers }

    context 'when making an HTML request' do
      it_behaves_like 'an admin user endpoint'

      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('text/html')
        expect(subject.body).to include('Game')
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it_behaves_like 'an admin user endpoint'

      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('application/json')
      end
    end
  end

  describe 'GET /games/1' do
    let(:request) { get game_path(game), headers: headers }

    context 'when making an HTML request' do
      it_behaves_like 'an admin user endpoint'

      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('text/html')
        expect(subject.body).to include('Arizona Cardinals')
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it_behaves_like 'an admin user endpoint'

      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('application/json')
        expect(JSON.parse(subject.body)).to include(JSON.parse(game.to_json))
      end
    end
  end

  describe 'POST /games' do
    subject { post games_path, headers: headers, params: params }

    context 'when making an HTML request' do
      context 'with correct parameters' do
        let(:params) { { game: { home_team: 'New York Giants', away_team: 'New York Jets', week: 0, year: 0 } } }

        it_behaves_like 'an admin user endpoint'

        it "creates the new Game and redirects to that Game's page" do
          expect { subject }.to change { Game.count }.by(1)

          game_id = Game.first.id
          expect(response).to redirect_to(game_path(game_id))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Game was successfully created.')
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { game: { foo: 'New York Giants', away_team: 'New York Jets', week: 0, year: 0 } } }

        it 'fails' do
          expect { subject }.to change { Game.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New Game')
        end
      end

      context 'with bad parameters' do
        let(:params) { { game: { home_team: 'New York Giants', away_team: 'New York Giants', week: 0, year: 0 } } }

        it 'fails' do
          expect { subject }.to change { Game.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New Game')
        end
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        let(:params) { { game: { home_team: 'New York Giants', away_team: 'New York Jets', week: 0, year: 0 } } }

        it_behaves_like 'an admin user endpoint'

        it 'succeeds' do
          expect { subject }.to change { Game.count }.by(1)

          game = Game.first
          expect(response).to have_http_status(201)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(game.to_json))
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { game: { foo: 'New York Giants', away_team: 'New York Jets', week: 0, year: 0 } } }

        it 'fails' do
          expect { subject }.to change { Game.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end

      context 'with bad parameters' do
        let(:params) { { game: { home_team: 'New York Giants', away_team: 'New York Giants', week: 0, year: 0 } } }

        it 'fails' do
          expect { subject }.to change { Game.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'PUT /games/1' do
    subject { put game_path(random_game), headers: headers, params: params }

    context 'when making an HTML request' do
      context 'with correct parameters' do
        let(:params) { { game: { home_team: 'Dallas Cowboys' } } }

        it_behaves_like 'an admin user endpoint'

        it "updates the Game and redirects to the Game's page" do
          home_team = random_game.home_team
          subject

          random_game.reload
          expect(random_game.home_team).to eq('Dallas Cowboys')
          expect(random_game.home_team).to_not eq(home_team)

          expect(response).to redirect_to(game_path(random_game.id))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Game was successfully updated.')
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { game: { foo: 'Foo' } } }

        it 'fails' do
          home_team = random_game.home_team
          subject

          random_game.reload
          expect(random_game.home_team).to_not eq('Foo')
          expect(random_game.home_team).to eq(home_team)
        end
      end

      context 'with bad parameters' do
        let(:params) { { game: { home_team: 'Foo' } } }

        it 'fails' do
          home_team = random_game.home_team

          subject

          random_game.reload
          expect(random_game.home_team).to_not eq('Foo')
          expect(random_game.home_team).to eq(home_team)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Home team is not a number')
        end
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        let(:params) { { game: { home_team: 'Dallas Cowboys' } } }

        it_behaves_like 'an admin user endpoint'

        it 'succeeds' do
          home_team = random_game.home_team
          subject

          random_game.reload
          expect(random_game.home_team).to eq('Dallas Cowboys')
          expect(random_game.home_team).to_not eq(home_team)
          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(random_game.to_json))
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { game: { foo: 'Foo' } } }

        it 'fails' do
          home_team = random_game.home_team
          subject

          random_game.reload
          expect(random_game.home_team).to_not eq('Foo')
          expect(random_game.home_team).to eq(home_team)
        end
      end

      context 'with bad parameters' do
        let(:params) { { game: { home_team: 'Foo' } } }

        it 'fails' do
          home_team = random_game.home_team

          subject

          random_game.reload
          expect(random_game.home_team).to_not eq('Foo')
          expect(random_game.home_team).to eq(home_team)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'DELETE /games/1' do
    subject { delete game_path(random_game), headers: headers }

    context 'when making an HTML request' do
      it_behaves_like 'an admin user endpoint'

      context 'with correct parameters' do
        it 'deletes the Game and redirects to the Game page' do
          random_game
          expect { subject }.to change { Game.count }.by(-1)

          expect(response).to redirect_to(games_path)
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Game was successfully destroyed.')
        end
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it_behaves_like 'an admin user endpoint'

      context 'with correct parameters' do
        it 'succeeds' do
          random_game
          expect { subject }.to change { Game.count }.by(-1)
          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
