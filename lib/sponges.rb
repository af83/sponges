# encoding: utf-8
%w[boson/runner socket logger machine forwardable json].each do |lib|
  require lib
end
%w[version alive configuration worker handler response listener supervisor
   runner commander cli store].each do |lib|
    require_relative "sponges/#{lib}"
   end

module Sponges
  STOP_SIGNALS = [:INT, :QUIT, :TERM]
  SIGNALS = STOP_SIGNALS + [:HUP, :TTIN, :TTOU, :CHLD]

  module_function

  def configure(&block)
    Sponges::Configuration.configure &block
  end

  def start(worker_name, options = {}, argv = ARGV, &block)
    Sponges::Configuration.worker_name = worker_name
    Sponges::Configuration.worker = block
    Sponges::Cli.start(argv)
  end

  def logger
    return @logger if @logger
    @logger = Sponges::Configuration.logger || Logger.new(STDOUT)
  end

  def env
    Sponges::Configuration.env
  end
end
