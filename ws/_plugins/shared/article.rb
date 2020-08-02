# frozen_string_literal: true

require 'jekyll'

class Article
  attr_reader :title
  attr_reader :path
  attr_reader :relative_path
  attr_reader :url_path
  attr_reader :basename
  attr_reader :basename_without_ext
  attr_reader :basename_wihtout_date
  attr_reader :extname
  attr_reader :content
  attr_reader :html
  attr_reader :categories
  attr_reader :eyecatch_image_path
  attr_reader :tags
  attr_reader :date
  attr_reader :excerpt
  attr_reader :excerpt_without_tag

  def initialize(document:)
    @title = document.data['title']
    @path = document.path
    @extname = document.extname
    @basename = document.basename
    @basename_without_ext = document.basename_without_ext
    @basename_without_date = @basename_without_ext[11..-1]
    @content = document.content
    @html = document.output
    @relative_path = document.relative_path
    @url_path = document.url
    @is_draft = document.data['draft']
    @categories = document.data['categories']
    @eyecatch_image_path = document.data['image']['path']
    @tags = document.data['tags']
    @date = document.date
    @excerpt = document.data['excerpt'].content
    @excerpt_without_tag = @excerpt.gsub(/<\/?[^>]*>/, '')
  end

  def draft?
    is_draft
  end

  class << self
    @@hashed_value = 0

    def imports_all(site:)
      hashed_value = site.posts.docs.map { |doc| File.mtime(doc.path).to_i }.sum
      if @@hashed_value != hashed_value
        puts "previous hashed_value: #{@@hashed_value}, new hashed_value: #{hashed_value}"
        @@articles = nil
        puts 'Clear cached articles'
      end
      @@hashed_value = hashed_value

      @@articles ||= site.posts.docs.map do |document|
        Article.new(document: document)
      end
    end

    def find_by(hash)
      raise ArgumentError, 'Hashで指定すること' unless hash.is_a? Hash

      articles = @@articles.dup
      hash.each do |key, value|
        articles = articles.select { |article| article.instance_variable_get("@#{key}") == value }
      end
      articles.first
    end
  end
end
