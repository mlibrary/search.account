class Fines
  def self.for(uniqname:, client: AlmaRestClient.client)
    url = "/users/#{uniqname}/fees"
    response = client.get_all(url: url, record_key: "fee")
    raise StandardError if response.status != 200
    Fines.new(body: response.body)
  end

  def initialize(body:)
    @body = body
    @list = @body["fee"]&.map { |l| Fine.new(l) } || []
  end

  def self.pay(uniqname:, amount:, order_number:, client: AlmaRestClient.client)
    client.post("/users/#{uniqname}/fees/all", query: {op: "pay", method: "ONLINE", amount: amount, external_transaction_id: order_number})
  end

  def count
    @body["total_record_count"] || 0
  end

  def total_sum
    @body["total_sum"] || 0
  end

  def total_sum_in_dollars
    total_sum&.to_currency
  end

  def select(ids)
    @list.select { |x| ids.include?(x.id) }
  end

  def each(&block)
    @list.each do |l|
      block.call(l)
    end
  end

  def each_with_index(&block)
    @list.each_with_index do |l, index|
      block.call(l, index)
    end
  end

  def self.verify_payment(uniqname:, order_number:, client: AlmaRestClient.client)
    url = "/users/#{uniqname}/fees"
    response = client.get_all(url: url, record_key: "fee")
    if response.status == 200
      body = response.body
      transactions = body["fee"].filter_map do |fee|
        fee["transaction"]
      end.flatten
      has_order_number = transactions.any? { |transaction| transaction["external_transaction_id"] == order_number }
      {
        has_order_number: has_order_number,
        total_sum: body["total_sum"]
      }
    else
      # if this errors out return alma error
      AlmaError.new(response)
    end
  end
end

class Fine
  def initialize(body)
    @body = body
  end

  def self.pay(uniqname:, fine_id:, balance:, client: AlmaRestClient.client)
    client.post("/users/#{uniqname}/fees/#{fine_id}",
      query: {op: "pay", method: "ONLINE", amount: balance})
  end

  def id
    @body["id"]
  end

  def title
    @body["title"]
  end

  def barcode
    @body.dig("barcode", "value")
  end

  def date
    DateTime.patron_format(@body["creation_time"])
  end

  def balance
    @body["balance"]&.to_currency
  end

  def type
    @body["type"]["desc"]
  end

  def code
    @body["type"]["value"]
  end

  def original_amount
    @body["original_amount"]&.to_currency
  end

  def library
    @body["owner"]["desc"]
  end
end
