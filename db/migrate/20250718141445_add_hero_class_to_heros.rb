class AddHeroClassToHeros < ActiveRecord::Migration[7.2]
  def change
    add_column :heros, :hero_class, :string
  end
end
