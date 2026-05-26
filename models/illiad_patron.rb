class ILLiadPatron
  def initialize(body)
    @body = body
  end

  def self.for(uniqname:, illiad_client: ILLiadClient.new)
    resp = illiad_client.get("/Users/#{uniqname}")
    raise StandardError if resp.code != 200
    ILLiadPatron.new(resp.parsed_response)
  rescue
    NotInILLiad.new
  end

  def in_illiad?
    true
  end

  def delivery_location
    [@body["SAddress"], @body["SAddress2"]].reject { |x| x.nil? }.join(" / ")
  end
end

class NotInILLiad
  def in_illiad?
    false
  end

  def delivery_location
    ""
  end
end
