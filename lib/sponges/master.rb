# encoding: utf-8
module Sponges
  class Master
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

    def children_name
      "#{@name}_child_#{@children_seen +=1}"
    end

    def fork_children
      name = children_name
      pid = fork do
        $PROGRAM_NAME = name
        @worker.send(@method, *@args, &@block)
      end
      @pids << pid
    end

    def trap_signals
      Sponges::SIGNALS.each do |signal|
        trap(signal) do
          kill_them_all(signal)
          Process.kill :USR1, Process.pid
        end
      end
    end

    def kill_them_all(signal)
      @pids.each do |pid|
        begin
          Process.kill signal, pid
        rescue Errno::ESRCH
        end
      end
    end
  end
end
