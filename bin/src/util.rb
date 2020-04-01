#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'

# 指定パス内から次のファイル名を生成する
def next_image_file_name(target_directory_path:, extension_name: 'png')
  raise "Not found directory. path: #{target_directory_path}" unless Dir.exist?(target_directory_path)

  file_names = Dir.foreach(target_directory_path)

  no = 0
  loop do
    final_name = "#{no}.#{extension_name}"
    break final_name unless file_names.include?(final_name)

    no += 1
  end
end
