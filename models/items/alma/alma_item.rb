class AlmaItem < Item
  def url
    "https://search.lib.umich.edu/catalog/record/#{@body["mms_id"]}"
  end
end
