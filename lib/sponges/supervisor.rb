# encoding: utf-8
module Sponges
  class Supervisor
    def initialize(name, options, worker, method, *args, &block)
      @name, @options = name, options
      @worker, @method, @args, @block = worker, method, args, block
      @redis = Nest.new('sponges')
      @redis[:workers].sadd name
      @pids = @redis[:worker][name][:pids]
      @children_seen = 0
    end

    def start
      @options[:size].times do
        fork_children
      end
      trap_signals
      sleep
    end

    private

    def fork_children
      name = children_name
      pid = fork do
        $PROGRAM_NAME = name
        Sponges::WorkerBuilder.new(@worker, @method, *@args, &@block).start
      end
      Sponges.logger.info "Supervisor create a child with #{pid} pid."
      @pids.sadd pid
    end

    def children_name
      "#{@name}_child_#{@children_seen +=1}"
    end

    def trap_signals
      (Sponges::SIGNALS + [:HUP]).each do |signal|
        trap(signal) do
          handle_signal signal
        end
      end
      trap(:CHLD) do
        pids.each do |pid|
          begin
            dead = Process.waitpid(pid.to_i, Process::WNOHANG)
            if dead
              Sponges.logger.warn "Child #{dead} died. Restarting a new one..."
              @pids.srem dead
              fork_children
            end
          rescue Errno::ECHILD => e
            Sponges.logger.error e
          end
        end
      end
    end

    def handle_signal(signal)
      Sponges.logger.info "Supervisor received #{signal} signal."
      kill_them_all(signal)
      Process.waitall
      Sponges.logger.info "Children shutdown complete."
      Sponges.logger.info "Supervisor shutdown. Exiting..."
      Process.kill :USR1, @redis[:worker][@name][:supervisor].to_i
    end

    def kill_them_all(signal)
      pids.each do |pid|
        begin
          Process.kill signal, pid.to_i
          @pids.srem pid
          Sponges.logger.info "Child #{pid} receive a #{signal} signal."
        rescue Errno::ESRCH => e
          Sponges.logger.error e
        end
      end
    end

    def pids
      Array(@pids.smembers)
    end
  end
end
