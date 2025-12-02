class InjuriesController < ApplicationController
  before_action :set_hero
  before_action :set_injury, only: [:destroy]

  def create
    if params[:injury_key].present?
      # Create from known injury template
      @injury = Injuries.build_for_hero(@hero, params[:injury_key])
    else
      # Create custom injury
      @injury = @hero.injuries.build(injury_params)
    end

    if @injury&.save
      respond_to do |format|
        format.html { redirect_to @hero, notice: "Injury '#{@injury.name}' added." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @hero, alert: "Could not add injury." }
        format.turbo_stream
      end
    end
  end

  def destroy
    name = @injury.name
    
    if @injury.permanent?
      respond_to do |format|
        format.html { redirect_to @hero, alert: "#{name} is permanent and cannot be removed." }
        format.turbo_stream
      end
      return
    end
    
    @injury.destroy

    respond_to do |format|
      format.html { redirect_to @hero, notice: "Injury '#{name}' removed." }
      format.turbo_stream
    end
  end

  private

  def set_hero
    @hero = Hero.find(params[:hero_id])
  end

  def set_injury
    @injury = @hero.injuries.find(params[:id])
  end

  def injury_params
    params.require(:injury).permit(:name, :description, :permanent, modifiers: {})
  end
end
