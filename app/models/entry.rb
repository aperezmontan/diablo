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
  IMMUTABLE_ON_ACTIVE = %w{teams}

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
    calculate_default_data if valid? && data.nil?
    calculate_data(game: game) if valid? && game.present?
    self.save!
  end

  private

  attr_writer :data

  def calculate_data(game:)
    if data.dig(game.winner_before_type_cast)
      data.merge!(game.winner_before_type_cast => "winner")
      self.status = :winner if winner?
    end

    if data.dig(game.loser_before_type_cast)
      data.merge!(game.loser_before_type_cast => "loser")
      self.status = :loser
    end
  end

  def calculate_default_data
    self.data = teams.inject({}) do |hash, team|
      hash.merge!(team => "pending")
    end
  end

  def force_immutable
    if self.active?
      IMMUTABLE_ON_ACTIVE.each do |attr|
        self.changed.include?(attr) &&
          errors.add(attr, "can't be changed, active Entry") &&
          self[attr] = self.changed_attributes[attr]
      end
    end
  end

  def teams_ok
    errors.add(:teams, "picked too many") if teams.size > 6
    errors.add(:teams, "can only be picked once") if teams.size == 6 && teams.uniq.size < 6

    if self.active? && teams.size < 6
      errors.add(:teams, "haven't picked enough")
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  def winner?
    return false if data.value?("pending") || data.value?("loser")
    true
  end
end
