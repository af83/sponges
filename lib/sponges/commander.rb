# encoding: utf-8
module Sponges
  # This class concern is to send messages to supervisor. It's used to send
  # messages like 'stop' or 'restart'
  #
  class Commander
    def initialize(name, options = {})
      @name, @options = name, options
      @redis = Nest.new('sponges', Configuration.redis || Redis.new)[Socket.gethostname]
    end

    def kill
      Sponges.logger.info "Runner #{@name} kill message received."
      if pid = @redis[:worker][@name][:supervisor].get
        kill_process(:KILL, pid)
      else
        Sponges.logger.info "No supervisor found."
      end
      Array(@redis[:worker][@name][:pids].smembers).each do|pid|
        kill_process(:KILL, pid, "Worker")
      end
    end

    def stop
      Sponges.logger.info "Runner #{@name} stop message received."
      if pid = @redis[:worker][@name][:supervisor].get
        begin
          Process.kill gracefully? ? :HUP : :QUIT, pid.to_i
          while alive?(pid.to_i) do
            Sponges.logger.info "Supervisor #{pid} still alive"
            sleep 0.5
          end
          Sponges.logger.info "Supervisor #{pid} has stopped."
        rescue Errno::ESRCH => e
          Sponges.logger.error e
        end
      else
        Sponges.logger.info "No supervisor found."
      end
    end

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
