# encoding: utf-8
require_relative '../lib/sponges'

class Worker
  def run
    trap(:HUP) {
      Sponges.logger.info "HUP signal trapped, clean stop."
      @hup = true
    }
    Sponges.logger.info Process.pid
    if @hup
      Sponges.logger.info "HUP signal trapped, shutdown..."
      exit 0
    else
      sleep rand(20)
      run
    end
  end
end

Sponges.configure do |config|
  config.worker        = Worker.new
  config.worker_name   = "bob"
  config.worker_method = :run
  config.redis         = Redis.new
end

Sponges.start
