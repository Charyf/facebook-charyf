require 'charyf/utils/generator/base'

module Facebook
  module Interface
    module Generators
      class InstallGenerator < ::Charyf::Generators::Base

        source_root File.expand_path('templates', __dir__)

        def initializer
          template 'config/initializers/facebook.rb.tt'
        end

        def finalize
          return unless behavior == :invoke

          say_status 'notice', "Facebook interface installed" +
              "\n\t\tDo not forget to enable facebook interface in application configuration" +
              "\n\t\t\tconfig.enabled_interfaces = [.., :facebook, ..]", :green
        end

      end
    end
  end
end