class Usecase
  include ActiveModel::Model

  class BaseError < StandardError
    attr_accessor :usecase

    def initialize(usecase)
      self.usecase = usecase
    end
  end

  class Error < BaseError
  end

  class Input
    include ActiveModel::Model
    include ActiveModel::Attributes
  end

  class Output
    include ActiveModel::Model
  end
end
