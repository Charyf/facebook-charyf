require 'charyf'

require_relative 'facebook/interface'

module Facebook
  class Extension < Charyf::Extension

    generators do
      require_relative 'facebook/generators/install/install_generator'
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

    def configure(&block)
      Extension.configure(&block)
    end
  end
end