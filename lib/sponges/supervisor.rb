# encoding: utf-8
module Sponges
  class Supervisor
    attr_reader :store, :name, :options

    def initialize(name, options, store, block)
      @name, @options, @store, @block = name, options, store, block
      store.on_fork
      store.register Process.pid
      @children_seen = 0
    end

    def start
      options[:size].times do
        fork_children
      end
      trap_signals
      at_exit do
        Sponges.logger.info "Supervisor exits."
      end
      Sponges.logger.info "Supervisor started, waiting for messages."
      sleep
    rescue Exception => exception
      Sponges.logger.error exception
      kill_them_all(:INT)
      raise exception
    end

    private

    def fork_children
      name = children_name
      pid = fork do
        $PROGRAM_NAME = name
        Sponges::Hook.after_fork
        @block.call
      end
      Sponges.logger.info "Supervisor create a child with #{pid} pid."
      store.add_children pid
    end

    def children_name
      "#{name}_child_#{@children_seen +=1}"
    end

    def trap_signals
      (Sponges::SIGNALS + [:HUP]).each do |signal|
        trap(signal) do
          handle_signal signal
        end
      end
      trap(:TTIN) do
        Sponges.logger.warn "Supervisor increment child's pool by one."
        fork_children
      end
      trap(:TTOU) do
        Sponges.logger.warn "Supervisor decrement child's pool by one."
        if store.children_pids.first
          kill_one(store.children_pids.first, :HUP)
          store.delete_children(children_pids.first)
        else
          Sponges.logger.warn "No more child to kill."
        end
      end
      trap(:CHLD) do
        store.children_pids.each do |pid|
          begin
            dead = Process.waitpid(pid.to_i, Process::WNOHANG)
            if dead
              Sponges.logger.warn "Child #{dead} died. Restarting a new one..."
                store.delete_children dead
              Sponges::Hook.on_chld
              fork_children
            end
          rescue Errno::ECHILD => e
            # Don't panic
          end
        end
      end
    end

    def handle_signal(signal)
      Sponges.logger.info "Supervisor received #{signal} signal."
      kill_them_all(signal)
      Process.waitall
      Sponges.logger.info "Children shutdown complete."
      Sponges.logger.info "Supervisor shutdown. Exiting..."
      pid = store.supervisor_pid
      store.clear(name)
      Process.kill :USR1, pid.to_i
    end

    def kill_them_all(signal)
      store.children_pids.each do |pid|
        kill_one(pid.to_i, signal)
      end
    end

    def kill_one(pid, signal)
      begin
        Process.kill signal, pid
        Process.waitpid pid
        Sponges.logger.info "Child #{pid} receive a #{signal} signal."
      rescue Errno::ESRCH => e
        # Don't panic
      end
    end
  end
end
