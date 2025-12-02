class AddMutationToAdjustments < ActiveRecord::Migration[8.0]
  def change
    add_reference :adjustments, :mutation, null: true, foreign_key: { to_table: :mutations }
  end
end
