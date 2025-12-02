class MutationsController < ApplicationController
  before_action :set_hero
  before_action :set_mutation, only: [:destroy]

  def create
    if params[:mutation_key].present?
      # Create from known mutation template
      @mutation = Mutations.build_for_hero(@hero, params[:mutation_key])
    else
      # Create custom mutation
      @mutation = @hero.mutations.build(mutation_params)
    end

    if @mutation&.save
      respond_to do |format|
        format.html { redirect_to @hero, notice: "Mutation '#{@mutation.name}' added." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @hero, alert: "Could not add mutation." }
        format.turbo_stream
      end
    end
  end

  def destroy
    name = @mutation.name
    @mutation.destroy

    respond_to do |format|
      format.html { redirect_to @hero, notice: "Mutation '#{name}' removed." }
      format.turbo_stream
    end
  end

  private

  def set_hero
    @hero = Hero.find(params[:hero_id])
  end

  def set_mutation
    @mutation = @hero.mutations.find(params[:id])
  end

  def mutation_params
    params.require(:mutation).permit(:name, :description, modifiers: {})
  end
end
