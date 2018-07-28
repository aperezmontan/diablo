# frozen_string_literal: true

require 'rails_helper'

describe 'Users', type: :request do
  let(:user) { create(:user) }

  describe 'GET /users/new' do
    it "displays the new User's page" do
      get new_user_path
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('text/html')
      expect(response.body).to include('New User')
    end
  end

  describe 'GET /users/1/edit' do
    it "displays the new User's page" do
      get edit_user_path(user)
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('text/html')
      expect(response.body).to include('Editing User')
    end
  end

  describe 'GET /users' do
    context 'when requesting an HTML response' do
      it 'succeeds' do
        get users_path
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('text/html')
        expect(response.body).to include('Users')
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it 'succeeds' do
        get users_path, headers: headers
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'GET /users/1' do
    context 'when requesting an HTML response' do
      it 'succeeds' do
        get user_path(user)
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('text/html')
        expect(response.body).to include('Bruh')
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it 'succeeds' do
        get user_path(user), headers: headers
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to include('Bruh')
      end
    end
  end

  describe 'POST /users' do
    context 'when requesting an HTML response' do
      context 'with correct parameters' do
        it "creates the new User and redirects to that User's page" do
          expect { post users_path, params: { user: { name: 'Bruh' } } }
            .to change { User.count }.by(1)

          user_id = User.first.id
          expect(response).to redirect_to(user_path(user_id))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('User was successfully created.')
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect { post users_path, params: { user: { foo: 'Bruh' } } }
            .to change { User.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New User')
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          create(:user, name: 'Bruh')
          expect { post users_path, params: { user: { name: 'Bruh' } } }
            .to change { User.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New User')
        end
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        it 'succeeds' do
          expect { post users_path, headers: headers, params: { user: { name: 'Bruh' } } }
            .to change { User.count }.by(1)

          expect(response).to have_http_status(201)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(User.first.to_json))
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect { post users_path, headers: headers, params: { user: { foo: 'Bruh' } } }
            .to change { User.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          create(:user, name: 'Bruh')
          expect { post users_path, headers: headers, params: { user: { name: 'Bruh' } } }
            .to change { User.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'PUT /users/1' do
    context 'when requesting an HTML response' do
      context 'with correct parameters' do
        it "updates the User and redirects to the User's page" do
          expect(user.name).to eq('Bruh')
          put user_path(user), params: { user: { name: 'Foo' } }
          user.reload
          expect(user.name).to eq('Foo')

          user_id = User.first.id
          expect(response).to redirect_to(user_path(user_id))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('User was successfully updated.')
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect(user.name).to eq('Bruh')
          put user_path(user), params: { user: { foo: 'Foo' } }
          user.reload
          expect(user.name).to eq('Bruh')
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          create(:user, name: 'Foo')
          expect(user.name).to eq('Bruh')
          put user_path(user), params: { user: { name: 'Foo' } }

          user.reload
          expect(user.name).to eq('Bruh')

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Name has already been taken')
        end
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        it 'succeeds' do
          expect(user.name).to eq('Bruh')
          put user_path(user), headers: headers, params: { user: { name: 'Foo' } }

          user.reload
          expect(user.name).to eq('Foo')
          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(User.first.to_json))
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect(user.name).to eq('Bruh')
          put user_path(user), headers: headers, params: { user: { foo: 'Foo' } }
          user.reload
          expect(user.name).to eq('Bruh')
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          create(:user, name: 'Foo')
          expect(user.name).to eq('Bruh')
          put user_path(user), headers: headers, params: { user: { name: 'Foo' } }

          user.reload
          expect(user.name).to eq('Bruh')

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'DELETE /users/1' do
    context 'when requesting an HTML response' do
      context 'with correct parameters' do
        it 'deletes the User and redirects to the Users page' do
          delete user_path(user)

          expect(response).to redirect_to(users_path)
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('User was successfully destroyed.')
        end
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        it 'succeeds' do
          delete user_path(user), headers: headers

          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
