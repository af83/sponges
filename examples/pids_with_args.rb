# encoding: utf-8
require_relative '../lib/sponges'

class Worker
  def initialize
    trap(:HUP) {
      Sponges.logger.info "HUP signal trapped, clean stop."
      @hup = true
    }
  end

  def run(user)
    loop do
      Sponges.logger.info user
      if @hup
        Sponges.logger.info "HUP signal trapped, shutdown..."
        exit 0
      end
      sleep rand(20)
    end
  end
end

Sponges.start "bob" do
  Worker.new.run "bob"
end
