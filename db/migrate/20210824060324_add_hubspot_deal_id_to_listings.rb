class AddHubspotDealIdToListings < ActiveRecord::Migration[6.1]
  def change
    add_column :listings, :hubspot_deal_id, :string
  end
end
