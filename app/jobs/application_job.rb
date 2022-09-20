class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  before_perform do |job|
    @start_time = Time.now
    Rails.logger.info "========================================"
    Rails.logger.info "取得ジョブ開始: #{@start_time}"
    Rails.logger.info "========================================"
  end

  after_perform do |job|
    Rails.logger.info "========================================"
    Rails.logger.info "開始時間: #{@start_time}"
    Rails.logger.info "終了時間: #{Time.now}"
    Rails.logger.info "========================================"
  end
end
