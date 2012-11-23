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
  config.redis         = Redis.new
  config.size          = 10
  config.daemonize     = true
end

Sponges.start "pids_with_default" do
  Worker.new.run
end
