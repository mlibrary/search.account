class Loans < Items
  attr_reader :pagination
  def initialize(body:, pagination:)
    @body = body
    @items = @body["item_loan"]&.map do |loan|
      Loan.new(loan)
    end || []
    @pagination = pagination
  end

  def count
    @body["total_record_count"]
  end

  def self.for(uniqname:, offset: nil, limit: 15,
    client: AlmaRestClient.client, order_by: nil, direction: nil)
    url = "/users/#{uniqname}/loans"
    query = {"expand" => "renewable"}
    query["offset"] = offset unless offset.nil?
    query["direction"] = direction unless direction.nil?

    query["order_by"] = order_by.nil? ? "due_date" : order_by
    query["limit"] = limit.nil? ? 15 : limit

    response = client.get(url, query: query)
    raise StandardError unless response.status == 200
    body = response.body
    pagination_params = {url: "/current-checkouts/u-m-library", total: body["total_record_count"]}
    pagination_params[:limit] = limit unless limit.nil?
    pagination_params[:current_offset] = offset unless offset.nil?
    pagination_params[:order_by] = order_by unless order_by.nil?
    pagination_params[:direction] = direction unless direction.nil?
    Loans.new(body: body, pagination: PaginationDecorator.new(**pagination_params))
  end
end

class Loan < AlmaItem
  def self.renew(uniqname:, loan_id:, client: AlmaRestClient.client)
    client.post("/users/#{uniqname}/loans/#{loan_id}", query: {op: "renew"})
  end

  def due_date
    DateTime.patron_format(@body["due_date"]) unless claims_returned?
  end

  def loan_id
    @body["loan_id"]
  end

  def call_number
    @body["call_number"]
  end

  def barcode
    @body["item_barcode"]
  end

  def publication_date
    @body["publication_year"]
  end

  def due_status
    return OpenStruct.new(to_s: "Reported as returned", tag: "tag--warning", any?: true) if claims_returned?
    DueStatus.new(due_date: @body["due_date"], last_renew_date: @body["last_renew_date"])
  end

  def due_status_tag
    due_status.tag
  end

  private

  def claims_returned?
    @body["process_status"] == "CLAIMED_RETURN"
  end
end
