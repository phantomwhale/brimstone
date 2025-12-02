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

ActiveRecord::Schema[8.0].define(version: 2025_12_02_034823) do
  create_table "adjustments", force: :cascade do |t|
    t.integer "hero_id", null: false
    t.string "title", null: false
    t.boolean "active", default: true
    t.text "modifiers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "item_id"
    t.integer "injury_id"
    t.integer "madness_id"
    t.integer "mutation_id"
    t.index ["hero_id"], name: "index_adjustments_on_hero_id"
    t.index ["injury_id"], name: "index_adjustments_on_injury_id"
    t.index ["item_id"], name: "index_adjustments_on_item_id"
    t.index ["madness_id"], name: "index_adjustments_on_madness_id"
    t.index ["mutation_id"], name: "index_adjustments_on_mutation_id"
  end

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

  create_table "injuries", force: :cascade do |t|
    t.integer "hero_id", null: false
    t.string "injury_key"
    t.string "name", null: false
    t.text "description"
    t.integer "roll"
    t.text "modifiers"
    t.boolean "permanent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hero_id"], name: "index_injuries_on_hero_id"
  end

  create_table "items", force: :cascade do |t|
    t.integer "hero_id", null: false
    t.string "name", null: false
    t.text "description"
    t.boolean "equipped", default: false
    t.text "body_parts"
    t.integer "hands_required", default: 0
    t.integer "weight", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hero_id"], name: "index_items_on_hero_id"
  end

  create_table "madnesses", force: :cascade do |t|
    t.integer "hero_id", null: false
    t.string "madness_key"
    t.string "name", null: false
    t.text "description"
    t.integer "roll"
    t.text "modifiers"
    t.boolean "permanent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hero_id"], name: "index_madnesses_on_hero_id"
  end

  create_table "mutations", force: :cascade do |t|
    t.integer "hero_id", null: false
    t.string "mutation_key"
    t.string "name", null: false
    t.text "description"
    t.integer "roll"
    t.text "modifiers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hero_id"], name: "index_mutations_on_hero_id"
  end

  add_foreign_key "adjustments", "heros"
  add_foreign_key "adjustments", "injuries"
  add_foreign_key "adjustments", "items"
  add_foreign_key "adjustments", "madnesses"
  add_foreign_key "adjustments", "mutations"
  add_foreign_key "injuries", "heros"
  add_foreign_key "items", "heros"
  add_foreign_key "madnesses", "heros"
  add_foreign_key "mutations", "heros"
end
