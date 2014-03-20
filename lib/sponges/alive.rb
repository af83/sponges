# encoding: utf-8
module Sponges
  module Alive
    # Check processus presence by its pid.
    #
    # @param [Integer] pid
    #
    # @return [Boolean]
    #
    def alive?(pid)
      !Sys::ProcTable.ps.find {|f| f.pid == pid }.nil?
    rescue SystemCallError
      false
    end
    private :alive?
  end
end
