# encoding: utf-8
require_relative '../lib/sponges'

require 'goliath'

class Hello < Goliath::API
  def response(env)
    [200, {}, "Hello World"]
  end
end

class Server
  def self.run
    EM.synchrony do
      hello = Hello.new
      runner = Goliath::Runner.new(ARGV, hello)
      runner.app = Goliath::Rack::Builder.build(Hello, hello)
      # This is just for the example. In real world, http port attribution
      # should be based on some configuration. A list of ports could be given,
      # or having a api responsible for configuration distribution.
      #
      runner.port = Process.pid
      Sponges.logger.info "Start on #{Process.pid} port"
      runner.log_stdout = true
      runner.run
    end
  end
end

Sponges.configure do |config|
  config.worker        = Server
  config.worker_name   = "hello"
  config.worker_method = :run
end

Sponges.start
