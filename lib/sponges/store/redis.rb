# encoding: utf-8
module Sponges
  class Store
    class Redis
      attr_reader :redis, :hostname_store, :name
      private     :redis, :hostname_store

      def initialize(name)
        @name = name
        @redis ||= Nest.new('sponges', Configuration.redis)
        @hostname_store = @redis[Socket.gethostname]
      end

      def supervisor_pid
        hostname_store[:worker][name][:supervisor].get
      end

      def children_pids
        Array(hostname_store[:worker][name][:pids].smembers)
      end

      def running?
        if pid = hostname_store[:worker][name][:supervisor].get
          begin
            Process.kill 0, pid.to_i
            true
          rescue Errno::ESRCH => e
            hostname_store[:worker][name][:supervisor].del
            false
          end
        else
          false
        end
      end

      def register_hostname(hostname)
        redis[:hostnames].sadd hostname
      end

      def register(supervisor_pid)
        hostname_store[:workers].sadd name
        hostname_store[:worker][name][:supervisor].set supervisor_pid
      end

      def add_children(pid)
        hostname_store[:worker][name][:pids].sadd pid
      end

      def delete_children(pid)
        hostname_store[:worker][name][:pids].srem pid
      end

      def clear(name)
        hostname_store[:worker][name][:supervisor].del
        hostname_store[:workers].srem name
        hostname_store[:worker][name][:pids].del
      end

      def on_fork
        Sponges::Configuration.redis.client.reconnect
      end

      private

      def find_supervisor
        Sys::ProcTable.ps.select {|f| f.cmdline == supervisor_name }.first
      end

      def find_childs
        Sys::ProcTable.ps.select {|f| f.cmdline =~ /^#{childs_name}/ }
      end
    end
  end
end

