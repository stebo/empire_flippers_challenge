class Listing < ApplicationRecord
  validates :remote_id, presence: true, uniqueness: true

  store_accessor :remote_data, :listing_number, :listing_price, :summary
  
  scope :for_sale, -> { where("remote_data->>'listing_status' = ?", "For Sale") }

  def self.latest_by_remote_created_at
    Listing.order(Arel.sql("(remote_data ->> 'created_at')::timestamp with time zone DESC")).first
  end

  def self.upsert_from_remote_data(data)
    Listing.find_or_initialize_by(remote_id: data['id']).tap do |listing|
      listing.remote_data = data.except('id')
      listing.save
    end
  end

  def self.fetch_and_upsert_all_from_remote
    # if there are no listings present in the db, fetch all existing listings, starting with the oldest
    query_params = { limit: 100, sort: 'created_at', order: 'ASC' }
    # if listings exist, use the latest created_at timestamp to fetch the not yet added listings
    query_params.merge!({ 
      created_at_from: Listing.latest_by_remote_created_at.remote_data['created_at'] 
    }) if Listing.any?

    page = 1
    loop do
      response = EmpireFlippersAPI.new.listings(**query_params.merge!({page: page}))
      break unless response && response['listings'].any?

      response['listings'].each { |listing| Listing.upsert_from_remote_data(listing) }

      break if page >= response['pages']
      page += 1
      
      sleep(1) # comply with Empire Flipper API guidelines, no more than 1 request per second
    end
  end

  def create_as_hubspot_deal
    return if hubspot_deal_id

    begin
      response = 
        Hubspot::Crm::Deals::BasicApi.new.create(
          properties: {
            dealname: "Listing #{listing_number}",
            amount: listing_price,
            closedate: 30.days.from_now, # "Close Date: 30 days from the current time" does that make sense?
            description: summary
          }
        )
      update(hubspot_deal_id: response.id)
    rescue Hubspot::Crm::Deals::ApiError
      false
      # TODO: do some kind of error logging or force re-try of create
    end    
  end
end