# frozen_string_literal: true

require 'jekyll'

module Jekyll
  class TagLabelTag < Liquid::Tag
    def initialize(tag_name, markup, token)
      super
      @tag_label = markup.strip
    end

    def render(context)
      named_tags = YAML.load_file('./_data/tag-names.yml')['tags']
      named_tags[context[@tag_label]]
    end
  end
end

Liquid::Template.register_tag('tag_label', Jekyll::TagLabelTag)
