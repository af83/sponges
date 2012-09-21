# encoding: utf-8
module Sponges
  class Master
    def initialize(name, pids)
      @name, @pids = name, pids
      trap(:INT) { kill_all }
    end

    def start
      sleep
    end

    private

    def kill_all
      @pids.each do |pid|
        Process.kill :INT, pid
        @pids.delete pid
      end
      Process.kill Process.pid
    end
  end
end
