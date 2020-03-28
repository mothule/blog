#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'

def main
  default_extension = 'png'
  default_temporary_directory = '/tmp/images/'
  default_output_base_path = './ws/assets/images/'

  # prepare temporary directory
  `mkdir -p #{default_temporary_directory}`

  default_output_filename = Time.current.strftime('%F-%s')
  output_file_name = "#{default_output_filename}.#{default_extension}"
  temporary_path = default_temporary_directory + output_file_name

  case ARGV.count
  when 0 then
    raise 'Need text to argument 1'
    exit(1)
  when 1 then
    render_text = ARGV[0]
    output_directory_name = nil
  else
    render_text = ARGV[0]
    output_directory_name = ARGV[1]
  end

  output_path = prepare_output(
    output_directory_name: output_directory_name,
    output_base_path: default_output_base_path,
    default_output_file_name: default_output_filename,
    default_extension: default_extension
  )

  # Create PNG image via kiji to temp directory.
  puts "Writing to file... #{temporary_path}"
  `cd ~/workspace/ruby/kiji && rbenv exec bundle exec ruby main.rb -l "#{render_text}" -o #{temporary_path}`
  raise 'Failed creation of a temporary image file via kiji.' unless File.exist? temporary_path

  # Compress PNG image
  puts "Compressing image... #{output_path} from #{temporary_path}"
  `ruby bin/compress_image #{temporary_path} #{output_path}`
end

def prepare_output(output_directory_name:, output_base_path:, default_output_file_name:, default_extension:)
  return "#{output_base_path}#{default_output_file_name}" if output_directory_name.nil?

  # Prepare directory
  Dir.mkdir(output_base_path + output_directory_name) unless Dir.exist?(output_base_path + output_directory_name)

  # Resolve file name
  final_name = ''
  names = Dir.foreach(output_base_path + output_directory_name)
  no = 0
  loop do
    final_name = "#{no}.#{default_extension}"
    break unless names.include?(final_name)

    no += 1
  end

  # Final output path
  output_base_path + output_directory_name + '/' + final_name
end

main
