# encoding: utf-8
module Sponges
  class Cli  < Boson::Runner
    option :daemonize, type: :boolean

    desc "Start workers"
    def start(options = {})
      Sponges::Runner.new(Sponges::Configuration.worker_name, options).
        work(Sponges::Configuration.worker, Sponges::Configuration.worker_method)
    end
  end
end
