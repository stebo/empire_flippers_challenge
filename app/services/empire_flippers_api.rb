class EmpireFlippersAPI
  include HTTParty
  base_uri 'https://api.empireflippers.com/api/v1'

  def capture_response(response)
    if response["errors"].blank?
      response
    else
      false
    end
  end

  # for list of possible query params see 
  # https://empireflippers.com/empire-flippers-public-listings-api/
  def listings(**kwargs)
    options = { query: kwargs }
    capture_response(self.class.get("/listings/list", options)['data'])
  end
end