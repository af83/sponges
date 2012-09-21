# encoding: utf-8
module Sponges
  class Runner
    def initialize(name, options = {})
      @name = name
      @options = default_options.merge options
    end

    def work(worker, method, *args, &block)
      trap_signals
      master_pid = fork_master(worker, method, *args, &block)
      if daemonize?
        Process.daemon
      else
        Process.waitpid(master_pid) unless daemonize?
      end
    end

    private

    def trap_signals
      Sponges::SIGNALS.each do |signal|
        trap(signal) { kill_master }
      end
    end

    def kill_master
      Process.kill :INT, @master
    end

    def default_options
      {
        size: CpuInfo.cores_size
      }
    end

    def fork_master(worker, method, *args, &block)
      @master = fork do
        $PROGRAM_NAME = "#{@name}_master"
        Master.new(@name, @options, worker, method, *args, &block).start
      end
    end

    def daemonize?
      !!@options[:daemonize]
    end
  end
end
