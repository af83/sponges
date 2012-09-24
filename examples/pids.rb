# encoding: utf-8
require_relative '../lib/sponges'

class Worker
  def run
    puts Process.pid
    sleep 10
    run
  end
end

Sponges.configure do |config|
  config.worker_name   = "bob"
  config.worker        = Worker.new
  config.worker_method = :run
end
Sponges::Runner.new("bob").work(Worker.new, :run)
