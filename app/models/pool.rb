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

class Pool < ApplicationRecord
  # ASSOCIATIONS
  has_many :entries
  has_many :game_pools
  has_many :games, through: :game_pools

  # VALIDATIONS
  validates_presence_of :week
  validates_presence_of :year
  validates_numericality_of :week
  validates_numericality_of :year
end
