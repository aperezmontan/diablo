class CreateGamePools < ActiveRecord::Migration[5.2]
  def change
    create_table :game_pools do |t|
      t.references :game, foreign_key: true
      t.references :pool, foreign_key: true
      t.integer :week
      t.integer :year

      t.timestamps
    end
  end
end
