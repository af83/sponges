#!/usr/bin/env ruby
# encoding: UTF-8

require_relative '../lib/sponges'

class SleepRunner
  def run
    sleep 1
    run
  end
end

Sponges.configure do |config|
  config.logger          = Logger.new('/dev/null')
end

Sponges.start '_sponges_sleep_test' do
  SleepRunner.new.run
end

