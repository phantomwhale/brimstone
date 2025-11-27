module HeroesHelper
  def available_portraits
    Dir.glob(Rails.root.join("app/assets/images/portraits/*.jpg")).map do |path|
      File.basename(path, ".jpg")
    end.sort
  end

  def portrait_display_name(portrait)
    return "No Portrait" if portrait.blank?
    portrait.titleize.gsub("_", " ")
  end
  
  # Returns array of all available sidebag token names (without extension)
  def available_sidebag_tokens
    Dir.glob(Rails.root.join("app/assets/images/tokens/sidebag/*.png")).map do |path|
      File.basename(path, ".png")
    end.sort
  end
  
  # Converts a token filename to a display name
  # e.g., "brimstone_ash" -> "Brimstone Ash"
  def token_display_name(token)
    return "Unknown" if token.blank?
    token.titleize.gsub("_", " ")
  end
  
  # Groups tokens by category for the picker UI
  def grouped_sidebag_tokens
    tokens = available_sidebag_tokens
    
    # Status effect tokens
    status_tokens = %w[bleeding burning death_mark ensnared noise poison potent_poison shaken stone stunned traumatized void_venom webbed]
    
    # Large tokens (elixers and amulet)
    large_tokens = %w[amulet_of_light elixer_of_fortitude elixer_of_purity elixer_of_vitality]
    
    # Everything else is a regular sidebag token
    sidebag_tokens = tokens - status_tokens - large_tokens
    
    {
      "Side Bag Tokens" => sidebag_tokens,
      "Large Tokens (2 slots)" => large_tokens,
      "Status Effects" => status_tokens
    }
  end
end
