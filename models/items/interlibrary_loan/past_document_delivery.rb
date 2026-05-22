class PastDocumentDelivery < InterlibraryLoanItems
  attr_reader :pagination, :count
  def initialize(pagination:, body:, count: nil)
    super
    @items = body.map { |item| PastDocumentDeliveryItem.new(item) }
    @pagination = pagination
    @count = count
  end

  def self.illiad_url(uniqname)
    "/Transaction/UserRequests/#{uniqname}"
  end

  def self.url
    "/past-activity/scans-and-electronic-items"
  end

  def self.filter
    "RequestType eq 'Article' and (TransactionStatus eq 'Request Finished' or startswith(TransactionStatus, 'Cancelled'))"
  end
end

class PastDocumentDeliveryItem < DocumentDeliveryItem
end
