class InterlibraryLoans < InterlibraryLoanItems
  attr_reader :pagination, :count
  def initialize(pagination:, body:, count: nil)
    super
    @items = body.map { |item| InterlibraryLoan.new(item) }
    @pagination = pagination
    @count = count
  end

  def self.illiad_url(uniqname)
    "/Transaction/UserRequests/#{uniqname}"
  end

  def self.url
    "/current-checkouts/interlibrary-loan"
  end

  def self.filter
    "RequestType eq 'Loan' and TransactionStatus eq 'Checked Out to Customer' and ProcessType eq 'Borrowing'"
  end
end

class InterlibraryLoan < InterlibraryLoanItem
end
