# encoding: utf-8
module Sponges
  # This class concern is to send messages to supervisor. It's used to send
  # messages like 'stop' or 'restart'
  #
  class Commander
    def initialize(name, options = {})
      @name, @options = name, options
      @redis = Nest.new('sponges', Configuration.redis || Redis.new)[Socket.gethostname]
    end

    def rest
      Sponges.logger.info "Runner #{@name} stop message received."
      if pid = @redis[:worker][@name][:supervisor].get
        begin
          Process.kill gracefully? ? :HUP : :QUIT, pid.to_i
          # TODO: wait for process kill. Since it's not its child, this process
          # can't wait for it.
          #
          # We'll have to use a different approach. A few ideas:
          #   * check process exitence with a Process.kill 0, pid.to_i in a
          #   loop.
          #   * use messaging, we have already Redis, so blpop could be a good
          #   fit here.
          #
        rescue Errno::ESRCH => e
          Sponges.logger.error e
        end
      else
        Sponges.logger.info "No supervisor found."
      end
    end

    private

    def gracefully?
      !!@options[:gracefully]
    end
  end
end
