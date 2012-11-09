#!/usr/bin/env ruby
# encoding: UTF-8

require 'sponges'

class Worker
  def run
    sleep 1
    run
  end
end

Sponges.configure do |config|
  config.logger        = Logger.new('/dev/null')
end

Sponges.start '_sponges_test' do
  Worker.new.run
end
