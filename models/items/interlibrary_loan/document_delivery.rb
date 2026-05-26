class DocumentDelivery < InterlibraryLoanItems
  attr_reader :pagination, :count
  def initialize(pagination:, body:, count: nil)
    super
    @items = body.map { |item| DocumentDeliveryItem.new(item) }
    @pagination = pagination
    @count = count
  end

  def self.illiad_url(uniqname)
    "/Transaction/UserRequests/#{uniqname}"
  end

  def self.url
    "/current-checkouts/scans-and-electronic-items"
  end

  def self.filter
    "RequestType eq 'Article' and TransactionStatus eq 'Delivered to Web'"
  end
end

class DocumentDeliveryItem < InterlibraryLoanItem
end
