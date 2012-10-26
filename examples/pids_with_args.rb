# encoding: utf-8
require_relative '../lib/sponges'

class Worker
  def run(user)
    trap(:HUP) {
      Sponges.logger.info "HUP signal trapped, clean stop."
      @hup = true
    }
    Sponges.logger.info user
    if @hup
      Sponges.logger.info "HUP signal trapped, shutdown..."
      exit 0
    else
      sleep rand(20)
      run(user)
    end
  end
end

Sponges.start "bob" do
  Worker.new.run "bob"
end
