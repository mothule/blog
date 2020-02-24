# frozen_string_literal: true

require 'jekyll'

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
      post_name = @markup
      post_file_name = post_name + '.md'
      is_draft = draft?(post_file_name: post_file_name)

      path = site.posts.docs
                 .select do |p|
                   if is_draft
                     p.cleaned_relative_path.gsub('_drafts/', '') == post_name
                   else
                     p.cleaned_relative_path[1..-1] == post_name
                   end
                 end
                 .map(&:url)
                 .first

      raise StandardError.new('指定パスにファイルなし') unless File.exist?(article_path(post_file_name: post_file_name))
      post_article = File.read(article_path(post_file_name: post_file_name))
      title = post_article.match(/title: (.*)/).captures.first
      image_path = post_article.match(/path: (.*)/)&.captures&.first
      if image_path.nil?
        image_path = '/assets/images/site-image.png'
        puts "アイキャッチ画像がありません。 #{post_file_name}"
      end

      post = Jekyll::Tags::PostComparer.new(post_name)
      begin_index = post_article[(post_article.index('---') + 3)..-1].index('---') + 6
      brief = post_article[begin_index..begin_index + 250]
              .gsub(/^## /, '')
              .gsub(/^### /, '')
              .gsub(/^#### /, '')
              .gsub(/{% .* %}/, '') + '...'
      <<~"HTML"
        <span><a href='#{path}'>#{@title || title}</a></span>
      HTML

      # tags = "<div class='link-container'>"
      # tags += "<a href='#{path}'>#{title}</a>"
      # tags += "<p>📅#{post.date}</p>"
      # tags += '</div>'
      # tags
    end

    private

    def draft?(post_file_name:)
      if File.exist?('./_posts/' + post_file_name)
        false
      elsif File.exist?('./_drafts/' + post_file_name)
        true
      else
        raise "Not found article. post_file_name: #{post_file_name}"
      end
    end

    def article_path(post_file_name:)
      if draft?(post_file_name: post_file_name)
        './_drafts/' + post_file_name
      else
        './_posts/' + post_file_name
      end
    end
  end
end

Liquid::Template.register_tag('post_link_text', Jekyll::PostLinkTextTag)
