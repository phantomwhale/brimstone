class Adjustment < ApplicationRecord
  belongs_to :hero, class_name: "Hero", foreign_key: "hero_id"
  
  # Modifiers are stored as a JSON hash of attribute => modifier value
  # e.g., { "strength" => 2, "agility" => -1 }
  serialize :modifiers, coder: JSON
  
  validates :title, presence: true
  
  scope :active, -> { where(active: true) }
  
  # List of attributes that can be modified by adjustments
  ADJUSTABLE_ATTRIBUTES = %w[
    health
    sanity
    agility
    cunning
    spirit
    strength
    lore
    luck
    initiative
    range_to_hit
    melee_to_hit
    combat
    max_grit
    defense
    willpower
    corrupt_resist
    sidebag_capacity
  ].freeze
  
  after_initialize :set_default_modifiers
  
  # Get the modifier for a specific attribute
  def modifier_for(attribute)
    (modifiers || {})[attribute.to_s].to_i
  end
  
  # Set the modifier for a specific attribute
  def set_modifier(attribute, value)
    self.modifiers ||= {}
    if value.to_i == 0
      self.modifiers.delete(attribute.to_s)
    else
      self.modifiers[attribute.to_s] = value.to_i
    end
  end
  
  # Returns only non-zero modifiers
  def active_modifiers
    (modifiers || {}).reject { |_, v| v.to_i == 0 }
  end
  
  private
  
  def set_default_modifiers
    self.modifiers ||= {}
    self.active = true if active.nil?
  end
end
