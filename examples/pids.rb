# encoding: utf-8
require_relative '../lib/sponges'

class Worker
  def run
    puts Process.pid
    sleep 10
    run
  end
end

Sponges::Runner.new("bob").work(Worker.new, :run)
