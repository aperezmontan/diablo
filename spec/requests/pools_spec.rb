# frozen_string_literal: true

require 'rails_helper'

describe 'Pools', type: :request do
  let(:pool) { create(:pool) }

  describe 'GET /pools/new' do
    it "displays the new Pool's page" do
      get new_pool_path
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('text/html')
      expect(response.body).to include('New Pool')
    end
  end

  describe 'GET /pools/1/edit' do
    it "displays the new Pool's page" do
      get edit_pool_path(pool)
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('text/html')
      expect(response.body).to include('Editing Pool')
    end
  end

  describe 'GET /pools' do
    context 'when requesting an HTML response' do
      it 'succeeds' do
        get pools_path
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('text/html')
        expect(response.body).to include('Pools')
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it 'succeeds' do
        get pools_path, headers: headers
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'GET /pools/1' do
    context 'when requesting an HTML response' do
      it 'succeeds' do
        get pool_path(pool)
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('text/html')
        expect(response.body).to include('This is a Pool')
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it 'succeeds' do
        get pool_path(pool), headers: headers
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to include('This is a Pool')
      end
    end
  end

  describe 'POST /pools' do
    context 'when requesting an HTML response' do
      context 'with correct parameters' do
        it "creates the new Pool and redirects to that Pool's page" do
          expect { post pools_path, params: { pool: { week: 2, year: 2018, description: 'Bruh' } } }
            .to change { Pool.count }.by(1)

          pool_id = Pool.first.id
          expect(response).to redirect_to(pool_path(pool_id))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Pool was successfully created.')
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect { post pools_path, params: { pool: { foo: 'Bruh' } } }
            .to change { Pool.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New Pool')
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          create(:pool, description: 'Bruh')
          expect { post pools_path, params: { pool: { description: 'Bruh' } } }
            .to change { Pool.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New Pool')
        end
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        it 'succeeds' do
          expect { post pools_path, headers: headers, params: { pool: { week: 2, year: 2018, description: 'Bruh' } } }
            .to change { Pool.count }.by(1)

          expect(response).to have_http_status(201)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(Pool.first.to_json))
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect { post pools_path, headers: headers, params: { pool: { foo: 'Bruh' } } }
            .to change { Pool.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          create(:pool, description: 'Bruh')
          expect { post pools_path, headers: headers, params: { pool: { description: 'Bruh' } } }
            .to change { Pool.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'PUT /pools/1' do
    context 'when requesting an HTML response' do
      context 'with correct parameters' do
        it "updates the Pool and redirects to the Pool's page" do
          expect(pool.description).to eq('This is a Pool')
          put pool_path(pool), params: { pool: { description: 'Foo' } }
          pool.reload
          expect(pool.description).to eq('Foo')

          pool_id = Pool.first.id
          expect(response).to redirect_to(pool_path(pool_id))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Pool was successfully updated.')
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect { put pool_path(pool), params: { pool: { foo: 'Foo' } } }
            .to_not change { pool.attributes }
        end
      end

      context 'with bad parameters' do
        let(:pool) { create(:pool, week: 1) }

        it 'fails' do
          expect(pool.week).to eq(1)
          put pool_path(pool), params: { pool: { week: 'Foo' } }

          pool.reload
          expect(pool.week).to eq(1)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Week is not a number')
        end
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        it 'succeeds' do
          expect(pool.description).to eq('This is a Pool')
          put pool_path(pool), headers: headers, params: { pool: { description: 'Foo' } }

          pool.reload
          expect(pool.description).to eq('Foo')
          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(Pool.first.to_json))
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect { put pool_path(pool), headers: headers, params: { pool: { foo: 'Foo' } } }
            .to_not change { pool.attributes }
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          expect { put pool_path(pool), headers: headers, params: { pool: { week: 'Foo' } } }
            .to_not change { pool.attributes }

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to eq('week' => ['is not a number'])
        end
      end
    end
  end

  describe 'DELETE /pools/1' do
    context 'when requesting an HTML response' do
      context 'with correct parameters' do
        it 'deletes the Pool and redirects to the Pools page' do
          delete pool_path(pool)

          expect(response).to redirect_to(pools_path)
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Pool was successfully destroyed.')
        end
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        it 'succeeds' do
          delete pool_path(pool), headers: headers

          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
