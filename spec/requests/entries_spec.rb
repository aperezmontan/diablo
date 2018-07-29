# frozen_string_literal: true

require 'rails_helper'

describe 'Pools', type: :request do
  let(:user) { create(:user) }
  let(:pool) { create(:pool, :with_games) }
  let(:entry) { create(:entry, pool: pool) }

  describe 'GET /pools/1/entries/new' do
    it "displays the new Entry's page" do
      get new_pool_entry_path(pool)
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('text/html')
      expect(response.body).to include('New Entry')
    end
  end

  describe 'GET /pools/1/entries/1/edit' do
    it "displays the edit Entry's page" do
      get edit_pool_entry_path(pool, entry)
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('text/html')
      expect(response.body).to include('Editing Entry')
    end
  end

  describe 'GET /pools/1/entries' do
    context 'when requesting an HTML response' do
      it 'succeeds' do
        get pool_entries_path(pool)
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('text/html')
        expect(response.body).to include('Entries')
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it 'succeeds' do
        get pool_entries_path(pool), headers: headers
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'GET /pools/1/entries/1' do
    context 'when requesting an HTML response' do
      it 'succeeds' do
        get pool_entry_path(pool, entry)
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('text/html')
        expect(response.body).to include('This is an Entry')
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it 'succeeds' do
        get pool_entry_path(pool, entry), headers: headers
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to include('This is an Entry')
      end
    end
  end

  describe 'POST /pools/1/entries' do
    context 'when requesting an HTML response' do
      context 'with correct parameters' do
        it "creates the new Entry and redirects to that Pool's page" do
          expect { post pool_entries_path(pool), params: { entry: { name: 'Bruh', user_id: user.id } } }
            .to change { Entry.count }.by(1)

          expect(response).to redirect_to(pool_path(pool))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Entry was successfully created.')
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect { post pool_entries_path(pool), params: { entry: { foo: 'Bruh', user_id: user.id } } }
            .to change { Entry.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New Entry')
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          expect { post pool_entries_path(pool), params: { entry: { name: 'Bruh' } } }
            .to change { Entry.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New Entry')
        end
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        it 'succeeds' do
          expect do
            post pool_entries_path(pool),
                 headers: headers,
                 params: { entry: { name: 'Bruh', user_id: user.id } }
          end.to change { Entry.count }.by(1)

          expect(response).to have_http_status(201)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(Entry.first.to_json))
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect do
            post pool_entries_path(pool),
                 headers: headers,
                 params: { entry: { foo: 'Bruh', user_id: user.id } }
          end.to change { Entry.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          expect { post pool_entries_path(pool), headers: headers, params: { entry: { name: 'Bruh' } } }
            .to change { Entry.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'PUT /pools/1/entries/1' do
    context 'when requesting an HTML response' do
      context 'with correct parameters' do
        it "updates the Entry and redirects to the Pool's page" do
          expect(entry.name).to eq('This is an Entry')
          put pool_entry_path(pool, entry), params: { entry: { name: 'Foo' } }
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
        it 'fails' do
          expect { put pool_entry_path(pool, entry), params: { entry: { foo: 'Foo' } } }
            .to_not change { entry.attributes }
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          expect(entry.status).to eq('pending')
          put pool_entry_path(pool, entry), params: { entry: { teams: [0,31,2,3,4,5] } }

          entry.reload
          expect(entry.status).to eq('pending')

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Teams [[&quot;ari&quot;, &quot;was&quot;]] are playing each other')
        end
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        it 'succeeds' do
          expect(entry.name).to eq('This is an Entry')
          put pool_entry_path(pool, entry), headers: headers, params: { entry: { name: 'Foo' } }

          entry.reload
          expect(entry.name).to eq('Foo')
          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(Entry.first.to_json))
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect { put pool_entry_path(pool, entry), headers: headers, params: { entry: { foo: 'Foo' } } }
            .to_not change { entry.attributes }
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          expect { put pool_entry_path(pool, entry), headers: headers, params: { entry: { teams: [0,31,2,3,4,5] } } }
            .to_not change { entry.attributes }

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to eq("teams" => ["[[\"ari\", \"was\"]] are playing each other"])
        end
      end
    end
  end

  describe 'DELETE /pools/1/entries/1' do
    context 'when requesting an HTML response' do
      context 'with correct parameters' do
        it 'deletes the Pool and redirects to the Pools page' do
          delete pool_entry_path(pool, entry)

          expect(response).to redirect_to(pool_entries_path(pool))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Entry was successfully destroyed.')
        end
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        it 'succeeds' do
          delete pool_entry_path(pool, entry), headers: headers

          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
