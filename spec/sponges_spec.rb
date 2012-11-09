# encoding: UTF-8

require 'spec_helper'

describe Sponges do
  context 'start' do
    it 'can be started' do
      find_supervisor.cmdline.should eq(supervisor_name)
    end

    it 'have childs' do
      find_childs.size.should eq Machine::Info::Cpu.cores_size
    end

    it 'can increase and decrease childs size' do
      Process.kill :TTIN, find_supervisor.pid
      sleep 1.2
      find_childs.size.should eq(Machine::Info::Cpu.cores_size + 1)

      Process.kill :TTOU, find_supervisor.pid
      sleep 1.2
      find_childs.size.should eq(Machine::Info::Cpu.cores_size)
    end
  end

  context 'stop' do
    it 'cannot kill a child' do
      childs = find_childs
      Process.kill :INT, childs.first.pid
      sleep 2
      find_childs.size.should eq(Machine::Info::Cpu.cores_size)
    end
  end

  context 'restart' do
    it 'can be restarted' do
      old_pid = find_supervisor.pid
      system('spec/worker_runner.rb restart -d')
      sleep 1
      old_pid.should_not eq(find_supervisor.pid)
    end
  end
end
