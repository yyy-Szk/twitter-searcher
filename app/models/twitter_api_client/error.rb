class TwitterApiClient
  class Error < StandardError
  end

  class TooManyRequestError < Error
    attr_reader :reset_at

    def initialize(error_message = nil, reset_at:)
      super(error_message)
      @reset_at = reset_at
    end
  end

  class ResponseError < Error
  end
end
