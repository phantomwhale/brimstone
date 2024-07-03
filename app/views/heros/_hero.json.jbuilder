json.extract! hero, :id, :name, :health, :sanity, :agility, :cunning, :spirit, :strength, :lore, :luck, :initiative, :range, :melee, :combat, :max_grit, :created_at, :updated_at
json.url hero_url(hero, format: :json)
