#!/usr/bin/env ruby
# frozen_string_literal: true

# require 'active_support/core_ext/hash'
require_relative 'src/all'
require 'erb'

sitemap_path = './ws/_site/sitemap.xml'

raise 'Not found sitemap.xml' unless File.exist?(sitemap_path)

xml = Hash.from_xml(File.open(sitemap_path))
xml['urlset']['url'].reject! do |url|
  url['loc'].match?(/page\d/)
end

url_info_list = xml['urlset']['url'].map do |url|
  { url: url['loc'], lastmod: url['lastmod'] }
end
template = File.read('./bin/src/sitemap.xml.erb')
erb = ERB.new(template, nil, '-')
string = erb.result(binding)
File.write(sitemap_path, string)
