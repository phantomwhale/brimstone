class HeroesController < ApplicationController
  before_action :set_hero, only: %i[show edit update destroy]

  # GET /heroes or /heroes.json
  def index
    @heroes = Hero.all
  end

  # GET /heroes/1 or /heroes/1.json
  def show
  end

  # GET /heroes/new
  def new
    @hero = Hero.new
  end

  # GET /heroes/1/edit
  def edit
  end

  # POST /heroes or /heroes.json
  def create
    @hero = Hero.new(hero_params)
    
    # Copy stats from hero class if hero_class is provided
    if @hero.hero_class.present?
      class_attributes = HeroClasses.attributes_for(@hero.hero_class)
      if class_attributes
        class_attributes.each do |attribute, value|
          @hero.send("#{attribute}=", value) if @hero.respond_to?("#{attribute}=")
        end
      end
    end

    respond_to do |format|
      if @hero.save
        format.html { redirect_to hero_url(@hero), notice: "Hero was successfully created." }
        format.json { render :show, status: :created, location: @hero }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @hero.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /heroes/1 or /heroes/1.json
  def update
    respond_to do |format|
      if @hero.update(hero_params)
        format.html { redirect_to hero_url(@hero), notice: "Hero was successfully updated." }
        format.json { render :show, status: :ok, location: @hero }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @hero.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /heroes/1 or /heroes/1.json
  def destroy
    @hero.destroy

    respond_to do |format|
      format.html { redirect_to heroes_url, notice: "Hero was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_hero
    @hero = Hero.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def hero_params
    params.require(:hero).permit(:name, :hero_class, :health, :sanity, :agility, :cunning, :spirit, :strength, :lore, :luck, :initiative, :range_to_hit, :melee_to_hit, :combat,
      :max_grit, :defense, :willpower, :corrupt_resist, :side_bag_tokens, :experience, :gold, :dark_stone)
  end
end
