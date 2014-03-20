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
      press_sponges { Process.kill :TTIN, find_supervisor.pid }
      find_childs.size.should eq Machine::Info::Cpu.cores_size + 1
      press_sponges { Process.kill :TTOU, find_supervisor.pid }
      find_childs.size.should eq Machine::Info::Cpu.cores_size
    end
  end

  context 'stop' do
    it 'cannot kill a child' do
      childs = find_childs
      press_sponges { Process.kill :INT, childs.first.pid }
      find_childs.size.should eq Machine::Info::Cpu.cores_size
    end
  end

  context 'restart' do
    it 'can be restarted' do
      old_pid = find_supervisor.pid
      press_sponges { system('spec/worker_runner.rb restart') }
      old_pid.should_not eq find_supervisor.pid
      find_childs.size.should eq Machine::Info::Cpu.cores_size
    end
  end

  context 'increment' do
    before do
      press_sponges { system('spec/worker_runner.rb increment') }
    end

    it "increments worker pool by one" do
      find_childs.size.should eq Machine::Info::Cpu.cores_size + 1
    end

    it 'can be restarted' do
      old_pid = find_supervisor.pid
      press_sponges { system('spec/worker_runner.rb restart') }
      old_pid.should_not eq(find_supervisor.pid)
      find_childs.size.should eq Machine::Info::Cpu.cores_size
    end

    it "loves to be incremented" do
      press_sponges { 5.times { system('spec/worker_runner.rb increment') } }
      find_childs.size.should eq Machine::Info::Cpu.cores_size + 6
    end

    it "can be stopped, no matter the number of childs" do
      find_childs.size.should eq Machine::Info::Cpu.cores_size + 1
      system('spec/worker_runner.rb stop')
      find_supervisor.should be_nil
    end
  end

  context 'decrement' do
    before do
      press_sponges { system('spec/worker_runner.rb restart -d') }
      press_sponges { system('spec/worker_runner.rb decrement') }
    end

    it "increments worker pool by one" do
      find_childs.size.should eq(Machine::Info::Cpu.cores_size - 1)
    end
  end

  context "http supervision" do
    require "net/http"
    require "uri"

    before do
      press_sponges { system('spec/worker_runner.rb restart -d') }
    end

    let(:uri) { URI.parse("http://localhost:5032") }
    let(:response) { JSON.parse(Net::HTTP.get_response(uri).body) }

    it "should expose the supervisor_pid" do
      response["supervisor"]["pid"].should eq find_supervisor.pid
    end

    it "should expose the created_at" do
      response["supervisor"]["created_at"].should_not be_nil
    end

    it "should return a collection of children" do
      response["children"].size.should eq Machine::Info::Cpu.cores_size
    end

    it 'should exposes pids of children' do
      response["children"].first["pid"].should be_an Integer
    end
  end

  context "sigkill on supervisor" do
    it "should also shutdown children" do
      press_sponges { Process.kill "KILL", find_supervisor.pid }
      find_supervisor.should be_nil
      find_childs.size.should be_zero
    end
  end
end
