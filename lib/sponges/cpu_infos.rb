# encoding: utf-8
class CpuInfo
  # This class concern is to grab some informations about hardware.
  #
  class << self
    def cores_size
      `grep -c processor /proc/cpuinfo`.to_i
    end
  end
end
