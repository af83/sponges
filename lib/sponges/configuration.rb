# encoding: utf-8
module Sponges
  # This class concern is to provide a global object for configuration needs.
  #
  class Configuration
    class << self
      ACCESSOR = [:worker_name, :worker, :logger, :redis, :size,
        :daemonize, :after_fork
      ]
      attr_accessor *ACCESSOR

      def configure
        yield self
      end

      def configuration
        ACCESSOR.inject({}) do |conf, method|
          conf[method] = send(method)
          conf
        end
      end

      def after_fork(&block)
        Hook._after_fork = block
      end
    end
  end

  class Hook
    class << self
      attr_accessor :_after_fork

      def after_fork
        _after_fork.call if _after_fork.respond_to?(:call)
      end
    end
  end
end
