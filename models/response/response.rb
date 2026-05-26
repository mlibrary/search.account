class Response
  attr_reader :status, :code, :message, :body
  def initialize(status: 200, message: "Success", body: {})
    @status = status
    @message = message
    @body = body
  end
end

# class RenewResponse < Response
# attr_reader :code, :renewed, :not_renewed, :messages, :renewed_count, :not_renewed_count
# def initialize(code: 200, messages: [], renew_statuses: [])
# @code = code
# @messages = messages
# @renew_statuses = renew_statuses
# @renewed_count = @renew_statuses.count { |x| x == :success }
# @not_renewed_count = @renew_statuses.count { |x| x == :fail }
# end
# end

class Error < Response
  def initialize(status: 500, message: "There was an error")
    super
  end
end

class AlmaError < Error
  def initialize(response)
    @body = response.body
    @status = response.status

    @message = get_messages
  end

  private

  def get_messages
    errors = @body.dig("errorList", "error")&.map { |x| x["errorMessage"].strip }
    message = errors&.join(" ") || ""
    message.to_s
  end
end
