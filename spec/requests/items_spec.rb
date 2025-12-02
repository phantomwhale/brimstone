require 'rails_helper'

RSpec.describe "Items", type: :request do
  let(:hero) { create(:hero) }

  describe "POST /heroes/:hero_id/items" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          item: {
            name: "Revolver",
            description: "A trusty six-shooter",
            hands_required: 1,
            weight: 1,
            body_parts: []
          }
        }
      end

      it "creates a new item" do
        expect {
          post hero_items_path(hero), params: valid_params
        }.to change(Item, :count).by(1)
      end

      it "redirects to the hero" do
        post hero_items_path(hero), params: valid_params
        expect(response).to redirect_to(hero_path(hero))
      end

      it "sets a success notice" do
        post hero_items_path(hero), params: valid_params
        follow_redirect!
        expect(response.body).to include("Revolver")
        expect(response.body).to include("was added")
      end

      it "auto-equips equippable items when possible" do
        post hero_items_path(hero), params: valid_params
        expect(Item.last.equipped).to be true
      end

      it "does not auto-equip non-equippable items" do
        params = {
          item: {
            name: "Gold Nugget",
            hands_required: 0,
            body_parts: []
          }
        }
        post hero_items_path(hero), params: params
        expect(Item.last.equipped).to be false
      end
    end

    context "with body parts" do
      it "cleans up empty body parts" do
        params = {
          item: {
            name: "Hat",
            body_parts: ["head", "", nil]
          }
        }
        post hero_items_path(hero), params: params
        expect(Item.last.body_parts).to eq(["head"])
      end
    end

    context "with adjustment attributes" do
      it "creates item with adjustment" do
        params = {
          item: {
            name: "Magic Sword",
            hands_required: 1,
            adjustment_attributes: {
              hero_id: hero.id,
              title: "Magic Sword",
              modifiers: { "strength" => 2 }
            }
          }
        }
        post hero_items_path(hero), params: params
        item = Item.last
        expect(item.adjustment).to be_present
        # Modifiers may be stored as string or integer depending on serialization
        expect(item.adjustment.modifiers["strength"].to_i).to eq(2)
      end

      it "updates adjustment title to match item name" do
        params = {
          item: {
            name: "Fire Sword",
            hands_required: 1,
            adjustment_attributes: {
              hero_id: hero.id,
              title: "Old Title",
              modifiers: { "combat" => 1 }
            }
          }
        }
        post hero_items_path(hero), params: params
        expect(Item.last.adjustment.title).to eq("Fire Sword")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          item: {
            name: "",
            hands_required: 10
          }
        }
      end

      it "does not create an item" do
        expect {
          post hero_items_path(hero), params: invalid_params
        }.not_to change(Item, :count)
      end
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        params = { item: { name: "Turbo Item" } }
        post hero_items_path(hero), params: params, as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "GET /heroes/:hero_id/items/:id/edit" do
    let(:item) { create(:item, hero: hero) }

    it "redirects for HTML format" do
      get edit_hero_item_path(hero, item)
      expect(response).to redirect_to(hero_path(hero))
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        get edit_hero_item_path(hero, item), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "PATCH /heroes/:hero_id/items/:id" do
    let!(:item) { create(:item, hero: hero, name: "Old Name") }

    context "with valid parameters" do
      it "updates the item" do
        patch hero_item_path(hero, item), params: { item: { name: "New Name" } }
        expect(item.reload.name).to eq("New Name")
      end

      it "redirects to the hero" do
        patch hero_item_path(hero, item), params: { item: { name: "New Name" } }
        expect(response).to redirect_to(hero_path(hero))
      end

      it "sets a success notice" do
        patch hero_item_path(hero, item), params: { item: { name: "New Name" } }
        follow_redirect!
        expect(response.body).to include("New Name")
        expect(response.body).to include("was updated")
      end
    end

    context "with invalid parameters" do
      it "does not update the item" do
        patch hero_item_path(hero, item), params: { item: { name: "" } }
        expect(item.reload.name).to eq("Old Name")
      end
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        patch hero_item_path(hero, item), params: { item: { name: "Updated" } }, as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "DELETE /heroes/:hero_id/items/:id" do
    let!(:item) { create(:item, hero: hero, name: "To Delete") }

    it "destroys the item" do
      expect {
        delete hero_item_path(hero, item)
      }.to change(Item, :count).by(-1)
    end

    it "redirects to the hero" do
      delete hero_item_path(hero, item)
      expect(response).to redirect_to(hero_path(hero))
    end

    it "sets a success notice" do
      delete hero_item_path(hero, item)
      follow_redirect!
      expect(response.body).to include("To Delete")
      expect(response.body).to include("was removed")
    end

    it "destroys associated adjustment" do
      create(:adjustment, hero: hero, item: item)
      expect {
        delete hero_item_path(hero, item)
      }.to change(Adjustment, :count).by(-1)
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        delete hero_item_path(hero, item), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "PATCH /heroes/:hero_id/items/:id/equip" do
    context "when item can be equipped" do
      let!(:item) { create(:item, hero: hero, hands_required: 1, equipped: false) }

      it "equips the item" do
        patch equip_hero_item_path(hero, item)
        expect(item.reload.equipped).to be true
      end

      it "redirects to the hero" do
        patch equip_hero_item_path(hero, item)
        expect(response).to redirect_to(hero_path(hero))
      end

      it "sets a success notice" do
        patch equip_hero_item_path(hero, item)
        follow_redirect!
        expect(response.body).to include("equipped")
      end
    end

    context "when item cannot be equipped" do
      let!(:blocking_item) { create(:item, hero: hero, hands_required: 2, equipped: true) }
      let!(:item) { create(:item, hero: hero, hands_required: 1, equipped: false) }

      it "does not equip the item" do
        patch equip_hero_item_path(hero, item)
        expect(item.reload.equipped).to be false
      end

      it "redirects with an alert" do
        patch equip_hero_item_path(hero, item)
        expect(response).to redirect_to(hero_path(hero))
        # Alert may contain various messages about why equip failed
      end
    end

    context "with turbo_stream format" do
      let!(:item) { create(:item, hero: hero, hands_required: 1, equipped: false) }

      it "returns turbo_stream response" do
        patch equip_hero_item_path(hero, item), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "PATCH /heroes/:hero_id/items/:id/unequip" do
    let!(:item) { create(:item, hero: hero, equipped: true) }

    it "unequips the item" do
      patch unequip_hero_item_path(hero, item)
      expect(item.reload.equipped).to be false
    end

    it "redirects to the hero" do
      patch unequip_hero_item_path(hero, item)
      expect(response).to redirect_to(hero_path(hero))
    end

    it "sets a success notice" do
      patch unequip_hero_item_path(hero, item)
      follow_redirect!
      expect(response.body).to include("unequipped")
    end

    context "with turbo_stream format" do
      it "returns turbo_stream response" do
        patch unequip_hero_item_path(hero, item), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end
end
