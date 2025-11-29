class CreateAdjustments < ActiveRecord::Migration[8.0]
  def change
    create_table :adjustments do |t|
      t.references :hero, null: false, foreign_key: { to_table: :heros }
      t.string :title, null: false
      t.boolean :active, default: true
      t.text :modifiers

      t.timestamps
    end
  end
end
