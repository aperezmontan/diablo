# frozen_string_literal: true

# == Schema Information
#
# Table name: game_pools
#
#  id         :integer          not null, primary key
#  game_id    :integer
#  pool_id    :integer
#  week       :integer
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (pool_id => pools.id)
#

class GamePool < ApplicationRecord
  belongs_to :game
  belongs_to :pool
end
