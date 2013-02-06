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

    option :daemonize,  type: :boolean
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

    desc "Show running processes"
    def list
      if Sponges::Configuration.store == :memory
        puts "Command not available with the memory store"
        exit
      end
      redis = Nest.new('sponges')
      puts %q{
 ___ _ __   ___  _ __   __ _  ___  ___
/ __| '_ \ / _ \| '_ \ / _` |/ _ \/ __|
\__ \ |_) | (_) | | | | (_| |  __/\__ \
|___/ .__/ \___/|_| |_|\__, |\___||___/
    | |                 __/ |
    |_|                |___/
}.gsub(/^\n/, '') + "\n"
      puts "Workers:"
      Array(redis[:hostnames].smembers).each do |hostname|
        puts hostname.rjust(6)
        Array(redis[hostname][:workers].smembers).each do |worker|
          puts worker.rjust(6)
          puts "supervisor".rjust(15)
          puts redis[hostname][:worker][worker][:supervisor].get.rjust(12)
          puts "children".rjust(13)
          Array(redis[hostname][:worker][worker][:pids].smembers).each do |pid|
            puts pid.rjust(12)
          end
        end
      end
      puts "\n"
    end
  end

end
