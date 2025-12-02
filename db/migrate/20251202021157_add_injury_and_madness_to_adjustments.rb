class AddInjuryAndMadnessToAdjustments < ActiveRecord::Migration[8.0]
  def change
    add_reference :adjustments, :injury, null: true, foreign_key: true
    add_reference :adjustments, :madness, null: true, foreign_key: true
  end
end
