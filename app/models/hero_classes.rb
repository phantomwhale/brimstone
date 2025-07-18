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

  def self.all
    @hero_classes_data ||= YAML.load_file('config/hero_classes.yml')
  end

  def self.names
    all.keys.map(&:to_s).sort
  end

  def self.attributes_for(class_name)
    all[class_name.to_s] || all[class_name.to_sym]
  end
end
