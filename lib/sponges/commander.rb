# encoding: utf-8
require 'timeout'

module Sponges
  # This class concern is to send messages to supervisor. It's used to send
  # messages like 'stop' or 'restart'
  #
  class Commander
    def initialize(name, options = {})
      @name, @options = name, options
      @redis = Nest.new('sponges', Configuration.redis || Redis.new)[Socket.gethostname]
    end

    # Kills the supervisor, and then all workers.
    #
    def kill
      Sponges.logger.info "Runner #{@name} kill message received."
      stop :KILL
      Array(@redis[:worker][@name][:pids].smembers).each do|pid|
        kill_process(:KILL, pid, "Worker")
      end
    end

    # Stops supervisor, signal depends on options given by Boson.
    #
    def stop(signal = nil)
      signal ||= gracefully? ? :HUP : :QUIT
      Sponges.logger.info "Runner #{@name} stop message received."
      if pid = @redis[:worker][@name][:supervisor].get
        if @options[:timeout]
          begin
            Timeout::timeout(@options[:timeout]) do
              kill_process(signal, pid)
            end
          rescue Timeout::Error
            kill
          end
        else
          kill_process(signal, pid)
        end
      else
        Sponges.logger.info "No supervisor found."
      end
    end

    # Increment workers's pool by one.
    #
    def increment
      Sponges.logger.info "Runner #{@name} increment message received."
      if pid = @redis[:worker][@name][:supervisor].get
        begin
          Process.kill :TTIN, pid.to_i
        rescue Errno::ESRCH => e
          Sponges.logger.error e
        end
      else
        Sponges.logger.info "No supervisor found."
      end
    end

    # Decrement workers's pool by one.
    #
    def decrement
      Sponges.logger.info "Runner #{@name} decrement message received."
      if pid = @redis[:worker][@name][:supervisor].get
        begin
          Process.kill :TTOU, pid.to_i
        rescue Errno::ESRCH => e
          Sponges.logger.error e
        end
      else
        Sponges.logger.info "No supervisor found."
      end
    end

    private

    def kill_process(signal, pid, type = "Supervisor")
      pid = pid.to_i
      begin
        Process.kill signal, pid
        while alive?(pid) do
          Sponges.logger.info "#{type} #{pid} still alive"
          sleep 0.5
        end
        Sponges.logger.info "#{type} #{pid} has stopped."
      rescue Errno::ESRCH => e
        Sponges.logger.error e
      end
    end

    def alive?(pid)
      begin
        Process.kill 0, pid
        true
      rescue Errno::ESRCH => e
        false
      end
    end

    def gracefully?
      !!@options[:gracefully]
    end
  end
end
