require 'charyf/utils/generator/base'

module Facebook
  module Generators
    class InstallGenerator < ::Charyf::Generators::Base

      source_root File.expand_path('templates', __dir__)

      def initializer
        template 'config/initializers/facebook.rb.tt'
      end

      def finalize
        return unless behavior == :invoke

        say_status 'notice', "Wit installed" +
            "\n\t\tDo not forget to set adapt intent processor in application configuration" +
            "\n\t\t\tconfig.enabled_intent_processors = [.., :wit, ..]", :green
      end

    end
  end
end
