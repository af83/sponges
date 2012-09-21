# encoding: utf-8
module Sponges
  class Runner
    def initialize(name, options = {})
      @options = default_options.merge options
      @pids = []
    end

    def work(worker, method, *args, &block)
      @options[:size].times do |index|
        @pids << fork_children(children_name(index), worker, method, *args, &block)
      end
      start!
      trap(:INT) { kill_master }
    end

    private

    def start!
      if daemonize?
        Process.daemon
      else
        Process.waitpid(fork_master) unless daemonize?
      end
    end

    def kill_all
      Process.kill :INT, @master
    end

    def children_name(index)
      "#{@name}_child_#{index}"
    end

    def default_options
      {
        size: CpuInfo.cores_size
      }
    end

    def fork_master
      @master = fork do
        $PROGRAM_NAME = "#{@name}_master"
        Master.new(@name, @pids).start
      end
    end

    def fork_children(name, worker, method, *args, &block)
      fork do
        $PROGRAM_NAME = name
        worker.send(method, *args, &block)
      end
    end

    def daemonize?
      !!@options[:daemonize]
    end
  end
end
