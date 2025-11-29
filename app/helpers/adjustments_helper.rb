module AdjustmentsHelper
  # Format a value with its adjustment indicator
  def display_adjusted_value(hero, attribute)
    base_value = hero.send(attribute).to_i
    adjusted_value = hero.adjusted_value_for(attribute)
    adjustment = hero.total_adjustment_for(attribute)
    
    if adjustment == 0
      adjusted_value.to_s
    else
      adjusted_value.to_s
    end
  end
  
  # Returns CSS class for adjustment indicator
  def adjustment_indicator_class(hero, attribute)
    adjustment = hero.total_adjustment_for(attribute)
    return "" if adjustment == 0
    adjustment > 0 ? "has-positive-adjustment" : "has-negative-adjustment"
  end
  
  # Returns the adjustment amount formatted with sign
  def adjustment_amount(hero, attribute)
    adjustment = hero.total_adjustment_for(attribute)
    return nil if adjustment == 0
    adjustment > 0 ? "+#{adjustment}" : adjustment.to_s
  end
end
