class Hero < ApplicationRecord
  self.table_name = "heros"
  
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
  
  # Check if sidebag has room for more tokens
  def sidebag_full?
    sidebag_tokens.length >= (sidebag_capacity || 5)
  end
  
  # Number of tokens currently in sidebag
  def sidebag_count
    sidebag_tokens.length
  end
  
  # Available slots in sidebag
  def sidebag_slots_remaining
    (sidebag_capacity || 5) - sidebag_count
  end
  
  private
  
  def set_default_sidebag
    self.sidebag_capacity ||= 5
    self.sidebag_contents ||= []
  end
end
