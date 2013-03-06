# encoding: utf-8
module Sponges
  # This class concern is to expose a nice CLI interface.
  #
  class Cli < Boson::Runner
    option :daemonize,  type: :boolean
    option :size,       type: :numeric
    desc "Start workers"
    def start(options = {})
      options = {
        size: Sponges::Configuration.size,
        daemonize: Sponges::Configuration.daemonize
      }.reject{|k, v| v.nil?}.merge(options)
      Sponges::Runner.new(Sponges::Configuration.worker_name, options,
                          Sponges::Configuration.worker
                         ).start
    end

    option :gracefully, type: :boolean
    option :timeout,    type: :numeric
    desc "Stop workers"
    def stop(options = {})
      options = {
        timeout:    Sponges::Configuration.timeout,
        gracefully: Sponges::Configuration.gracefully
      }.reject{|k, v| v.nil?}.merge(options)
      Sponges::Commander.new(Sponges::Configuration.worker_name, options).stop
    end

    desc "Kill workers"
    def kill(options = {})
      Sponges::Commander.new(Sponges::Configuration.worker_name, options).kill
    end

    option :daemonize,  type: :boolean, default: true
    option :size,       type: :numeric
    option :gracefully, type: :boolean
    option :timeout,    type: :numeric
    desc "Restart workers"
    def restart(options = {})
      stop(options)
      sleep 1
      start(options)
    end

    desc "Increment workers pool size"
    def increment(options = {})
      Sponges::Commander.new(Sponges::Configuration.worker_name, options).
        increment
    end

    desc "Decrement workers pool size"
    def decrement(options = {})
      Sponges::Commander.new(Sponges::Configuration.worker_name, options).
        decrement
    end
  end

end
