# encoding: utf-8
require 'timeout'

module Sponges
  # This class concern is to send messages to supervisor. It's used to send
  # messages like 'stop' or 'restart'
  #
  class Commander
    attr_reader :store

    def initialize(name, options = {})
      @name, @options = name, options
      @store = Sponges::Store.new(@name)
    end

    # Kills the supervisor, and then all workers.
    #
    def kill
      Sponges.logger.info "Runner #{@name} kill message received."
      stop :KILL
      children_pids.each do|pid|
        begin
          kill_process(:KILL, pid, "Worker")
        rescue Errno::ESRCH => e
          # Don't panic
        ensure
          store.delete_children pid
        end
      end
    end

    # Stops supervisor, signal depends on options given by Boson.
    #
    def stop(signal = nil)
      signal ||= gracefully? ? :HUP : :QUIT
      Sponges.logger.info "Runner #{@name} stop message received."
      if pid = supervisor_pid
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
      if pid = supervisor_pid
        begin
          Process.kill :TTIN, supervisor_pid.to_i
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
      if supervisor_pid
        begin
          Process.kill :TTOU, supervisor_pid.to_i
        rescue Errno::ESRCH => e
          Sponges.logger.error e
        end
      else
        Sponges.logger.info "No supervisor found."
      end
    end

    private

    def supervisor_pid
      @store.supervisor_pid
    end

    def children_pids
      @store.children_pids
    end

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
        # Don't panic
      end
    end

    def alive?(pid)
      !Sys::ProcTable.ps.find {|f| f.pid == pid }.nil?
    end

    def gracefully?
      !!@options[:gracefully]
    end
  end
end
