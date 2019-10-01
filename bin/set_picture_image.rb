#!/usr/bin/env ruby

require 'bundler/setup'
require 'active_support/all'

default_extension = 'png'
default_temporary_directory = '/tmp/images/'
`mkdir -p #{default_temporary_directory}`

default_output_filename = Time.current.strftime('%F-%s')
output_file_name = ARGV[0] || "#{default_output_filename}.#{default_extension}"
default_input_path = Dir.glob("#{Dir.home}/Pictures/*.png").max_by { |f| File.ctime(f) }
puts default_input_path
temporary_path = default_input_path

raise 'Not found image file in user pictures directory.' unless File.exists? default_input_path

output_path = "./ws/assets/images/#{output_file_name}"

puts "Compressing image... #{output_path} from #{temporary_path}"
`ruby bin/compress_image "#{temporary_path}" "#{output_path}"`

