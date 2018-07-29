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

describe 'Users', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, role: 'admin') }
  let(:random_user) { create(:user) }
  let(:headers) { nil }

  subject do
    request
    response
  end

  before(:each) { sign_in user }

  describe 'GET /users/new' do
    let(:request) { get new_users_admin_path }

    it_behaves_like 'an admin user endpoint'

    it "displays the new User's page" do
      expect(subject).to have_http_status(200)
      expect(subject.content_type).to eq('text/html')
      expect(subject.body).to include('New User')
    end
  end

  describe 'GET /users/1/edit' do
    let(:request) { get edit_users_admin_path(user) }

    it_behaves_like 'an admin user endpoint'

    it "displays the new User's page" do
      expect(subject).to have_http_status(200)
      expect(subject.content_type).to eq('text/html')
      expect(subject.body).to include('Editing User')
    end
  end

  describe 'GET /users' do
    let(:request) { get users_admin_index_path, headers: headers }

    context 'when making an HTML request' do
      it_behaves_like 'an admin user endpoint'

      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('text/html')
        expect(subject.body).to include('Users')
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

  describe 'GET /users/1' do
    let(:request) { get users_admin_path(user), headers: headers }

    context 'when making an HTML request' do
      it_behaves_like 'an admin user endpoint'

      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('text/html')
        expect(subject.body).to include('Bruh')
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it_behaves_like 'an admin user endpoint'

      it 'succeeds' do
        expect(subject).to have_http_status(200)
        expect(subject.content_type).to eq('application/json')
        expect(subject.body).to include('Bruh')
      end
    end
  end

  describe 'POST /users' do
    subject { post users_admin_index_path, headers: headers, params: params }

    context 'when making an HTML request' do
      context 'with correct parameters' do
        let(:params) { { user: { username: 'Bruh', email: 'yuurr@bruh.com' } } }

        it_behaves_like 'an admin user endpoint'

        it "creates the new User and redirects to that User's page" do
          expect { subject }.to change { User.count }.by(1)

          user_id = User.find_by_username('Bruh').id
          expect(response).to redirect_to(users_admin_path(user_id))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('User was successfully created.')
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { user: { foo: 'Bruh' } } }

        it 'fails' do
          expect { subject }.to change { User.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New User')
        end
      end

      context 'with bad parameters' do
        let(:params) { { user: { username: 'Bruh' } } }

        it 'fails' do
          create(:user, username: 'Bruh')
          expect { subject }.to change { User.count }.by(0)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('New User')
        end
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        let(:params) { { user: { username: 'Bruh', email: 'yuurr@bruh.com' } } }

        it_behaves_like 'an admin user endpoint'

        it 'succeeds' do
          expect { subject }.to change { User.count }.by(1)

          user = User.find_by_username('Bruh')
          expect(response).to have_http_status(201)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(user.to_json))
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { user: { foo: 'Bruh' } } }

        it 'fails' do
          expect { subject }.to change { User.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end

      context 'with bad parameters' do
        let(:params) { { user: { username: 'Bruh' } } }

        it 'fails' do
          create(:user, username: 'Bruh')
          expect { subject }.to change { User.count }.by(0)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'PUT /users/1' do
    subject { put users_admin_path(random_user), headers: headers, params: params }

    context 'when making an HTML request' do
      context 'with correct parameters' do
        let(:params) { { user: { username: 'Foo' } } }

        it_behaves_like 'an admin user endpoint'

        it "updates the User and redirects to the User's page" do
          username = random_user.username
          subject

          random_user.reload
          expect(random_user.username).to eq('Foo')
          expect(random_user.username).to_not eq(username)

          expect(response).to redirect_to(users_admin_path(random_user.id))
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('User was successfully updated.')
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { user: { foo: 'Foo' } } }

        it 'fails' do
          username = random_user.username
          subject

          random_user.reload
          expect(random_user.username).to_not eq('Foo')
          expect(random_user.username).to eq(username)
        end
      end

      context 'with bad parameters' do
        let(:params) { { user: { username: 'Foo' } } }

        it 'fails' do
          username = random_user.username
          create(:user, username: 'Foo')

          subject

          random_user.reload
          expect(random_user.username).to_not eq('Foo')
          expect(random_user.username).to eq(username)

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('Username has already been taken')
        end
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      context 'with correct parameters' do
        let(:params) { { user: { username: 'Foo' } } }

        it_behaves_like 'an admin user endpoint'

        it 'succeeds' do
          username = random_user.username
          subject

          random_user.reload
          expect(random_user.username).to eq('Foo')
          expect(random_user.username).to_not eq(username)
          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('application/json')
          expect(JSON.parse(response.body)).to include(JSON.parse(random_user.to_json))
        end
      end

      context 'with incorrect parameters' do
        let(:params) { { user: { foo: 'Foo' } } }

        it 'fails' do
          username = random_user.username
          subject

          random_user.reload
          expect(random_user.username).to_not eq('Foo')
          expect(random_user.username).to eq(username)
        end
      end

      context 'with bad parameters' do
        let(:params) { { user: { username: 'Foo' } } }

        it 'fails' do
          username = random_user.username
          create(:user, username: 'Foo')

          subject

          random_user.reload
          expect(random_user.username).to_not eq('Foo')
          expect(random_user.username).to eq(username)

          expect(response).to have_http_status(422)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'DELETE /users/1' do
    subject { delete users_admin_path(random_user), headers: headers }

    context 'when making an HTML request' do
      it_behaves_like 'an admin user endpoint'

      context 'with correct parameters' do
        it 'deletes the User and redirects to the Users page' do
          random_user
          expect { subject }.to change { User.count }.by(-1)

          expect(response).to redirect_to(users_admin_index_path)
          expect(response.content_type).to eq('text/html')
          follow_redirect!

          expect(response).to have_http_status(200)
          expect(response.content_type).to eq('text/html')
          expect(response.body).to include('User was successfully destroyed.')
        end
      end
    end

    context 'when making a JSON request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } } # This is what Rails accepts

      it_behaves_like 'an admin user endpoint'

      context 'with correct parameters' do
        it 'succeeds' do
          random_user
          expect { subject }.to change { User.count }.by(-1)
          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
