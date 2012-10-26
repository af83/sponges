# encoding: utf-8
module Sponges
  # This class concern is to build a worker instance, set some signals handlers
  # and make it start its job.
  #
  class WorkerBuilder
    def initialize(block)
      @block = block
    end

    def start
      trap_signals
      at_exit do
        Sponges.logger.info "Child exits."
      end
      @block.call
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
