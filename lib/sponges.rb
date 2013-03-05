# encoding: utf-8
require 'boson/runner'
require 'socket'
require 'logger'
require 'machine'
require 'forwardable'
require 'socket'
require 'json'
require_relative 'sponges/version'
require_relative 'sponges/configuration'
require_relative 'sponges/handler'
require_relative 'sponges/response'
require_relative 'sponges/listener'
require_relative 'sponges/supervisor'
require_relative 'sponges/runner'
require_relative 'sponges/commander'
require_relative 'sponges/cli'
require_relative 'sponges/store'
require_relative 'sponges/store/memory'
require_relative 'sponges/store/redis'

module Sponges
  STOP_SIGNALS = [:INT, :QUIT, :TERM]
  SIGNALS = STOP_SIGNALS + [:HUP, :TTIN, :TTOU, :CHLD]

  def configure(&block)
    Sponges::Configuration.configure &block
  end
  module_function :configure

  def start(worker_name, options = {}, argv = ARGV, &block)
    Sponges::Configuration.worker_name = worker_name
    Sponges::Configuration.worker = block
    Sponges::Cli.start(argv)
  end
  module_function :start

  def logger
    return @logger if @logger
    @logger = Sponges::Configuration.logger || Logger.new(STDOUT)
  end
  module_function :logger
end
