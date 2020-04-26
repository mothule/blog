# frozen_string_literal: true

require 'jekyll'
require_relative 'shared/article'

# Usage:
# {% post_link markdown-file-name %}
module Jekyll
  class PostLinkTag < Liquid::Tag
    def initialize(tag_name, markup, token)
      super
      @markup = markup.strip
    end

    def render(context)
      site = context.registers[:site]
      ::Article.imports_all(site: site)
      post_name = @markup
      article = Article.find_by(basename_without_ext: post_name)
      raise StandardError.new('指定パスにファイルなし') if article.nil?
      path = article.url_path
      title = article.title
      image_path = article.eyecatch_image_path
      if image_path.nil?
        image_path = '/assets/images/site-image.png'
        puts "アイキャッチ画像がありません。 #{article.basename}"
      end

      brief = article.excerpt_without_tag
      <<~"HTML"
        <div class='link-container'>
          <a href='#{path}'>
            <div class='link-container-image'>
              <img src='#{image_path}'>
            </div>
            <div class='link-container-summary'>
              <div class='link-container-summary-title'>
                <span>#{title}</span>
              </div>
              <div class='link-container-summary-brief'>
                <span>#{brief}</span>
              </div>
            </div>
          </a>
        </div>
      HTML
    end
  end
end

Liquid::Template.register_tag('post_link', Jekyll::PostLinkTag)
