# frozen_string_literal: true

module Jekyll
  module Drops
    JekyllDrop.class_eval do
      def build_environment
        ENV['BUILD_ENV'] || ''
      end
    end

    class JekyllDrop < Liquid::Drop
      def to_h
        @to_h ||= { 'version' => version,
                    'environment' => environment,
                    'build_environment' => build_environment }
      end
    end
  end
end
