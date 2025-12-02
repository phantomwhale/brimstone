class CreateMutations < ActiveRecord::Migration[8.0]
  def change
    create_table :mutations do |t|
      t.references :hero, null: false, foreign_key: { to_table: :heros }
      t.string :mutation_key
      t.string :name, null: false
      t.text :description
      t.integer :roll
      t.text :modifiers

      t.timestamps
    end
  end
end
