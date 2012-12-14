# encoding: utf-8
module Sponges
  class Store
    class << self
      def new(name)
        case Sponges::Configuration.store
        when :memory
          Sponges::Store::Memory.new(name)
        when :redis
          Sponges::Store::Redis.new(name)
        end
      end
    end
  end
end
