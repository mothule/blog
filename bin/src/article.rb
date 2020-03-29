# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'

class Article
  attr_accessor :title
  attr_accessor :categories
  attr_accessor :tags
  attr_accessor :published_at

  class << self
    def imports_all(contain_drafts: true)
      article_paths = Array.wrap(Dir.glob('./ws/_posts/*.md'))
      article_paths += Array.wrap(Dir.glob('./ws/_drafts/*.md')) if contain_drafts

      articles = article_paths.map { |path| import_from(path: path) }
                              .sort_by(&:published_at)

      articles
    end

    def import_from(path:)
      raise "Not found path. path:#{path}" unless File.exist?(path)

      text = File.read(path)
      title = text.match(/title: (.*)/)&.captures&.first || 'untitled'
      categories = text.match(/categories: (.*)/)&.captures&.first&.split(' ') || []
      tags = text.match(/tags: (.*)/)&.captures&.first&.split(' ') || []

      published_at = if path.include?('_drafts')
                       'no publish'
                     else
                       File.basename(path).match(/(\d{4}-\d{2}-\d{2})/)&.captures&.first
                     end

      Article.new(title: title, categories: categories, tags: tags, published_at: published_at)
    end

    def report(articles:)
      categories_width = max_length_categories(articles: articles)

      articles.each do |article|
        puts article.to_s(categories_width: categories_width)
      end
    end

    def max_length_categories(articles:)
      articles.map(&:categories).map { |c| c.join(' ') }.map(&:length).max
    end
  end

  def initialize(title:, categories:, tags:, published_at:)
    @title = title
    @categories = categories
    @tags = tags
    @published_at = published_at
  end

  def to_s(categories_width:)
    "#{date_with(width: 10)} | #{title_with(width: 32)} |  #{categories.join(' ').ljust(categories_width, ' ').green} | #{tags.join(' ').magenta}"
  end

  private

  def date_with(width:)
    @published_at[0..width]
  end

  def title_with(width:)
    t = title[0..width]
    len = t.length + t.chars.reject(&:ascii_only?).length

    wide_width = 2 + width * 2

    space = ''
    space = ' ' * (wide_width - len) if wide_width - len > 0
    t + space
  end
end
