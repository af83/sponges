# encoding: utf-8
module Sponges
  # This class helps building new workers.
  #
  class Worker
    include Sponges::Alive
    attr_reader :supervisor, :name

    # Initialize an Worker with a supervisor and its future name
    #
    #
    # @param [Sponges::Supervisor] supervisor
    # @param [String] name
    #
    # @return [undefined]
    #
    def initialize(supervisor, name)
      @supervisor, @name = supervisor, name
    end

    # Forks a brandly new worker.
    #
    # @return [Integer] Pid of the new worker
    #
    def call
      fork do
        $PROGRAM_NAME = name
        (Sponges::STOP_SIGNALS + [:HUP]).each { |sig| trap(sig) { exit!(0) } }
        trap_supervisor_sigkill!
        Sponges::Hook.after_fork
        supervisor.call
      end
    end

    private

    def trap_supervisor_sigkill!
      Thread.new do
        while alive?(supervisor.pid) do
          Sponges.logger.debug Configuration.polling
          sleep Configuration.polling
        end
        exit
      end
    end
  end
end
