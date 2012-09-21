# encoding: utf-8
module Sponges
  class WorkerBuilder
    def initialize(worker, method, *args, &block)
      @worker, @method, @args, @block = worker, method, args, block
    end

    def start
      trap_signals
      @worker.send(@method, *@args, &@block)
    end

    private

    def trap_signals
      Sponges::SIGNALS.each do |signal|
        trap(signal) do
          exit 0
        end
      end
    end
  end
end
