class CreateHeros < ActiveRecord::Migration[7.0]
  def change
    create_table :heros do |t|
      t.string :name
      t.integer :health
      t.integer :sanity
      t.integer :agility
      t.integer :cunning
      t.integer :spirit
      t.integer :strength
      t.integer :lore
      t.integer :luck
      t.integer :initiative
      t.integer :range
      t.integer :melee
      t.integer :combat
      t.integer :max_grit

      t.timestamps
    end
  end
end
