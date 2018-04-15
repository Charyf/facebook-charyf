require 'charyf'

module Facebook
  class Interface < Charyf::Interface::Base

    module VERSION
      MAJOR = 0
      MINOR = 3
      TINY  = 0
      PRE   = nil

      STRING = [MAJOR, MINOR, TINY, PRE].compact.join(".")
    end

  end
end