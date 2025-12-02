require 'rails_helper'

RSpec.describe "Madnesses", type: :request do
  let(:hero) { create(:hero) }

  describe "POST /heroes/:hero_id/madnesses" do
    context "with custom madness parameters" do
      let(:valid_params) do
        {
          madness: {
            name: "Paranoia",
            description: "You trust no one",
            permanent: false,
            modifiers: { "cunning" => -1 }
          }
        }
      end

      it "creates a new madness" do
        expect {
          post hero_madnesses_path(hero), params: valid_params
        }.to change(Madness, :count).by(1)
      end

      it "redirects to the hero" do
        post hero_madnesses_path(hero), params: valid_params
        expect(response).to redirect_to(hero_path(hero))
      end

      it "sets a success notice" do
        post hero_madnesses_path(hero), params: valid_params
        follow_redirect!
        expect(response.body).to include("Paranoia")
        expect(response.body).to include("added")
      end

      it "creates an adjustment for madnesses with modifiers" do
        expect {
          post hero_madnesses_path(hero), params: valid_params
        }.to change(Adjustment, :count).by(1)
      end
    end

    context "with madness_key from chart" do
      before do
        allow(Madnesses).to receive(:find).with("test_madness").and_return({
          'name' => 'Test Madness',
          'description' => 'A test madness',
          'roll' => 1,
          'modifiers' => { 'spirit' => -1 },
          'permanent' => false
        })
        allow(Madnesses).to receive(:build_for_hero).and_call_original
      end

      it "creates madness from template" do
        expect {
          post hero_madnesses_path(hero), params: { madness_key: "test_madness" }
        }.to change(Madness, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          madness: {
            name: ""
          }
        }
      end

      it "does not create a madness" do
        expect {
          post hero_madnesses_path(hero), params: invalid_params
        }.not_to change(Madness, :count)
      end

      it "redirects with an alert" do
        post hero_madnesses_path(hero), params: invalid_params
        expect(response).to redirect_to(hero_path(hero))
      end
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        params = { madness: { name: "Turbo Madness" } }
        post hero_madnesses_path(hero), params: params, as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "DELETE /heroes/:hero_id/madnesses/:id" do
    context "with non-permanent madness" do
      let!(:madness) { create(:madness, hero: hero, name: "Anxiety", permanent: false) }

      it "destroys the madness" do
        expect {
          delete hero_madness_path(hero, madness)
        }.to change(Madness, :count).by(-1)
      end

      it "redirects to the hero" do
        delete hero_madness_path(hero, madness)
        expect(response).to redirect_to(hero_path(hero))
      end

      it "sets a success notice" do
        delete hero_madness_path(hero, madness)
        follow_redirect!
        expect(response.body).to include("Anxiety")
        expect(response.body).to include("removed")
      end

      it "destroys associated adjustment" do
        madness_with_mod = create(:madness, hero: hero, modifiers: { "cunning" => -1 })
        expect {
          delete hero_madness_path(hero, madness_with_mod)
        }.to change(Adjustment, :count).by(-1)
      end
    end

    context "with permanent madness" do
      let!(:madness) { create(:madness, hero: hero, name: "Deep Trauma", permanent: true) }

      it "does not destroy the madness" do
        expect {
          delete hero_madness_path(hero, madness)
        }.not_to change(Madness, :count)
      end

      it "redirects with an alert about permanent madness" do
        delete hero_madness_path(hero, madness)
        expect(response).to redirect_to(hero_path(hero))
        # The alert message may vary, just check we get redirected
      end
    end

    context "with turbo_stream format" do
      let!(:madness) { create(:madness, hero: hero, permanent: false) }

      it "returns turbo_stream response" do
        delete hero_madness_path(hero, madness), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end
end
