class MadnessesController < ApplicationController
  before_action :set_hero
  before_action :set_madness, only: [:destroy]

  def create
    if params[:madness_key].present?
      # Create from known madness template
      @madness = Madnesses.build_for_hero(@hero, params[:madness_key])
    else
      # Create custom madness
      @madness = @hero.madnesses.build(madness_params)
    end

    if @madness&.save
      respond_to do |format|
        format.html { redirect_to @hero, notice: "Madness '#{@madness.name}' added." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @hero, alert: "Could not add madness." }
        format.turbo_stream
      end
    end
  end

  def destroy
    name = @madness.name
    
    if @madness.permanent?
      respond_to do |format|
        format.html { redirect_to @hero, alert: "#{name} is permanent and cannot be removed." }
        format.turbo_stream
      end
      return
    end
    
    @madness.destroy

    respond_to do |format|
      format.html { redirect_to @hero, notice: "Madness '#{name}' removed." }
      format.turbo_stream
    end
  end

  private

  def set_hero
    @hero = Hero.find(params[:hero_id])
  end

  def set_madness
    @madness = @hero.madnesses.find(params[:id])
  end

  def madness_params
    params.require(:madness).permit(:name, :description, :permanent, modifiers: {})
  end
end
