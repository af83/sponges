# encoding: utf-8
class CpuInfo
  class << self
    def cores_size
      File.read("/proc/cpuinfo").scan(/core id\s+: \d+/).uniq.size
    end
  end
end
