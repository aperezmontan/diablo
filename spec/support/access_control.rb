# frozen_string_literal: true

shared_examples 'a resource owner endpoint' do
  let(:non_resource_owner) { create(:user) }
  let(:result) do
    return subject unless subject.class == Fixnum # rubocop:disable Lint/UnifiedInteger
    response
  end

  before(:each) { sign_out :user }

  context 'when the user is not the resource owner' do
    it 'fails with Unauthorized' do
      sign_in non_resource_owner
      expect(result).to have_http_status(401)
    end
  end

  context 'when the user is the resource owner' do
    it 'succeeds' do
      sign_in resource_owner
      expect(result).to_not have_http_status(401)
    end
  end
end

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
