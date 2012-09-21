# encoding: utf-8
module Sponges
  class Master
    def initialize(name, options, worker, method, *args, &block)
      @name, @options = name, options
      @worker, @method, @args, @block = worker, method, args, block
      @pids = []
      trap_signals
    end

    def start
      @options[:size].times do |index|
        @pids << fork_children(children_name(index))
      end
      sleep
    end

    private

    def children_name(index)
      "#{@name}_child_#{index}"
    end

    def fork_children(name)
      fork do
        $PROGRAM_NAME = name
        @worker.send(@method, *@args, &@block)
      end
    end

    def trap_signals
      Sponges::SIGNALS.each do |signal|
        trap(signal) do
          kill_all(signal)
          Process.kill :TERM, Process.pid
        end
      end
    end

    def kill_all(signal)
      @pids.each do |pid|
        begin
          Process.kill signal, pid
        rescue Errno::ESRCH
        end
      end
    end
  end
end
