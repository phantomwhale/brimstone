class ItemsController < ApplicationController
  before_action :set_hero
  before_action :set_item, only: [:edit, :update, :destroy, :equip, :unequip]

  def edit
    respond_to do |format|
      format.html { redirect_to @hero }
      format.turbo_stream
    end
  end

  def create
    @item = @hero.items.build(item_params)
    
    if @item.save
      # Auto-equip if the item is equippable and can be equipped
      @item.equip! if @item.equippable? && @item.can_equip?
      
      respond_to do |format|
        format.html { redirect_to @hero, notice: "Item '#{@item.name}' was added." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @hero, alert: "Could not create item: #{@item.errors.full_messages.join(', ')}" }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("item-form", partial: "items/form", locals: { hero: @hero, item: @item }) }
      end
    end
  end

  def update
    if @item.update(item_params)
      respond_to do |format|
        format.html { redirect_to @hero, notice: "Item '#{@item.name}' was updated." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @hero, alert: "Could not update item." }
        format.turbo_stream
      end
    end
  end

  def destroy
    name = @item.name
    @item.destroy
    
    respond_to do |format|
      format.html { redirect_to @hero, notice: "Item '#{name}' was removed." }
      format.turbo_stream
    end
  end

  def equip
    if @item.equip!
      respond_to do |format|
        format.html { redirect_to @hero, notice: "#{@item.name} equipped." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @hero, alert: @item.cannot_equip_reason || "Cannot equip item." }
        format.turbo_stream
      end
    end
  end

  def unequip
    @item.unequip!
    
    respond_to do |format|
      format.html { redirect_to @hero, notice: "#{@item.name} unequipped." }
      format.turbo_stream
    end
  end

  private

  def set_hero
    @hero = Hero.find(params[:hero_id])
  end

  def set_item
    @item = @hero.items.find(params[:id])
  end

  def item_params
    permitted = params.require(:item).permit(
      :name, :description, :hands_required, :weight, 
      body_parts: [],
      adjustment_attributes: [:id, :hero_id, :title, :active, modifiers: {}]
    )
    
    # Clean up body_parts array - remove empty strings
    if permitted[:body_parts].present?
      permitted[:body_parts] = permitted[:body_parts].reject(&:blank?)
    end
    
    # Update adjustment title to match item name
    if permitted[:adjustment_attributes].present? && permitted[:name].present?
      permitted[:adjustment_attributes][:title] = permitted[:name]
    end
    
    permitted
  end
end
