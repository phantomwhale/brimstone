class AddPortraitToHeroes < ActiveRecord::Migration[8.0]
  def change
    add_column :heros, :portrait, :string
  end
end
