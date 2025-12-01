class SidebagTokensController < ApplicationController
  before_action :set_hero

  def create
    token = params[:token]
    
    unless @hero.sidebag_full?
      tokens = @hero.sidebag_tokens
      tokens << token
      @hero.update(sidebag_contents: tokens)
    end
    
    respond_to do |format|
      format.html { redirect_to @hero }
      format.turbo_stream
    end
  end

  def destroy
    index = params[:id].to_i
    tokens = @hero.sidebag_tokens
    
    if index >= 0 && index < tokens.length
      tokens.delete_at(index)
      @hero.update(sidebag_contents: tokens)
    end
    
    respond_to do |format|
      format.html { redirect_to @hero }
      format.turbo_stream
    end
  end

  private

  def set_hero
    @hero = Hero.find(params[:hero_id])
  end
end
