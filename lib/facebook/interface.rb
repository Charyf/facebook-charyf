require 'charyf'

require_relative 'interface/interface'

module Facebook
  module Interface
    class Extension < Charyf::Extension

      generators do
        require_relative 'interface/generators/install/install_generator'
      end

      configure do
        config.port = 30000
        config.host = '0.0.0.0'
      end

    end


    # Provide config on FacebookCharyf module
    class << self
      def config
        Extension.config
      end
    end

  end
end