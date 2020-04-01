#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'
require 'csv'
require_relative 'src/article'
require 'yaml'

csv = CSV.open('./ws/_data/article_ranking.csv')

articles = Dir.glob('./ws/_posts/*.md').map do |path|
  Article.import_from(path: path)
end

articles_ranking = csv.map do |tupple|
  uri_name = tupple.first
  uri_path = tupple.first
  start = uri_name.rindex('/')
  uri_name = uri_name[start + 1..-1].chomp
  ret = articles.select { |article| article.uri_name == uri_name }
  raise 'Multiple articles ware hit' if ret.count > 1

  article = ret.first

  {
    'title' => "#{article.title}",
    'path' => uri_path,
    'count' => tupple.last
  }
end.flatten

puts articles_ranking
YAML.dump(articles_ranking, File.open('./ws/_data/article-ranking.yml', 'w'))
