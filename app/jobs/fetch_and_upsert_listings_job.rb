class FetchAndUpsertListingsJob < ApplicationJob
  def perform
    Listing.fetch_and_upsert_all_from_remote
  end
end