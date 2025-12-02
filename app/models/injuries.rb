require 'yaml'

module Injuries
  def self.all
    @injuries_data ||= YAML.load_file('config/injuries.yml')
  end

  def self.names
    all.keys.map(&:to_s).sort
  end

  def self.find(key)
    all[key.to_s] || all[key.to_sym]
  end

  def self.[](key)
    find(key)
  end

  # Returns array of [key, data] for use in select dropdowns
  def self.for_select
    all.map { |key, data| [data['name'], key] }.sort_by(&:first)
  end

  # Build an Injury record from the template data
  def self.build_for_hero(hero, injury_key)
    data = find(injury_key)
    return nil unless data

    Injury.new(
      hero: hero,
      injury_key: injury_key.to_s,
      name: data['name'],
      description: data['description'],
      roll: data['roll'],
      modifiers: data['modifiers'] || {},
      permanent: data['permanent'] || false
    )
  end
end
