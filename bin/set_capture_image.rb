#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'

default_extension = 'png'
default_temporary_directory = '/tmp/images/'
`mkdir -p #{default_temporary_directory}`

default_output_filename = Time.current.strftime('%F-%s')
output_file_name = ARGV[0] || "#{default_output_filename}.#{default_extension}"
temporary_path = default_temporary_directory + output_file_name


puts "Writing to file... #{temporary_path}"
`pngpaste #{temporary_path}`
raise 'Failed creation of a temporary image file via pngpaste.' unless File.exists? temporary_path

output_path = "./ws/assets/images/#{output_file_name}"

puts "Compressing image... #{output_path} from #{temporary_path}"
`ruby bin/compress_image #{temporary_path} #{output_path}`
