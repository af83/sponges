# encoding: utf-8
module Sponges
  class Response
    attr_reader :supervisor

    def initialize(supervisor)
      @supervisor = supervisor
    end

    def to_json
      as_json.to_json
    end

    def as_json(opts={})
      {
        supervisor: process_information(supervisor.pid),
        children: children_information
      }
    end

    private

    def process_information(pid)
      info = Machine::ProcessStatus.new(pid)
      {
        pid:         pid,
        pctcpu:      info.pctcpu,
        pctmem:      info.pctmem,
        created_at:  info.created_at

      }
    end

    def children_information
      supervisor.children_pids.map do |pid|
        process_information(pid)
      end
    end

  end
end

