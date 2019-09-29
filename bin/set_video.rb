#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'

default_src_path = "#{Dir.home}/Downloads/dest.mp4"

default_output_filename = Time.current.strftime('%F-%s')
default_dest_path = "./ws/assets/videos/#{default_output_filename}.mp4"

raise 'Not found video dest.mp4.' unless File.exist? default_src_path

FileUtils.mv(default_src_path, default_dest_path)

raise 'Failed move to dest directory.' unless File.exists? default_dest_path

puts "Successful move to #{default_dest_path}"