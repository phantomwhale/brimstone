class AddResourcesToHeroes < ActiveRecord::Migration[8.0]
  def change
    add_column :heros, :experience, :integer, default: 0
    add_column :heros, :gold, :integer, default: 0
    add_column :heros, :dark_stone, :integer, default: 0
  end
end
