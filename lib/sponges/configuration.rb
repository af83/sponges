# encoding: utf-8
module Sponges
  # This class concern is to provide a global object for configuration needs.
  #
  class Configuration
    class << self
      ACCESSOR = [:worker_name, :worker, :worker_method, :logger, :redis]
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
    end
  end
end
