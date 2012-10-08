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
          Process.waitpid pid.to_i
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
