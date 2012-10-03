# encoding: utf-8
require 'boson/runner'
require 'socket'
require 'logger'
require 'nest'
require_relative 'sponges/configuration'
require_relative 'sponges/cpu_infos'
require_relative 'sponges/worker_builder'
require_relative 'sponges/supervisor'
require_relative 'sponges/runner'
require_relative 'sponges/cli'

module Sponges
  SIGNALS = [:INT, :QUIT, :TERM]

  def configure(&block)
    Sponges::Configuration.configure &block
  end
  module_function :configure

  def start(options = ARGV)
    Sponges::Cli.start(options)
  end
  module_function :start

  def logger
    return @logger if @logger
    @logger = Sponges::Configuration.logger || Logger.new(STDOUT)
  end
  module_function :logger
end
