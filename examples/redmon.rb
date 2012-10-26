#!/usr/bin/env ruby
# encoding: UTF-8
require 'sponges'
require 'redmon'
require 'uri'

redis_server           = ENV['REDIS_SERVER'] || 'redis://localhost:6379'
redis_connection_info  = URI.parse(redis_server)

Sponges.configure do |config|
  config.logger        = Logger.new('log/redmon.log')
  config.redis         = Redis.new(host: redis_connection_info.host,
                                   port: redis_connection_info.port)
end

Sponges.start "redmon" do
  Redmon.run {:redis_url => redis_server, :app => false, :worker => true}
end
