# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'

Dir["#{File.dirname(__FILE__)}/**/*.rb"].each do |path|
  require path
end
