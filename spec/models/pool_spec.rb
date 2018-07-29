# frozen_string_literal: true

# == Schema Information
#
# Table name: pools
#
#  id          :integer          not null, primary key
#  week        :integer
#  year        :integer
#  description :text
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

describe Pool do
  describe 'assocations' do
    it { is_expected.to have_many(:entries) }
    it { is_expected.to have_many(:games) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:week) }
    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_numericality_of(:week) }
    it { is_expected.to validate_numericality_of(:year) }
  end
end
