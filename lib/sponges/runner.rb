# encoding: utf-8
module Sponges
  class Runner
    def initialize(name, options = {})
      @name = name
      @options = default_options.merge options
      @redis = Nest.new('sponges', Configuration.redis || Redis.new)
    end

    def work(worker, method, *args, &block)
      Sponges.logger.info "Runner #{@name} start message received."
      @supervisor = fork_supervisor(worker, method, *args, &block)
      @redis[:worker][@name][:supervisor].set @supervisor
      trap_signals
      Sponges.logger.info "Supervisor started with #{@supervisor} pid."
      if daemonize?
        Sponges.logger.info "Supervisor daemonized."
        Process.daemon
      else
        Process.waitpid(@supervisor) unless daemonize?
      end
    end

    def rest
      Sponges.logger.info "Runner #{@name} stop message received."
      if pid = @redis[:worker][@name][:supervisor].get
        begin
          Process.kill gracefully? ? :HUP : :QUIT, pid.to_i
        rescue Errno::ESRCH => e
          Sponges.logger.error e
        end
      else
        Sponges.logger.info "No supervisor found."
      end
    end

    private

    def trap_signals
      Sponges::SIGNALS.each do |signal|
        trap(signal) {|signal| kill_supervisor(signal) }
      end
    end

    def kill_supervisor(signal)
      Sponges.logger.info "Supervisor receive a #{signal} signal."
      Process.kill :USR1, @supervisor
    end

    def default_options
      {
        size: CpuInfo.cores_size
      }
    end

    def fork_supervisor(worker, method, *args, &block)
      fork do
        $PROGRAM_NAME = "#{@name}_supervisor"
        Supervisor.new(@name, @options, worker, method, *args, &block).start
      end
    end

    def daemonize?
      !!@options[:daemonize]
    end

    def gracefully?
      !!@options[:gracefully]
    end
  end
end
