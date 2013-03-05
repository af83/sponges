# encoding: utf-8
module Sponges
  class Supervisor
    extend Forwardable
    attr_reader :store, :name, :options, :handler, :listener
    def_delegator :@store, :supervisor_pid, :pid
    def_delegator :@store, :children_pids

    def initialize(name, options, store, block)
      @name, @options, @store, @block = name, options, store, block
      $PROGRAM_NAME = "#{@name}_supervisor"
      store.on_fork
      store.register Process.pid
      @children_seen = 0
      @handler = Handler.new self
      @listener = Listener.new(self)
    end

    def start
      handler.call
      trap_signals
      options[:size].times do
        handler.push :TTIN
      end
      Sponges.logger.info "Supervisor started, waiting for messages, listening on port #{Sponges::Configuration.port}"
      listener.call
    rescue SystemExit => exception
      raise exception
    rescue Exception => exception
      Sponges.logger.error exception
      handler.push :INT
      raise exception
    end

    def call
      @block.call
    end

    private

    def children_name
      "#{name}_child_#{@children_seen +=1}"
    end

    def trap_signals
      Sponges::SIGNALS.each do |signal|
        trap(signal) {|signal| handler.push signal }
      end
    end

  end
end
