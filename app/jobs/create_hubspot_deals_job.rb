class CreateHubspotDealsJob < ApplicationJob
  def perform
    Listing.for_sale.where(hubspot_deal_id: nil).each do |listing|
      listing.create_as_hubspot_deal
    end
  end
end