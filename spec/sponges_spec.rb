# encoding: UTF-8

require 'spec_helper'


describe Sponges do
  context 'configuration' do
    it 'worker_name' do
      Sponges::Configuration.worker_name.should eq(Worker.name)
    end
    it 'worker_method' do
      Sponges::Configuration.worker_method.should eq(:run)
    end
  end

  context 'start' do

    before do
      kill_supervisor
    end

    it 'can be started and killed' do
      fork {
        Sponges.start(['start'])
      }
      sleep 1
      find_supervisor.cmdline.should eq(supervisor_name)
    end
  end
end

