class CreateMadnesses < ActiveRecord::Migration[8.0]
  def change
    create_table :madnesses do |t|
      t.references :hero, null: false, foreign_key: { to_table: :heros }
      t.string :madness_key
      t.string :name, null: false
      t.text :description
      t.integer :roll
      t.text :modifiers
      t.boolean :permanent, default: false

      t.timestamps
    end
  end
end
