class AddSidebagToHeroes < ActiveRecord::Migration[8.0]
  def change
    add_column :heros, :sidebag_capacity, :integer, default: 5
    add_column :heros, :sidebag_contents, :text
  end
end
