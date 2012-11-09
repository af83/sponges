# encoding: utf-8
require 'boson/runner'
require 'socket'
require 'logger'
require 'nest'
require 'machine'
require_relative 'sponges/configuration'
require_relative 'sponges/supervisor'
require_relative 'sponges/runner'
require_relative 'sponges/commander'
require_relative 'sponges/cli'

module Sponges
  SIGNALS = [:INT, :QUIT, :TERM]

  def configure(&block)
    Sponges::Configuration.configure &block
  end
  module_function :configure

  def start(worker_name, options = {}, argv = ARGV, &block)
    Sponges::Configuration.worker_name = worker_name
    Sponges::Configuration.worker = block
    Sponges::Configuration.options = options
    Sponges::Cli.start(argv)
  end
  module_function :start

  def logger
    return @logger if @logger
    @logger = Sponges::Configuration.logger || Logger.new(STDOUT)
  end
  module_function :logger
end
