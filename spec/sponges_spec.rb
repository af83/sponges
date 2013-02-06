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
      sleep sleep_value
      find_childs.size.should eq Machine::Info::Cpu.cores_size + 1

      Process.kill :TTOU, find_supervisor.pid
      sleep sleep_value
      find_childs.size.should eq Machine::Info::Cpu.cores_size
    end
  end

  context 'stop' do
    it 'cannot kill a child' do
      childs = find_childs
      Process.kill :INT, childs.first.pid
      sleep sleep_value
      find_childs.size.should eq Machine::Info::Cpu.cores_size
    end
  end

  context 'restart' do
    it 'can be restarted' do
      old_pid = find_supervisor.pid
      system('spec/worker_runner.rb restart -d')
      sleep sleep_value
      old_pid.should_not eq find_supervisor.pid
    end
  end

  context 'increment' do
    before do
      system('spec/worker_runner.rb increment')
      sleep sleep_value
    end

    it "increments worker pool by one" do
      find_childs.size.should eq Machine::Info::Cpu.cores_size + 1
    end

    it 'can be restarted' do
      old_pid = find_supervisor.pid
      system('spec/worker_runner.rb restart -d')
      sleep sleep_value
      old_pid.should_not eq(find_supervisor.pid)
      find_childs.size.should eq Machine::Info::Cpu.cores_size
    end

    it "loves to be incremented" do
      5.times { system('spec/worker_runner.rb increment') }
      sleep sleep_value
      find_childs.size.should eq Machine::Info::Cpu.cores_size + 6
    end

    it "can be stopped, no matter the number of childs" do
      find_childs.size.should eq Machine::Info::Cpu.cores_size + 7
      old_pid = find_supervisor.pid
      system('spec/worker_runner.rb stop')
      find_supervisor.should be_nil
    end
  end

  context 'decrement' do
    before do
      system('spec/worker_runner.rb restart -d')
      sleep sleep_value
      system('spec/worker_runner.rb decrement')
      sleep sleep_value
    end

    it "increments worker pool by one" do
      find_childs.size.should eq(Machine::Info::Cpu.cores_size - 1)
    end
  end
end
