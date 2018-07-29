# frozen_string_literal: true

require 'rails_helper'

describe 'Users', type: :request do
  let(:user) { create(:user) }

  describe 'GET /users/new' do
    it "displays the new User's page" do
      get new_users_admin_path
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('text/html')
      expect(response.body).to include('New User')
    end
  end

  describe 'GET /users/1/edit' do
    it "displays the new User's page" do
      get edit_users_admin_path(user)
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('text/html')
      expect(response.body).to include('Editing User')
    end
  end

  describe 'GET /users' do
    context 'when requesting an HTML response' do
      it 'succeeds' do
        get users_admin_index_path
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('text/html')
        expect(response.body).to include('Users')
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it 'succeeds' do
        get users_admin_index_path, headers: headers
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'GET /users/1' do
    context 'when requesting an HTML response' do
      it 'succeeds' do
        get users_admin_path(user)
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('text/html')
        expect(response.body).to include('Bruh')
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it 'succeeds' do
        get users_admin_path(user), headers: headers
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
          expect { post users_admin_index_path, params: { user: { username: 'Bruh', email: 'yuurr@bruh.com' } } }
            .to change { User.count }.by(1)

          user_id = User.first.id
          expect(response).to redirect_to(users_admin_path(user_id))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('User was successfully created.')
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect { post users_admin_index_path, params: { user: { foo: 'Bruh' } } }
            .to change { User.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New User')
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          create(:user, username: 'Bruh')
          expect { post users_admin_index_path, params: { user: { username: 'Bruh' } } }
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
          expect do
            post users_admin_index_path,
                 headers: headers,
                 params: { user: { username: 'Bruh', email: 'yuurr@bruh.com' } }
          end
            .to change { User.count }.by(1)

          expect(response).to have_http_status(201)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(User.first.to_json))
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          expect { post users_admin_index_path, headers: headers, params: { user: { foo: 'Bruh' } } }
            .to change { User.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          create(:user, username: 'Bruh')
          expect { post users_admin_index_path, headers: headers, params: { user: { username: 'Bruh' } } }
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
          username = user.username

          put users_admin_path(user), params: { user: { username: 'Foo' } }
          user.reload
          expect(user.username).to eq('Foo')
          expect(user.username).to_not eq(username)

          expect(response).to redirect_to(users_admin_path(user.id))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('User was successfully updated.')
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          username = user.username

          put users_admin_path(user), params: { user: { foo: 'Foo' } }
          user.reload
          expect(user.username).to_not eq('Foo')
          expect(user.username).to eq(username)
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          username = user.username

          create(:user, username: 'Foo')
          put users_admin_path(user), params: { user: { username: 'Foo' } }

          user.reload
          expect(user.username).to_not eq('Foo')
          expect(user.username).to eq(username)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Username has already been taken')
        end
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        it 'succeeds' do
          username = user.username

          put users_admin_path(user), headers: headers, params: { user: { username: 'Foo' } }

          user.reload
          expect(user.username).to eq('Foo')
          expect(user.username).to_not eq(username)
          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(User.first.to_json))
        end
      end

      context 'with incorrect parameters' do
        it 'fails' do
          username = user.username

          put users_admin_path(user), headers: headers, params: { user: { foo: 'Foo' } }
          user.reload
          expect(user.username).to_not eq('Foo')
          expect(user.username).to eq(username)
        end
      end

      context 'with bad parameters' do
        it 'fails' do
          username = user.username

          create(:user, username: 'Foo')
          put users_admin_path(user), headers: headers, params: { user: { username: 'Foo' } }

          user.reload
          expect(user.username).to_not eq('Foo')
          expect(user.username).to eq(username)

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
          delete users_admin_path(user)

          expect(response).to redirect_to(users_admin_index_path)
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
          delete users_admin_path(user), headers: headers

          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
