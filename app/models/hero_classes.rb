require 'yaml'

module HeroClasses
  def self.[](key)
    @hero_classes ||= YAML.load_file('config/hero_classes.yml').each_with_object({}) do |(name, attributes), collection|
      collection[name] = Hero.new(attributes.merge(name:))
    end
    @hero_classes[key]
  end

  def self.[]=(key, value)
    @hero_classes[key.to_sym] = value
  end
end
