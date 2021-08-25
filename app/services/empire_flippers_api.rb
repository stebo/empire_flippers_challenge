class EmpireFlippersAPI
  include HTTParty
  base_uri 'https://api.empireflippers.com/api/v1'

  def capture_response(response)
    # TODO: proper error handling
    case response.code
      when 200
        response['data']
      else
        false
    end
  end

  # for list of possible query params see 
  # https://empireflippers.com/empire-flippers-public-listings-api/
  def listings(**kwargs)
    options = { query: kwargs }
    capture_response(self.class.get("/listings/list", options))
  end
end