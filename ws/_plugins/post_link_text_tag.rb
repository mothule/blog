# frozen_string_literal: true

require 'jekyll'
require_relative 'shared/article'

# Usage:
# {% post_link_text markdown-file-name %}
module Jekyll
  class PostLinkTextTag < Liquid::Tag
    def initialize(tag_name, markup, token)
      super
      @markup, @title = markup.strip.split(' ')
    end

    def render(context)
      site = context.registers[:site]
      ::Article.imports_all(site: site)
      post_name = @markup

      article = Article.find_by(basename_without_date: post_name)
      article = Article.find_by(basename_without_ext: post_name) if article.nil?
      raise StandardError, '指定パスにファイルなし' if article.nil?

      path = article.url_path
      title = article.title
      <<~"HTML"
        <span><a href='#{path}'>#{@title || title}</a></span>
      HTML
    end
  end
end

Liquid::Template.register_tag('post_link_text', Jekyll::PostLinkTextTag)
