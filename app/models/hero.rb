class Hero < ApplicationRecord
  self.table_name = "heros"
  
  def initialize_dup(prototype)
    self.health = prototype.max_hit_points
    super
  end
end
