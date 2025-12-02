class Mutation < ApplicationRecord
  belongs_to :hero
  has_one :adjustment, dependent: :destroy

  serialize :modifiers, coder: JSON

  validates :name, presence: true

  after_initialize :set_defaults
  after_create :create_adjustment_if_needed
  after_update :update_adjustment_if_needed

  # Check if this is a known mutation from the chart
  def from_chart?
    mutation_key.present?
  end

  # Check if this mutation has stat modifiers
  def has_modifiers?
    modifiers.present? && modifiers.any? { |_, v| v.to_i != 0 }
  end

  # Get modifier for a specific attribute
  def modifier_for(attribute)
    (modifiers || {})[attribute.to_s].to_i
  end

  # Returns only non-zero modifiers
  def active_modifiers
    (modifiers || {}).transform_values(&:to_i).reject { |_, v| v == 0 }
  end

  private

  def set_defaults
    self.modifiers ||= {}
  end

  def create_adjustment_if_needed
    return unless has_modifiers?

    create_adjustment!(
      hero: hero,
      title: "Mutation: #{name}",
      active: true,
      modifiers: modifiers
    )
  end

  def update_adjustment_if_needed
    if has_modifiers?
      if adjustment
        adjustment.update!(
          title: "Mutation: #{name}",
          modifiers: modifiers
        )
      else
        create_adjustment_if_needed
      end
    elsif adjustment
      adjustment.destroy
    end
  end
end
