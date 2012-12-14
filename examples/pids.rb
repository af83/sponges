# encoding: utf-8
require_relative '../lib/sponges'
require 'nest'

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
  config.store         = :redis
end

Sponges.start "bob" do
  Worker.new.run
end
