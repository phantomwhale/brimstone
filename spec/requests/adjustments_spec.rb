require 'rails_helper'

RSpec.describe "Adjustments", type: :request do
  let(:hero) { create(:hero) }

  describe "POST /heroes/:hero_id/adjustments" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          adjustment: {
            title: "Blessing of Strength",
            active: true,
            modifiers: { "strength" => 2, "agility" => 1 }
          }
        }
      end

      it "creates a new adjustment" do
        expect {
          post hero_adjustments_path(hero), params: valid_params
        }.to change(Adjustment, :count).by(1)
      end

      it "redirects to the hero" do
        post hero_adjustments_path(hero), params: valid_params
        expect(response).to redirect_to(hero_path(hero))
      end

      it "sets a success notice" do
        post hero_adjustments_path(hero), params: valid_params
        follow_redirect!
        expect(response.body).to include("Blessing of Strength")
        expect(response.body).to include("was added")
      end

      it "associates the adjustment with the hero" do
        post hero_adjustments_path(hero), params: valid_params
        expect(Adjustment.last.hero).to eq(hero)
      end

      it "converts modifier values to integers and removes zeros" do
        params = {
          adjustment: {
            title: "Test",
            modifiers: { "strength" => "2", "agility" => "0" }
          }
        }
        post hero_adjustments_path(hero), params: params
        adjustment = Adjustment.last
        expect(adjustment.modifiers).to eq({ "strength" => 2 })
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          adjustment: {
            title: "",
            modifiers: {}
          }
        }
      end

      it "does not create an adjustment" do
        expect {
          post hero_adjustments_path(hero), params: invalid_params
        }.not_to change(Adjustment, :count)
      end

      it "redirects with an alert" do
        post hero_adjustments_path(hero), params: invalid_params
        expect(response).to redirect_to(hero_path(hero))
      end
    end

    context "with turbo_stream format" do
      let(:valid_params) do
        {
          adjustment: {
            title: "Turbo Adjustment",
            active: true,
            modifiers: { "strength" => 1 }
          }
        }
      end

      it "returns turbo_stream response" do
        post hero_adjustments_path(hero), params: valid_params, as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "PATCH /heroes/:hero_id/adjustments/:id" do
    let!(:adjustment) { create(:adjustment, hero: hero, title: "Old Title", modifiers: { "strength" => 1 }) }

    context "with valid parameters" do
      let(:update_params) do
        {
          adjustment: {
            title: "New Title",
            modifiers: { "strength" => 3 }
          }
        }
      end

      it "updates the adjustment" do
        patch hero_adjustment_path(hero, adjustment), params: update_params
        adjustment.reload
        expect(adjustment.title).to eq("New Title")
        expect(adjustment.modifiers["strength"]).to eq(3)
      end

      it "redirects to the hero" do
        patch hero_adjustment_path(hero, adjustment), params: update_params
        expect(response).to redirect_to(hero_path(hero))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          adjustment: {
            title: ""
          }
        }
      end

      it "does not update the adjustment" do
        patch hero_adjustment_path(hero, adjustment), params: invalid_params
        expect(adjustment.reload.title).to eq("Old Title")
      end
    end

    context "with turbo_stream format" do
      it "returns successful response" do
        patch hero_adjustment_path(hero, adjustment), params: { adjustment: { title: "Updated" } }, as: :turbo_stream
        expect(response).to have_http_status(:success).or have_http_status(:redirect)
      end
    end
  end

  describe "DELETE /heroes/:hero_id/adjustments/:id" do
    let!(:adjustment) { create(:adjustment, hero: hero, title: "To Delete") }

    it "destroys the adjustment" do
      expect {
        delete hero_adjustment_path(hero, adjustment)
      }.to change(Adjustment, :count).by(-1)
    end

    it "redirects to the hero" do
      delete hero_adjustment_path(hero, adjustment)
      expect(response).to redirect_to(hero_path(hero))
    end

    it "sets a success notice" do
      delete hero_adjustment_path(hero, adjustment)
      follow_redirect!
      expect(response.body).to include("To Delete")
      expect(response.body).to include("was removed")
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        delete hero_adjustment_path(hero, adjustment), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "PATCH /heroes/:hero_id/adjustments/:id/toggle" do
    let!(:adjustment) { create(:adjustment, hero: hero, active: true) }

    it "toggles the adjustment active state" do
      patch toggle_hero_adjustment_path(hero, adjustment)
      expect(adjustment.reload.active).to be false
    end

    it "toggles back to active" do
      adjustment.update(active: false)
      patch toggle_hero_adjustment_path(hero, adjustment)
      expect(adjustment.reload.active).to be true
    end

    it "redirects to the hero" do
      patch toggle_hero_adjustment_path(hero, adjustment)
      expect(response).to redirect_to(hero_path(hero))
    end

    it "sets appropriate notice for deactivation" do
      patch toggle_hero_adjustment_path(hero, adjustment)
      follow_redirect!
      expect(response.body).to include("deactivated")
    end

    it "sets appropriate notice for activation" do
      adjustment.update(active: false)
      patch toggle_hero_adjustment_path(hero, adjustment)
      follow_redirect!
      expect(response.body).to include("activated")
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        patch toggle_hero_adjustment_path(hero, adjustment), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end
end
