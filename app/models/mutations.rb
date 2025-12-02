require 'yaml'

module Mutations
  def self.all
    @mutations_data ||= YAML.load_file('config/mutations.yml')
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

  # Build a Mutation record from the template data
  def self.build_for_hero(hero, mutation_key)
    data = find(mutation_key)
    return nil unless data

    Mutation.new(
      hero: hero,
      mutation_key: mutation_key.to_s,
      name: data['name'],
      description: data['description'],
      roll: data['roll'],
      modifiers: data['modifiers'] || {}
    )
  end
end
