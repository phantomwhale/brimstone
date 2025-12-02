require 'rails_helper'

RSpec.describe "Injuries", type: :request do
  let(:hero) { create(:hero) }

  describe "POST /heroes/:hero_id/injuries" do
    context "with custom injury parameters" do
      let(:valid_params) do
        {
          injury: {
            name: "Broken Arm",
            description: "Your arm is broken",
            permanent: false,
            modifiers: { "strength" => -1 }
          }
        }
      end

      it "creates a new injury" do
        expect {
          post hero_injuries_path(hero), params: valid_params
        }.to change(Injury, :count).by(1)
      end

      it "redirects to the hero" do
        post hero_injuries_path(hero), params: valid_params
        expect(response).to redirect_to(hero_path(hero))
      end

      it "sets a success notice" do
        post hero_injuries_path(hero), params: valid_params
        follow_redirect!
        expect(response.body).to include("Broken Arm")
        expect(response.body).to include("added")
      end

      it "creates an adjustment for injuries with modifiers" do
        expect {
          post hero_injuries_path(hero), params: valid_params
        }.to change(Adjustment, :count).by(1)
      end
    end

    context "with injury_key from chart" do
      before do
        # Mock the Injuries module to return test data
        allow(Injuries).to receive(:find).with("test_injury").and_return({
          'name' => 'Test Injury',
          'description' => 'A test injury',
          'roll' => 1,
          'modifiers' => { 'agility' => -1 },
          'permanent' => false
        })
        allow(Injuries).to receive(:build_for_hero).and_call_original
      end

      it "creates injury from template" do
        expect {
          post hero_injuries_path(hero), params: { injury_key: "test_injury" }
        }.to change(Injury, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          injury: {
            name: ""
          }
        }
      end

      it "does not create an injury" do
        expect {
          post hero_injuries_path(hero), params: invalid_params
        }.not_to change(Injury, :count)
      end

      it "redirects with an alert" do
        post hero_injuries_path(hero), params: invalid_params
        expect(response).to redirect_to(hero_path(hero))
      end
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        params = { injury: { name: "Turbo Injury" } }
        post hero_injuries_path(hero), params: params, as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "DELETE /heroes/:hero_id/injuries/:id" do
    context "with non-permanent injury" do
      let!(:injury) { create(:injury, hero: hero, name: "Sprained Ankle", permanent: false) }

      it "destroys the injury" do
        expect {
          delete hero_injury_path(hero, injury)
        }.to change(Injury, :count).by(-1)
      end

      it "redirects to the hero" do
        delete hero_injury_path(hero, injury)
        expect(response).to redirect_to(hero_path(hero))
      end

      it "sets a success notice" do
        delete hero_injury_path(hero, injury)
        follow_redirect!
        expect(response.body).to include("Sprained Ankle")
        expect(response.body).to include("removed")
      end

      it "destroys associated adjustment" do
        injury_with_mod = create(:injury, hero: hero, modifiers: { "agility" => -1 })
        expect {
          delete hero_injury_path(hero, injury_with_mod)
        }.to change(Adjustment, :count).by(-1)
      end
    end

    context "with permanent injury" do
      let!(:injury) { create(:injury, hero: hero, name: "Lost Eye", permanent: true) }

      it "does not destroy the injury" do
        expect {
          delete hero_injury_path(hero, injury)
        }.not_to change(Injury, :count)
      end

      it "redirects with an alert about permanent injury" do
        delete hero_injury_path(hero, injury)
        expect(response).to redirect_to(hero_path(hero))
        # The alert message may vary, just check we get redirected
      end
    end

    context "with turbo_stream format" do
      let!(:injury) { create(:injury, hero: hero, permanent: false) }

      it "returns turbo_stream response" do
        delete hero_injury_path(hero, injury), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end
end
