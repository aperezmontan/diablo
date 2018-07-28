class CreateEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :entries do |t|
      t.references :pool, foreign_key: true
      t.references :user, foreign_key: true
      t.string :name
      t.integer :teams, array: true, default: []
      t.integer :status
      t.jsonb :data

      t.timestamps
    end
  end
end
