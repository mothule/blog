# frozen_string_literal: true

require 'jekyll'

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
      post_name = @markup
      post_file_name = post_name + '.md'

      path = site.posts.docs
                 .select { |p| p.cleaned_relative_path[1..-1] == post_name }
                 .map(&:url)
                 .first

      post_article = File.read('./_posts/' + post_file_name)
      title = post_article.match(/title: (.*)/).captures.first
      image_path = post_article.match(/path: (.*)/).captures.first

      post = Jekyll::Tags::PostComparer.new(post_name)
      begin_index = post_article[0..-1].rindex('---') + 3
      brief = post_article[begin_index..begin_index + 250]
              .gsub(/^## /, '')
              .gsub(/^### /, '')
              .gsub(/^#### /, '')
              .gsub(/{% .* %}/, '') + '...'
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

      # tags = "<div class='link-container'>"
      # tags += "<a href='#{path}'>#{title}</a>"
      # tags += "<p>📅#{post.date}</p>"
      # tags += '</div>'
      # tags
    end
  end
end

Liquid::Template.register_tag('post_link', Jekyll::PostLinkTag)
