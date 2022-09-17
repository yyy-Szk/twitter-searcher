class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  before_perform do |job|
    Rails.logger.debug "========================================"
    Rails.logger.debug "開始時間: #{Time.now}"
    Rails.logger.debug "========================================"
  end

  after_perform do |job|
    Rails.logger.debug "========================================"
    Rails.logger.debug "終了時間: #{Time.now}"
    Rails.logger.debug "========================================"
  end
end
