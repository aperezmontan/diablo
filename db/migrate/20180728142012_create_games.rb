class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.integer :home_team
      t.integer :away_team
      t.integer :status
      t.integer :winner
      t.references :pool

      t.timestamps
    end
  end
end
