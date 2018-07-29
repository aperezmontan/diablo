# frozen_string_literal: true

require 'rails_helper'

describe 'Pools', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, role: 'admin') }
  let(:resource_owner) { create(:user) }
  let(:pool) { create(:pool, :with_games) }
  let(:entry) { create(:entry, pool: pool, user: resource_owner) }
  let(:headers) { nil }

  subject do
    request
    response
  end

  before(:each) { sign_in user }

  describe 'GET /pools/1/entries/new' do
    let(:request) { get new_pool_entry_path(pool), headers: headers }

    it "displays the new Entry's page" do
      expect(subject).to have_http_status(200)
      expect(subject.content_type).to eq('text/html')
      expect(subject.body).to include('New Entry')
    end
  end

  describe 'GET /pools/1/entries/1/edit' do
    let(:request) { get edit_pool_entry_path(pool, entry) }

    it_behaves_like 'an admin user endpoint'
    it_behaves_like 'a resource owner endpoint'

    it "displays the edit Entry's page" do
      expect(subject).to have_http_status(200)
      expect(subject.content_type).to eq('text/html')
      expect(subject.body).to include('Editing Entry')
    end
  end

  describe 'GET /pools/1/entries' do
    let(:request) { get pool_entries_path(pool), headers: headers }

    context 'when making an HTML requeset' do
      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('text/html')
        expect(subject.body).to include('Entries')
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('application/json')
      end
    end
  end

  describe 'GET /pools/1/entries/1' do
    let(:request) { get pool_entry_path(pool, entry), headers: headers }

    context 'when making an HTML requeset' do
      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('text/html')
        expect(subject.body).to include('This is an Entry')
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('application/json')
        expect(subject.body).to include('This is an Entry')
      end
    end
  end

  describe 'POST /pools/1/entries' do
    subject {
      post pool_entries_path(pool),
      headers: headers,
      params: params
    }

    context 'when making an HTML requeset' do
      context 'with correct parameters' do
        let(:params) { { entry: { name: 'Bruh', user_id: user.id } } }

        it "creates the new Entry and redirects to that Pool's page" do
          expect { subject }.to change { Entry.count }.by(1)

          expect(response).to redirect_to(pool_path(pool))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Entry was successfully created.')
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { entry: { foo: 'Bruh', user_id: user.id } } }

        it 'fails' do
          expect { subject }.to change { Entry.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New Entry')
        end
      end

      context 'with bad parameters' do
        let(:params) { { entry: { name: 'Bruh' } } }

        it 'fails' do
          expect { subject }.to change { Entry.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New Entry')
        end
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        let(:params) { { entry: { name: 'Bruh', user_id: user.id } } }

        it 'succeeds' do
          expect { subject }.to change { Entry.count }.by(1)

          expect(response).to have_http_status(201)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(Entry.first.to_json))
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { entry: { foo: 'Bruh', user_id: user.id } } }

        it 'fails' do
          expect { subject }.to change { Entry.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end

      context 'with bad parameters' do
        let(:params) { { entry: { name: 'Bruh' } } }

        it 'fails' do
          expect { subject }.to change { Entry.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'PUT /pools/1/entries/1' do
    subject { put pool_entry_path(pool, entry), headers: headers, params: params }

    context 'when making an HTML requeset' do
      context 'with correct parameters' do
        let(:params) { { entry: { name: 'Foo' } } }

        it_behaves_like 'an admin user endpoint'
        it_behaves_like 'a resource owner endpoint'

        it "updates the Entry and redirects to the Pool's page" do
          expect(entry.name).to eq('This is an Entry')
          subject

          entry.reload
          expect(entry.name).to eq('Foo')

          expect(response).to redirect_to(pool_path(pool))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Entry was successfully updated.')
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { entry: { foo: 'Foo' } } }

        it 'fails' do
          expect { subject }.to_not change { entry.attributes }
        end
      end

      context 'with bad parameters' do
        let(:params) { { entry: { teams: [0, 31, 2, 3, 4, 5] } } }

        it 'fails' do
          expect(entry.status).to eq('pending')
          subject

          entry.reload
          expect(entry.status).to eq('pending')

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body)
            .to include(
              'Teams [[&quot;Arizona Cardinals&quot;, &quot;Washington Redskins&quot;]] are playing each other'
            )
        end
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        let(:params) { { entry: { name: 'Foo' } } }

        it_behaves_like 'an admin user endpoint'
        it_behaves_like 'a resource owner endpoint'

        it 'succeeds' do
          expect(entry.name).to eq('This is an Entry')
          subject

          entry.reload
          expect(entry.name).to eq('Foo')
          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(Entry.first.to_json))
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { entry: { foo: 'Foo' } } }

        it 'fails' do
          expect { subject }.to_not change { entry.attributes }
        end
      end

      context 'with bad parameters' do
        let(:params) { { entry: { teams: [0, 31, 2, 3, 4, 5] } } }

        it 'fails' do
          expect{ subject }.to_not change { entry.attributes }

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to eq(
            'teams' => [
              '[["Arizona Cardinals", "Washington Redskins"]] are playing each other'
            ]
          )
        end
      end
    end
  end

  describe 'DELETE /pools/1/entries/1' do
    let!(:entry_to_delete) { create(:entry, pool: pool, user: resource_owner) }

    subject { delete pool_entry_path(pool, entry_to_delete), headers: headers }

    context 'when making an HTML requeset' do
      it_behaves_like 'an admin user endpoint'
      it_behaves_like 'a resource owner endpoint'

      context 'with correct parameters' do
        it 'deletes the Pool and redirects to the Pools page' do
          expect { subject }.to change { Entry.count }.by(-1)

          expect(response).to redirect_to(pool_entries_path(pool))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Entry was successfully destroyed.')
        end
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it_behaves_like 'an admin user endpoint'
      it_behaves_like 'a resource owner endpoint'

      context 'with correct parameters' do
        it 'succeeds' do
          expect { subject }.to change { Entry.count }.by(-1)
          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
