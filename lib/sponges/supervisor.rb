# encoding: utf-8
module Sponges
  class Supervisor
    def initialize(name, options, worker, method, *args, &block)
      @name, @options = name, options
      @worker, @method, @args, @block = worker, method, args, block
      @pids = []
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
      @pids << pid
    end

    def children_name
      "#{@name}_child_#{@children_seen +=1}"
    end

    def trap_signals
      Sponges::SIGNALS.each do |signal|
        trap(signal) do
          kill_them_all(signal)
          Process.kill :USR1, Process.pid
        end
      end
      trap(:CHLD) do
        @pids.each do |pid|
          begin
            dead = Process.waitpid(pid, Process::WNOHANG)
            if dead
              Sponges.logger.warn "Child #{dead} died. Restarting a new one..."
              @pids.delete(dead)
              fork_children
            end
          rescue Errno::ECHILD => e
            Sponges.logger.error e
          end
        end
      end
    end

    def kill_them_all(signal)
      @pids.each do |pid|
        begin
          Process.kill signal, pid
          Sponges.logger.info "Child #{pid} receive a #{signal} signal."
        rescue Errno::ESRCH => e
          p e
        end
      end
    end
  end
end
