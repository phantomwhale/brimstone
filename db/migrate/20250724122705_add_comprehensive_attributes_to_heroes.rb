class AddComprehensiveAttributesToHeroes < ActiveRecord::Migration[7.2]
  def change
    add_column :heros, :defense, :integer
    add_column :heros, :willpower, :integer
    add_column :heros, :corrupt_resist, :integer
    add_column :heros, :side_bag_tokens, :integer
    
    # Rename existing columns to match YAML structure
    rename_column :heros, :range, :range_to_hit
    rename_column :heros, :melee, :melee_to_hit
  end
end
