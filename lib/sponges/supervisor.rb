# encoding: utf-8
module Sponges
  class Supervisor
    def initialize(name, options, worker, method, *args, &block)
      @name, @options = name, options
      @worker, @method, @args, @block = worker, method, args, block
      set_up_redis
      @pids = @redis[:worker][name][:pids]
      @children_seen = 0
    end

    def start
      @options[:size].times do
        fork_children
      end
      trap_signals
      at_exit do
        Sponges.logger.info "Supervisor exits."
      end
      Sponges.logger.info "Supervisor started, waiting for messages."
      sleep
    end

    private

    def set_up_redis
      if Configuration.redis
        redis_client = Configuration.redis
        redis_client.client.reconnect
      end
      @redis = Nest.new('sponges', redis_client || Redis.new)[Socket.gethostname]
      @redis[:workers].sadd @name
      @redis[:worker][@name][:supervisor].set Process.pid
    end

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
      trap(:TTIN) do
        Sponges.logger.warn "Supervisor increment child's pool by one."
        fork_children
      end
      trap(:TTOU) do
        Sponges.logger.warn "Supervisor decrement child's pool by one."
        if pids.first
          kill_one(pids.first, :HUP)
        else
          Sponges.logger.warn "No more child to kill."
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
            # Don't panic
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
      pid = @redis[:worker][@name][:supervisor]
      @redis[:worker][@name][:supervisor].del
      @redis[:workers].srem @name
      Process.kill :USR1, pid.to_i
    end

    def kill_them_all(signal)
      pids.each do |pid|
        kill_one(pid, signal)
      end
    end

    def kill_one(pid, signal)
      begin
        Process.kill signal, pid.to_i
        @pids.srem pid
        Sponges.logger.info "Child #{pid} receive a #{signal} signal."
      rescue Errno::ESRCH => e
        # Don't panic
      end
    end

    def pids
      Array(@pids.smembers)
    end
  end
end
