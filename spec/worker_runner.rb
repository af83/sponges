#!/usr/bin/env ruby
# encoding: UTF-8

require_relative '../lib/sponges'

class Worker
  def run
    sleep 1
    run
  end
end

Sponges.configure do |config|
  config.logger           = Logger.new('spec.log')
  config.polling          = 1
  config.env              = :test
end

Sponges.start '_sponges_test' do
  Worker.new.run
end
