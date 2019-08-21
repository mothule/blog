# frozen_string_literal: true

require 'jekyll'

module Jekyll
  class PageImageTag < Liquid::Tag
    def initialize(tag_name, markup, token)
      super
      @markup = markup.strip
    end

    def render(context)
      basename = File.basename(context['page'].path, '.md')

      @image_name, @width = @markup.split(' ')
      @width = '100%' if @width.nil?

      image_path = "/assets/images/#{basename}#{@image_name}"
      "<a href=\"#{image_path}\"><img src=\"#{image_path}\" width=\"#{@width}\"></a>"
    end
  end
end

Liquid::Template.register_tag('page_image', Jekyll::PageImageTag)
