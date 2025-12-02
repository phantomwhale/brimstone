require 'yaml'

module Madnesses
  def self.all
    @madnesses_data ||= YAML.load_file('config/madnesses.yml')
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

  # Build a Madness record from the template data
  def self.build_for_hero(hero, madness_key)
    data = find(madness_key)
    return nil unless data

    Madness.new(
      hero: hero,
      madness_key: madness_key.to_s,
      name: data['name'],
      description: data['description'],
      roll: data['roll'],
      modifiers: data['modifiers'] || {},
      permanent: data['permanent'] || false
    )
  end
end
