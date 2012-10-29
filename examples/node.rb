# encoding: utf-8
require_relative '../lib/sponges'

Sponges.start "node" do
  pid = spawn "node -v"
  Process.waitpid pid
  sleep
end
