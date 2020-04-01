#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'src/article'
require 'colorator'
require 'yaml'

unnamed_tags = []
named_tags = YAML.load_file('./ws/_data/tag-names.yml')['tags']
contain_drafts = (ARGV.first || 'true') == 'true'
articles = Article.imports_all(contain_drafts: contain_drafts)
articles.flat_map(&:tags).uniq.sort.each do |tag|
  named_tag = named_tags[tag]
  unnamed_tags << tag if named_tag.nil?
  puts "#{tag}: #{named_tag}"
end

if unnamed_tags.count > 0
  puts '------------------------'
  puts 'Some tags have no names.'
  unnamed_tags.each do |unnamed_tag|
    puts unnamed_tag.red
  end
  exit!(1)
end

exit!(0)
