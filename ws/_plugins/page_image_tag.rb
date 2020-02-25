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

      @image_name, @width, @alt = @markup.split(' ')
      @width = '100%' if @width.nil?

      image_path = find_image_path(basename, @image_name)
      "<a href=\"#{image_path}\"><img src=\"#{image_path}\" width=\"#{@width}\" alt=\"#{@alt}\"></a>"
    end

    private

    # 最初は /assets/images/YYYY-MM-DDフォルダの中に画像がないかを確認して、
    # なければ /assets/imagesフォルダの中に画像がないかを確認する。
    def find_image_path(basename, image_name)

      path_in_directory = "/assets/images/#{basename}/#{image_name}"
      full_path_in_directory = "/assets/images/#{basename}/#{basename}#{image_name}"
      image_path = "/assets/images/#{basename}#{image_name}"

      if File.exist?('.' + path_in_directory)
        path_in_directory
      elsif File.exist?('.' + full_path_in_directory)
        full_path_in_directory
      elsif File.exist?('.' + image_path)
        image_path
      else
        raise "Not found image path. #{basename}#{image_name}"
      end
    end
  end
end

Liquid::Template.register_tag('page_image', Jekyll::PageImageTag)
