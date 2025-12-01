class AddItemToAdjustments < ActiveRecord::Migration[8.0]
  def change
    # Item is optional - adjustments can exist without an item
    add_reference :adjustments, :item, null: true, foreign_key: true
  end
end
