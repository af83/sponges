# encoding: utf-8
module Sponges
  class Cli  < Boson::Runner
    option :daemonize, type: :boolean

    desc "Start workers"
    def start(options = {})
      Sponges::Runner.new(Sponges::Configuration.worker_name, options).
        work(Sponges::Configuration.worker, Sponges::Configuration.worker_method)
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
      Array(redis[:workers].smembers).each do |worker|
        puts worker.rjust(6)
        Array(redis[:worker][worker][:pids].smembers).each do |pid|
          puts pid.rjust(worker.size + 8)
        end
      end
      puts "\n"
    end
  end

end
