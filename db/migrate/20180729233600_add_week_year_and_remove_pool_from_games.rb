class AddWeekYearAndRemovePoolFromGames < ActiveRecord::Migration[5.2]
  def change
    remove_column :games, :pool_id
    add_column :games, :week, :integer
    add_column :games, :year, :integer
  end
end
