class Requests
  attr_reader :holds, :bookings
  def initialize(body:)
    @body = body
    @holds = @body["user_request"]&.select { |r| r["request_type"] == "HOLD" }&.map { |r| HoldRequest.new(r) } || []
    @bookings = @body["user_request"]&.select { |r| r["request_type"] == "BOOKING" }&.map { |r| BookingRequest.new(r) } || []
  end

  def count
    @body["total_record_count"]
  end

  def self.for(uniqname:, client: AlmaRestClient.client)
    url = "/users/#{uniqname}/requests"
    response = client.get_all(url: url, record_key: "user_request")
    raise StandardError unless response.status == 200
    Requests.new(body: response.body)
  end
end

class Request < AlmaItem
  def self.cancel(uniqname:, request_id:, client: AlmaRestClient.client)
    client.delete("/users/#{uniqname}/requests/#{request_id}", query: {reason: "CancelledAtPatronRequest"})
  end

  def self.empty_state(markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML))
    markdown.render(empty_state_text)
  end

  def expiry_date
    @body["expiry_date"] ? DateTime.patron_format(@body["expiry_date"]) : ""
  end

  def publication_date
    @body["date_of_publication"]
  end

  def request_id
    @body["request_id"]
  end

  def pickup_location
    @body["pickup_location"]
  end

  def request_date
    DateTime.patron_format(@body["request_time"])
  end

  def status
    request_status = @body["request_status"] || ""
    normalized_status = request_status.upcase.tr(" ", "_")
    case normalized_status
    when "IN_PROCESS"
      "In process"
    when "ON_HOLD_SHELF"
      "Ready"
    when "NOT_STARTED"
      "Not started"
    else
      ""
    end
  end

  def status_tag
    case status
    when "In process"
      "--warning"
    when "Ready"
      "--success"
    else
      ""
    end
  end
end

class BookingRequest < Request
  def booking_date
    DateTime.patron_format(@body["booking_start_date"])
  end

  def self.empty_state_text
    "You don't have any active media requests."
  end
end

class HoldRequest < Request
  def self.empty_state_text
    "You don't have any active requests.\n\nSee [what you can borrow from the library](https://www.lib.umich.edu/find-borrow-request)."
  end
end
