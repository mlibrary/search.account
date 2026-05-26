class InterlibraryLoanItem < Item
  def initialize(body)
    super
    if @body["RequestType"] == "Article"
      @title = [@body["PhotoJournalTitle"], @body["PhotoArticleTitle"]].reject { |e| e.to_s.empty? }.join(": ")
      @author = [@body["PhotoArticleAuthor"], @body["PhotoItemAuthor"]].reject { |e| e.to_s.empty? }.join("; ")
      @description = (!@body["PhotoJournalVolume"].nil?) ? "vol #{@body["PhotoJournalVolume"]}" : ""
    else
      @title = @body["LoanTitle"] || ""
      @author = @body["LoanAuthor"] || ""
      @description = ""
    end
  end

  def illiad_id
    @body["TransactionNumber"]
  end

  def illiad_url(action, form, type = false)
    "https://ill.lib.umich.edu/illiad/illiad.dll?Action=#{action}&#{type ? "Type" : "Form"}=#{form}&Value=#{illiad_id}"
  end

  def url
    url_transaction
  end

  def url_transaction
    illiad_url(10, 72)
  end

  def url_cancel_request
    illiad_url(21, 10, true)
  end

  def renew_text
    if renewable?
      "Yes - select title to request renewal"
    else
      "No - not eligible for renewal"
    end
  end

  def creation_date
    @body["CreationDate"] ? DateTime.patron_format(@body["CreationDate"]) : ""
  end

  def expiration_date
    @body["DueDate"] ? DateTime.patron_format(@body["DueDate"]) : ""
  end

  def due_status
    @body["DueDate"] ? DueStatus.new(due_date: @body["DueDate"]) : OpenStruct.new(any?: false)
  end

  def transaction_date
    @body["TransactionDate"] ? DateTime.patron_format(@body["TransactionDate"]) : ""
  end

  def renewable?
    @body["RenewalsAllowed"]
  end
end
