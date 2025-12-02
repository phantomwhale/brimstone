require 'rails_helper'

RSpec.describe "Mutations", type: :request do
  let(:hero) { create(:hero) }

  describe "POST /heroes/:hero_id/mutations" do
    context "with custom mutation parameters" do
      let(:valid_params) do
        {
          mutation: {
            name: "Extra Arm",
            description: "You have grown an extra arm",
            modifiers: { "total_hands" => 1 }
          }
        }
      end

      it "creates a new mutation" do
        expect {
          post hero_mutations_path(hero), params: valid_params
        }.to change(Mutation, :count).by(1)
      end

      it "redirects to the hero" do
        post hero_mutations_path(hero), params: valid_params
        expect(response).to redirect_to(hero_path(hero))
      end

      it "sets a success notice" do
        post hero_mutations_path(hero), params: valid_params
        follow_redirect!
        expect(response.body).to include("Extra Arm")
        expect(response.body).to include("added")
      end

      it "creates an adjustment for mutations with modifiers" do
        expect {
          post hero_mutations_path(hero), params: valid_params
        }.to change(Adjustment, :count).by(1)
      end
    end

    context "with mutation_key from chart" do
      before do
        allow(Mutations).to receive(:find).with("test_mutation").and_return({
          'name' => 'Test Mutation',
          'description' => 'A test mutation',
          'roll' => 1,
          'modifiers' => { 'strength' => 1 }
        })
        allow(Mutations).to receive(:build_for_hero).and_call_original
      end

      it "creates mutation from template" do
        expect {
          post hero_mutations_path(hero), params: { mutation_key: "test_mutation" }
        }.to change(Mutation, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          mutation: {
            name: ""
          }
        }
      end

      it "does not create a mutation" do
        expect {
          post hero_mutations_path(hero), params: invalid_params
        }.not_to change(Mutation, :count)
      end

      it "redirects with an alert" do
        post hero_mutations_path(hero), params: invalid_params
        expect(response).to redirect_to(hero_path(hero))
      end
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        params = { mutation: { name: "Turbo Mutation" } }
        post hero_mutations_path(hero), params: params, as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "DELETE /heroes/:hero_id/mutations/:id" do
    let!(:mutation) { create(:mutation, hero: hero, name: "Scales") }

    it "destroys the mutation" do
      expect {
        delete hero_mutation_path(hero, mutation)
      }.to change(Mutation, :count).by(-1)
    end

    it "redirects to the hero" do
      delete hero_mutation_path(hero, mutation)
      expect(response).to redirect_to(hero_path(hero))
    end

    it "sets a success notice" do
      delete hero_mutation_path(hero, mutation)
      follow_redirect!
      expect(response.body).to include("Scales")
      expect(response.body).to include("removed")
    end

    it "destroys associated adjustment" do
      mutation_with_mod = create(:mutation, hero: hero, modifiers: { "strength" => 1 })
      expect {
        delete hero_mutation_path(hero, mutation_with_mod)
      }.to change(Adjustment, :count).by(-1)
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        delete hero_mutation_path(hero, mutation), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end
end
