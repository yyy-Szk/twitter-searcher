module Job
  class EnqueueSearchTwitterUserUseCase
    class << self
      def run!
      end
    end

    def initialize
    end

    def run!
      # result = TwitterSearchResult.new
      # if result.save
      #   SearchTwitterUserJob.perform_later(result, search_condition_params, narrow_down_condition_params)
  
      #   redirect_to action: "result", id: result.id
      # else
      #   redirect_to action: "index"
      # end
    end
  end
end
