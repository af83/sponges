# encoding: utf-8
module Sponges
  class Runner
    def initialize(name, options = {})
      Sponges.logger.info "Runner #{name} started."
      @name = name
      @options = default_options.merge options
      @redis = Nest.new('sponges')
    end

    def work(worker, method, *args, &block)
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
  end
end
