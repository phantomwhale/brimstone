# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_27_213846) do
  create_table "heros", force: :cascade do |t|
    t.string "name"
    t.integer "health"
    t.integer "sanity"
    t.integer "agility"
    t.integer "cunning"
    t.integer "spirit"
    t.integer "strength"
    t.integer "lore"
    t.integer "luck"
    t.integer "initiative"
    t.integer "range_to_hit"
    t.integer "melee_to_hit"
    t.integer "combat"
    t.integer "max_grit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hero_class"
    t.integer "defense"
    t.integer "willpower"
    t.integer "corrupt_resist"
    t.integer "side_bag_tokens"
    t.integer "experience", default: 0
    t.integer "gold", default: 0
    t.integer "dark_stone", default: 0
    t.string "portrait"
    t.integer "sidebag_capacity", default: 5
    t.text "sidebag_contents"
  end
end
