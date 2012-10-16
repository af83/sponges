# encoding: utf-8
module Sponges
  # This class concern is to expose a nice CLI interface.
  #
  class Cli < Boson::Runner
    option :daemonize,  type: :boolean
    option :size,       type: :numeric
    desc "Start workers"
    def start(options = {})
      worker = Sponges::Runner.new(Sponges::Configuration.worker_name, options)
      if Sponges::Configuration.worker_args
        worker.work(Sponges::Configuration.worker, Sponges::Configuration.worker_method,
             Sponges::Configuration.worker_args)
      else
        worker.work(Sponges::Configuration.worker, Sponges::Configuration.worker_method)
      end
    end

    option :gracefully, type: :boolean
    desc "Stop workers"
    def stop(options = {})
      Sponges::Commander.new(Sponges::Configuration.worker_name, options).
        stop
    end

    option :daemonize,  type: :boolean
    option :size,       type: :numeric
    option :gracefully, type: :boolean
    desc "Restart workers"
    def restart(options = {})
      stop(options)
      start(options)
    end

    desc "Increment workers pool size"
    def increment(options = {})
      Sponges::Commander.new(Sponges::Configuration.worker_name, options).
        increment
    end

    desc "Show running processes"
    def list
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
