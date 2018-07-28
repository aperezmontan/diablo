class CreatePools < ActiveRecord::Migration[5.2]
  def change
    create_table :pools do |t|
      t.integer :week
      t.integer :year
      t.text :description
      t.integer :status

      t.timestamps
    end
  end
end
