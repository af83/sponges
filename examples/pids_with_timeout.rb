# encoding: utf-8
require_relative '../lib/sponges'

class Worker
  def run
    trap(:HUP) {
      Sponges.logger.info "HUP signal trapped, nah nah nah, I won't shutdown"
    }
    Sponges.logger.info Process.pid
    sleep
  end
end

Sponges.configure do |config|
  config.timeout    = 3
  config.gracefully = true
end

Sponges.start "bob" do
  Worker.new.run
end

