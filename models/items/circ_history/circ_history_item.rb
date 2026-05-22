class CirculationHistoryItems < Items
  attr_reader :pagination
  def initialize(body:, pagination:)
    @body = body
    @items = @body["loans"]&.map do |loan|
      CirculationHistoryItem.new(loan)
    end || []
    @pagination = pagination
  end

  def count
    @body["total_record_count"]
  end

  def self.for(uniqname:, offset: nil, limit: nil,
    order_by: nil, direction: nil,
    client: CircHistoryClient.new(uniqname))
    query = {}
    query["offset"] = offset unless offset.nil?
    query["limit"] = limit unless limit.nil?
    query["order_by"] = order_by unless order_by.nil?
    query["direction"] = direction.nil? ? "DESC" : direction
    query["direction"] = direction unless direction.nil?

    response = client.loans(query)
    if response.code == 200
      body = response.parsed_response

      pagination_params = {url: "/past-activity/u-m-library", total: body["total_record_count"]}
      pagination_params[:limit] = limit unless limit.nil?
      pagination_params[:current_offset] = offset unless offset.nil?
      pagination_params[:order_by] = order_by unless order_by.nil?
      pagination_params[:direction] = direction.nil? ? "DESC" : direction
      CirculationHistoryItems.new(body: body, pagination: CirculationHistoryPaginationDecorator.new(**pagination_params))
    end
  end
end

class CirculationHistoryItem < Item
  def url
    "https://search.lib.umich.edu/catalog/record/#{mms_id}"
  end

  def call_number
    @body["call_number"]
  end

  def barcode
    @body["barcode"]
  end

  def description
    @body["description"]
  end

  def checkout_date
    DateTime.patron_format(@body["checkout_date"])
  end

  def return_date
    DateTime.patron_format(@body["return_date"])
  end

  def mms_id
    @body["mms_id"]
  end
end
