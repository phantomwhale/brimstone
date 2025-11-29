class Hero < ApplicationRecord
  self.table_name = "heros"
  
  has_many :adjustments, dependent: :destroy
  
  # Sidebag tokens are stored as a JSON array of token names
  serialize :sidebag_contents, coder: JSON
  
  after_initialize :set_default_sidebag
  
  def initialize_dup(prototype)
    self.health = prototype.max_hit_points
    super
  end
  
  # Returns array of token names in the sidebag
  def sidebag_tokens
    sidebag_contents || []
  end
  
  # Sets the sidebag contents from an array of token names
  def sidebag_tokens=(tokens)
    self.sidebag_contents = tokens.is_a?(Array) ? tokens : []
  end
  
  # Check if sidebag has room for more tokens (using adjusted capacity)
  def sidebag_full?
    sidebag_tokens.length >= adjusted_sidebag_capacity
  end
  
  # Number of tokens currently in sidebag
  def sidebag_count
    sidebag_tokens.length
  end
  
  # Available slots in sidebag (using adjusted capacity)
  def sidebag_slots_remaining
    adjusted_sidebag_capacity - sidebag_count
  end
  
  # Calculate total adjustment for a given attribute from all active adjustments
  def total_adjustment_for(attribute)
    adjustments.active.sum { |adj| adj.modifier_for(attribute) }
  end
  
  # Get the adjusted value for any adjustable attribute
  def adjusted_value_for(attribute)
    base_value = send(attribute).to_i
    adjustment = total_adjustment_for(attribute)
    base_value + adjustment
  end
  
  # Convenience methods for adjusted values
  Adjustment::ADJUSTABLE_ATTRIBUTES.each do |attr|
    define_method("adjusted_#{attr}") do
      adjusted_value_for(attr)
    end
  end
  
  # Check if an attribute has any active adjustments
  def has_adjustment_for?(attribute)
    total_adjustment_for(attribute) != 0
  end
  
  # Get a hash of all adjustments by attribute
  def all_adjustments_summary
    summary = {}
    Adjustment::ADJUSTABLE_ATTRIBUTES.each do |attr|
      adj = total_adjustment_for(attr)
      summary[attr] = adj if adj != 0
    end
    summary
  end
  
  private
  
  def set_default_sidebag
    self.sidebag_capacity ||= 5
    self.sidebag_contents ||= []
  end
end
