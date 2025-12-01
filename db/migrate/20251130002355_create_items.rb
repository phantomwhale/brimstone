class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.references :hero, null: false, foreign_key: { to_table: :heros }
      t.string :name, null: false
      t.text :description
      t.boolean :equipped, default: false
      t.text :body_parts
      t.integer :hands_required, default: 0
      t.integer :weight, default: 0

      t.timestamps
    end
  end
end
