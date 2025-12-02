class Adjustment < ApplicationRecord
  belongs_to :hero, class_name: "Hero", foreign_key: "hero_id"
  belongs_to :item, optional: true
  belongs_to :injury, optional: true
  belongs_to :madness, optional: true
  belongs_to :mutation, optional: true
  
  # Modifiers are stored as a JSON hash of attribute => modifier value
  # e.g., { "strength" => 2, "agility" => -1 }
  serialize :modifiers, coder: JSON
  
  validates :title, presence: true
  
  scope :active, -> { where(active: true) }
  scope :standalone, -> { where(item_id: nil, injury_id: nil, madness_id: nil, mutation_id: nil) }
  scope :from_items, -> { where.not(item_id: nil) }
  scope :from_injuries, -> { where.not(injury_id: nil) }
  scope :from_madnesses, -> { where.not(madness_id: nil) }
  scope :from_mutations, -> { where.not(mutation_id: nil) }
  
  # An adjustment is effectively active if:
  # - It's marked as active AND
  # - Either it's standalone (no item) OR its item is equipped
  # - Injuries and madnesses are always active (they don't have an equipped state)
  def effectively_active?
    return false unless active?
    return true if item.nil?
    item.equipped?
  end
  
  # List of attributes that can be modified by adjustments
  # Note: range_to_hit, melee_to_hit, defense, and willpower are dice target values
  # and should only be modified via the hero edit form, not adjustments
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
    combat
    max_grit
    corrupt_resist
    sidebag_capacity
    total_hands
    move
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
  
  # Returns only non-zero modifiers (with integer values)
  def active_modifiers
    (modifiers || {}).transform_values(&:to_i).reject { |_, v| v == 0 }
  end
  
  private
  
  def set_default_modifiers
    self.modifiers ||= {}
    self.active = true if active.nil?
  end
end
