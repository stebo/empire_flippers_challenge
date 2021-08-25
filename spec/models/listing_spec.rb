require 'rails_helper'

RSpec.describe Listing, type: :model do
  fixtures :listings

  describe "fetching listings from EmpireFlippers API" do

    it "should create a new listing if not already present" do
      response = JSON.parse(File.read(File.join("spec", "fixtures", "empire_flippers_api", "new_listing.json")))
      
      stub_request(:get, /api.empireflippers.com/)
        .to_return(
          status: 200,
          body: response.to_json,
          headers: {content_type: 'application/json'}
        )

      expect { Listing.fetch_and_upsert_all_from_remote }
        .to change{ Listing.count }.by(1)
    end

    it "should update the data of an already present listing" do
      response = JSON.parse(File.read(File.join("spec", "fixtures", "empire_flippers_api", "present_listing.json")))
      
      stub_request(:get, /api.empireflippers.com/)
        .to_return(
          status: 200,
          body: response.to_json,
          headers: {content_type: 'application/json'}
        )
      
      expect { Listing.fetch_and_upsert_all_from_remote }
        .to change{ listings(:listing_55644).reload.listing_price }
        .to(response['data']['listings'].first['listing_price'])
    end
  end

  describe "pushing a listing to Hubspot for deal creation" do
    it "should save the returned hubspot_deal_id with the listing" do
      hubspot_deal_id = "4601823213"

      stub_request(:post, /api.hubapi.com/)
      .to_return(
        status: 200,
        body: { id: hubspot_deal_id }.to_json,
        headers: {content_type: 'application/json'}
      )
      
      expect { listings(:listing_55644).create_as_hubspot_deal }
        .to change{ listings(:listing_55644).hubspot_deal_id }.from(nil).to(hubspot_deal_id)
    end
  end
end
