# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe User do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
