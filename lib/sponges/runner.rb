# encoding: utf-8
module Sponges
  # This class concern is to create a Supervisor, set some signals handlers and
  # watch over the supervisor.
  #
  class Runner
    attr_reader :store

    def initialize(name, options = {}, block)
      @name, @block = name, block
      @options = default_options.merge options
      @store = Sponges::Store.new(@name)
      if store.running?
        Sponges.logger.error "Runner #{@name} already started."
        exit
      end
      store.register_hostname Socket.gethostname
    end

    def start
      if daemonize?
        Sponges.logger.info "Supervisor daemonized."
        Process.daemon
      end
      Sponges.logger.info "Runner #{@name} start message received."
      @supervisor = fork_supervisor
      trap_signals
      Sponges.logger.info "Supervisor started with #{@supervisor} pid."
      Process.waitpid(@supervisor) unless daemonize?
    end

    private

    def trap_signals
      Sponges::SIGNALS.each do |signal|
        trap(signal) {|signal| kill_supervisor(signal) }
      end
    end

    def kill_supervisor(signal)
      Process.kill :USR1, @supervisor
    end

    def default_options
      {
        size: Machine::Info::Cpu.cores_size
      }
    end

    def fork_supervisor
      fork do
        Supervisor.new(@name, @options, store, @block).start
      end
    end

    def daemonize?
      !!@options[:daemonize]
    end
  end
end
