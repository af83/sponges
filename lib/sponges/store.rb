# encoding: utf-8
module Sponges
  class Store
    extend Forwardable

    attr_writer :supervisor_pid
    attr_reader :pids, :name

    def initialize(name)
      @pids, @name = [], name
    end

    def_delegator :@pids, :<<, :add_children
    def_delegator :@pids, :delete, :delete_children

    def supervisor_pid
      return @supervisor_pid if @supervisor_pid
      s = find_supervisor
      @supervisor_pid = s.pid if s
    end

    def children_pids
      @pids.any? ? @pids : find_childs.map(&:pid)
    end

    def running?
      !!find_supervisor
    end

    def register(supervisor_pid)
      @supervisor_pid = supervisor_pid
    end

    def clear(name)
      pids.clear
    end

    private

    def supervisor_name
      "#{name}_supervisor"
    end

    def childs_name
      "#{name}_child"
    end

    def find_supervisor
      Sys::ProcTable.ps.select {|f| f.cmdline == supervisor_name }.first
    end

    def find_childs
      Sys::ProcTable.ps.select {|f| f.cmdline =~ /^#{childs_name}/ }
    end
  end
end
