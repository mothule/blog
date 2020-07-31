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

      separater = @markup.split(' ').count > 3 ? ',' : ' '
      @image_name, @width, @alt = @markup.split(separater).map(&:strip)
      @width = '100%' if @width.nil?

      image_path = find_image_path(basename, @image_name)
      "<a href=\"#{image_path}\"><img src=\"#{image_path}\" width=\"#{@width}\" alt=\"#{@alt}\"></a>"
    end

    private

    # 最初は /assets/images/YYYY-MM-DDフォルダの中に画像がないかを確認して、
    # なければ /assets/imagesフォルダの中に画像がないかを確認する。
    def find_image_path(basename, image_name)

      # /assets/images/hogehoge/0.png
      basename_without_date = basename[11..-1]
      path_in_directory_without_date = "/assets/images/#{basename_without_date}/#{image_name}"

      # /assets/images/yyyy-mm-dd-hogehoge/0.png
      path_in_directory = "/assets/images/#{basename}/#{image_name}"

      # /assets/images/yyyy-mm-dd-hogehoge/yyyy-mm-dd-hogehoge-0.png
      full_path_in_directory = "/assets/images/#{basename}/#{basename}#{image_name}"

      # /assets/images/yyyy-mm-dd-hogehoge-0.png
      image_path = "/assets/images/#{basename}#{image_name}"

      if File.exist?('.' + path_in_directory_without_date)
        path_in_directory_without_date
      elsif File.exist?('.' + path_in_directory)
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
