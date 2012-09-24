# encoding: utf-8
module Sponges
  class Runner
    def initialize(name, options = {})
      Sponges.logger.info "Runner #{name} started."
      @name = name
      @options = default_options.merge options
    end

    def work(worker, method, *args, &block)
      @Supervisor = fork_Supervisor(worker, method, *args, &block)
      trap_signals
      Sponges.logger.info "Supervisor started with #{@Supervisor} pid."
      if daemonize?
        Sponges.logger.info "Supervisor daemonized."
        Process.daemon
      else
        Process.waitpid(@Supervisor) unless daemonize?
      end
    end

    private

    def trap_signals
      Sponges::SIGNALS.each do |signal|
        trap(signal) {|signal| kill_Supervisor(signal) }
      end
    end

    def kill_Supervisor(signal)
      Sponges.logger.info "Supervisor receive a #{signal} signal."
      Process.kill :USR1, @Supervisor
    end

    def default_options
      {
        size: CpuInfo.cores_size
      }
    end

    def fork_Supervisor(worker, method, *args, &block)
      fork do
        $PROGRAM_NAME = "#{@name}_Supervisor"
        Supervisor.new(@name, @options, worker, method, *args, &block).start
      end
    end

    def daemonize?
      !!@options[:daemonize]
    end
  end
end
