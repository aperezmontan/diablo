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
    it { is_expected.to have_many(:game_pools) }
    it { is_expected.to have_many(:games).through(:game_pools) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:week) }
    it { is_expected.to validate_numericality_of(:week) }

    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_numericality_of(:year) }

    it { is_expected.to validate_presence_of(:status) }
    xit { is_expected.to validate_numericality_of(:status) }

    context 'status enum values' do
      subject { described_class }

      let(:statuses) do
        {
          'pending' => 0,
          'active' => 1,
          'finished' => 2
        }
      end

      its(:statuses) { is_expected.to eq statuses }
    end
  end
end
