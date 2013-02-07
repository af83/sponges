# encoding: utf-8
require_relative '../lib/sponges'

class Worker
  def initialize
    trap(:HUP) {
      Sponges.logger.info "HUP signal trapped, clean stop."
      @hup = true
    }
  end

  def run
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
  config.after_fork do
    puts "forked"
  end
  config.on_chld do
    puts "Child exit"
  end
end

Sponges.start "bob" do
  Worker.new.run
end
