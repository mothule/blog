#!/usr/bin/env ruby
# frozen_string_literal: true

# require 'bundler/setup'
# require 'active_support/all'
require_relative 'src/all'
require 'open3'

info 'Run', File.expand_path(__FILE__.to_s)

DEFAULT_EXTENSION = 'png'
DEFAULT_TEMPORARY_DIRECTORY = '/tmp/images/'
OUTPUT_BASE_DIRECTORY = './ws/assets/images'

module Status
  OK = 0
  NOT_FOUND_DIRECTORY = 1
  FAILED_MKDIR_P = 2
  FAILED_PNGPASTE = 3
  EXIST_FILE_ALREADY = 4
  FAILED_COMPORESS = 5
  UNKNOWN = 99
end

output_directory_path = nil
output_filename = Time.current.strftime('%F-%s')
case ARGV.count
when 1 then output_directory_path = ARGV[0]
when 2 then output_directory_path, output_filename = *ARGV[0..1]
end

# Sanitize
output_directory_path = File.join(OUTPUT_BASE_DIRECTORY, output_directory_path.presence || '')
if output_filename.exclude?(DEFAULT_EXTENSION)
  output_filename = output_filename + ".#{DEFAULT_EXTENSION}"
end

log 'Validation arguments'
unless Dir.exist?(output_directory_path)
  error "Not found directory at #{output_directory_path}"
  exit Status::NOT_FOUND_DIRECTORY
end

# stdout, stderr, status = Open3.capture3("mkdir -p #{DEFAULT_TEMPORARY_DIRECTORY}")
# unless status.success?
if FileUtils.mkdir_p(DEFAULT_TEMPORARY_DIRECTORY).empty?
  error(stderr)
  exit Status::FAILED_MKDIR_P
end

temporary_path = File.join(DEFAULT_TEMPORARY_DIRECTORY, output_filename)
log "Writing to file at #{temporary_path}"

stdout, stderr, status = Open3.capture3("pngpaste #{temporary_path}")
unless status.success?
  error stderr
  exit Status::FAILED_PNGPASTE
end
unless File.exist? temporary_path
  error "Not found file at #{temporary_path}"
  exit Status::UNKNOWN
end

output_path = File.join(output_directory_path, output_filename)

if File.exist?(output_path)
  error 'The specified path is existing already'
  exit Status::EXIST_FILE_ALREADY
end

log "Compressing image to #{output_path} from #{temporary_path}"
stdout, stderr, status = Open3.capture3("ruby bin/compress_image #{temporary_path} #{output_path}")
unless status.success?
  error stderr
  exit  Status::FAILED_COMPORESS
end

success('Successful', output_path)
exit Status::OK
