# encoding: utf-8
class CpuInfo
  class << self
    def cores_size
      `grep -c processor /proc/cpuinfo`.to_i
    end
  end
end
