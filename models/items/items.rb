class Items
  def initialize(body)
    @body = body
    @items = []
  end

  def count
    @items.length
  end

  def each(&block)
    @items.each do |item|
      block.call(item)
    end
  end

  def empty?
    count == 0
  end

  def item_text
    (count == 1) ? "item" : "items"
  end
end
