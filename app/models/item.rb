class Item < ApplicationRecord
  belongs_to :hero, class_name: "Hero", foreign_key: "hero_id"
  has_one :adjustment, dependent: :destroy
  
  # Body parts are stored as a JSON array
  serialize :body_parts, coder: JSON
  
  validates :name, presence: true
  validates :hands_required, numericality: { in: 0..3 }
  validates :weight, numericality: { greater_than_or_equal_to: 0 }
  
  # Available body parts for equipment
  BODY_PARTS = %w[head face shoulders chest legs].freeze
  
  after_initialize :set_defaults
  
  # Accept nested attributes for adjustment
  accepts_nested_attributes_for :adjustment, allow_destroy: true, reject_if: :all_modifiers_blank?
  
  scope :equipped, -> { where(equipped: true) }
  scope :unequipped, -> { where(equipped: false) }
  
  # Check if this item requires any body parts
  def requires_body_parts?
    body_parts_array.any?
  end
  
  # Check if this item requires hands
  def requires_hands?
    hands_required.to_i > 0
  end
  
  # Check if this item is equippable (requires body parts or hands)
  def equippable?
    requires_body_parts? || requires_hands?
  end
  
  # Get body parts as array
  def body_parts_array
    body_parts.is_a?(Array) ? body_parts : []
  end
  
  # Set body parts from array
  def body_parts_array=(parts)
    self.body_parts = parts.is_a?(Array) ? parts.select(&:present?) : []
  end
  
  # Check if this item can be equipped given the hero's current equipment
  def can_equip?
    return true unless equippable?
    return false if equipped?
    
    # Check body part conflicts
    if requires_body_parts?
      occupied_parts = hero.occupied_body_parts
      conflicting_parts = body_parts_array & occupied_parts
      return false if conflicting_parts.any?
    end
    
    # Check hand availability
    if requires_hands?
      return false if hero.free_hands < hands_required
    end
    
    true
  end
  
  # Get the reason why this item cannot be equipped
  def cannot_equip_reason
    return nil if can_equip?
    return "Already equipped" if equipped?
    
    if requires_body_parts?
      occupied_parts = hero.occupied_body_parts
      conflicting_parts = body_parts_array & occupied_parts
      if conflicting_parts.any?
        return "#{conflicting_parts.map(&:titleize).join(', ')} already in use"
      end
    end
    
    if requires_hands?
      if hero.free_hands < hands_required
        return "Not enough free hands (need #{hands_required}, have #{hero.free_hands})"
      end
    end
    
    nil
  end
  
  # Equip this item
  def equip!
    return false unless can_equip?
    update(equipped: true)
  end
  
  # Unequip this item
  def unequip!
    update(equipped: false)
  end
  
  # Build or return existing adjustment for form
  def adjustment_for_form
    adjustment || build_adjustment(hero: hero, title: name, active: true)
  end
  
  # Check if this item has any stat modifiers
  def has_modifiers?
    adjustment.present? && adjustment.active_modifiers.any?
  end
  
  private
  
  def set_defaults
    self.equipped ||= false
    self.body_parts ||= []
    self.hands_required ||= 0
    self.weight ||= 0
  end
  
  # Reject adjustment if all modifiers are zero/blank
  def all_modifiers_blank?(attributes)
    modifiers = attributes[:modifiers]
    return true if modifiers.blank?
    modifiers.values.all? { |v| v.to_i == 0 }
  end
end
