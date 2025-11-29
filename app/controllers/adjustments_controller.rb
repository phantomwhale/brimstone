class AdjustmentsController < ApplicationController
  before_action :set_hero
  before_action :set_adjustment, only: [:update, :destroy, :toggle]

  def create
    @adjustment = @hero.adjustments.build(adjustment_params)
    
    if @adjustment.save
      respond_to do |format|
        format.html { redirect_to @hero, notice: "Adjustment '#{@adjustment.title}' was added." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @hero, alert: "Could not create adjustment: #{@adjustment.errors.full_messages.join(', ')}" }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("adjustment-form", partial: "adjustments/form", locals: { hero: @hero, adjustment: @adjustment }) }
      end
    end
  end

  def update
    if @adjustment.update(adjustment_params)
      respond_to do |format|
        format.html { redirect_to @hero, notice: "Adjustment '#{@adjustment.title}' was updated." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @hero, alert: "Could not update adjustment." }
        format.turbo_stream
      end
    end
  end

  def destroy
    title = @adjustment.title
    @adjustment.destroy
    
    respond_to do |format|
      format.html { redirect_to @hero, notice: "Adjustment '#{title}' was removed." }
      format.turbo_stream
    end
  end

  def toggle
    @adjustment.update(active: !@adjustment.active)
    @hero.reload # Reload to get fresh adjustment calculations
    
    respond_to do |format|
      format.html { redirect_to @hero, notice: "Adjustment '#{@adjustment.title}' was #{@adjustment.active? ? 'activated' : 'deactivated'}." }
      format.turbo_stream
    end
  end

  private

  def set_hero
    @hero = Hero.find(params[:hero_id])
  end

  def set_adjustment
    @adjustment = @hero.adjustments.find(params[:id])
  end

  def adjustment_params
    permitted = params.require(:adjustment).permit(:title, :active, modifiers: {})
    
    # Convert modifier values to integers and remove zeros
    if permitted[:modifiers].present?
      permitted[:modifiers] = permitted[:modifiers].to_h.transform_values(&:to_i).reject { |_, v| v == 0 }
    end
    
    permitted
  end
end
