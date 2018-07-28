# frozen_string_literal: true

# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  pool_id    :integer
#  user_id    :integer
#  name       :string
#  teams      :integer          default([]), is an Array
#  status     :integer
#  data       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (pool_id => pools.id)
#  fk_rails_...  (user_id => users.id)
#

class Entry < ApplicationRecord
  IMMUTABLE_ON_ACTIVE = %w[teams].freeze

  # ASSOCIATIONS
  belongs_to :pool
  belongs_to :user

  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :status

  validate :teams_ok
  validate :force_immutable

  enum status: %i[pending active winner loser]

  attr_reader :data

  def calculate!(game = nil)
    return if game.nil? && data.present?

    calc_and_save(game: game) if valid?
  end

  private

  attr_writer :data

  def calc_and_save(game:)
    calculate_default_data if data.nil?
    calculate_data(game: game) if game.present?
    save!
  end

  def calculate_data(game:)
    winner(game: game) if data.dig(game.winner_before_type_cast)
    loser(game: game) if data.dig(game.loser_before_type_cast)
  end

  def calculate_default_data
    self.data = teams.inject({}) do |hash, team|
      hash.merge!(team => 'pending')
    end
  end

  def force_immutable
    IMMUTABLE_ON_ACTIVE.each do |attr|
      changed.include?(attr) &&
        errors.add(attr, "can't be changed, active Entry") &&
        self[attr] = changed_attributes[attr]
    end if active?
  end

  def loser(game:)
    data[game.loser_before_type_cast] = 'loser'
    self.status = :loser
  end

  def not_enough_teams_check
    return unless teams.size < 6
    errors.add(:teams, "haven't picked enough")
    raise ActiveRecord::RecordInvalid, self
  end

  def teams_ok
    too_many_teams_check
    teams_not_unique_check
    not_enough_teams_check if active?
  end

  def teams_not_unique_check
    errors.add(:teams, 'can only be picked once') if teams.size == 6 && teams.uniq.size < 6
  end

  def too_many_teams_check
    errors.add(:teams, 'picked too many') if teams.size > 6
  end

  def winner(game:)
    data[game.winner_before_type_cast] = 'winner'
    self.status = :winner if winner?
  end

  def winner?
    return false if data.value?('pending') || data.value?('loser')
    true
  end
end
