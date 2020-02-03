#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'

default_extension = 'png'
default_temporary_directory = '/tmp/images/'

# prepare temporary directory
`mkdir -p #{default_temporary_directory}`

default_output_filename = Time.current.strftime('%F-%s')
output_file_name = "#{default_output_filename}.#{default_extension}"
temporary_path = default_temporary_directory + output_file_name

# Create PNG image via kiji to temp directory.
puts "Writing to file... #{temporary_path}"
`cd ~/workspace/ruby/kiji && rbenv exec bundle exec ruby main.rb -l "#{ARGV[0]}" -o #{temporary_path}`
raise 'Failed creation of a temporary image file via kiji.' unless File.exists? temporary_path


# Compress PNG image
output_path = "./ws/assets/images/#{output_file_name}"
puts "Compressing image... #{output_path} from #{temporary_path}"
`ruby bin/compress_image #{temporary_path} #{output_path}`
