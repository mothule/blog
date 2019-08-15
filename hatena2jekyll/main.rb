require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
require 'reverse_markdown'


p "start"

class Article
  attr_accessor :author,
                :title,
                :basename,
                :status,
                :allow_comments,
                :convert_breaks,
                :date,
                :categories,
                :image,
                :body,
                :comments


  def parse(line)

    if @block_in
      if line =~ /^-----$/i
        block_line # end block
      elsif line =~ /body:/i
        @body_block = true
      else

        append_block_buffer(line)
      end

    else

      case line
      when /author: (.*)/i then self.author = $1
      when /title: (.*)/i then self.title = $1
      when /basename: (.*)/i then self.basename = $1
      when /status: (.*)/i then self.status = $1
      when /allow comments: (.*)/i then self.allow_comments = $1
      when /convert breaks: (.*)/i then self.convert_breaks = $1
      when /date: (.*)/i then self.date = DateTime.strptime($1, "%m/%d/%Y %H:%M:%s")
      when /image: (.*)/i then self.image = $1
      when /category: (.*)/i then append_category($1)
      when /^-----$/i then block_line # begin block
      when /^--------$/ then return true
      end
    end

    return false
  end

  def to_s
    "#{date} #{author} #{categories.first} #{title} #{basename} #{status} #{allow_comments} #{convert_breaks} #{image} #{body}"
  end

  def file_name
    "#{date.strftime('%Y-%m-%d')}-#{basename.gsub('/', '-')}.md"
  end

  private

  def append_category(category)
    self.categories = [] if self.categories.nil?
    self.categories << category
  end

  def block_line
    if @block_in
      @block_in = false

      if @body_block
        self.body = @block_buffer.join("\n")
        @body_block = false
      end

      @block_buffer = nil

    else
      @block_in = true

    end
  end

  def append_block_buffer(line)
    @block_buffer = [] if @block_buffer.nil?
    @block_buffer << line
  end

end

articles = []
File.open('mothulog.hateblo.jp.export.txt', 'r') do |file|
  article = Article.new
  file.each_line do |line|
    if article.parse(line)
      # p article.to_s
      articles << article
      article = Article.new
    end
  end
end

articles = articles.sort_by {|a| a.date }

p "Article count: #{articles.count}"
articles.filter! do |article|
  article.date >= DateTime.strptime("02/12/2013", "%m/%d/%Y")
end

p "Article count: #{articles.count}"
articles.filter! do |article|
  article.status == 'Publish'
end

p "Article count: #{articles.count}"

# remove hatena keyword links, because no necessary
articles.each do |article|
  pattern = %r{<a class="keyword" href="http://d.hatena.ne.jp/keyword/(.*)">\1</a>}
  pattern2 = %r{<a class="keyword" href="http://d.hatena.ne.jp/keyword/.*">(.*)</a>}
  if article.body =~ pattern
    article.body.gsub!(pattern) { $1 }
  end

  if article.body =~ pattern2
    article.body.gsub!(pattern2) { $1 }
  end
end

# Remove iframe for markdown convert
articles.each do |article|
  pattern = /<iframe.*>.*<\/iframe>/i
  article.body.gsub!(pattern, '')
end

# Remove cite for markdown convert
articles.each do |article|
  pattern = /<cite.*>(.*)<\/cite>/i
  if article.body =~ pattern
    article.body.gsub!(pattern, $1)
  end
end

# Remove figure for markdown convert
articles.each do |article|
  pattern = /<figure.*>(.*)<\/figure>/i
  if article.body =~ pattern
    article.body.gsub!(pattern, $1)
  end
end

# convert to markdown from html
articles.each do |article|
  article.body = ReverseMarkdown.convert article.body,
                                         github_flavored: true,
                                         unknown_tags: :raise
end


# Sanitize tags
articles.each do |article|
  next if article.categories.blank?
  article.categories = article.categories.map do |category|
    case category
    when 'Ruby-Rails' then 'rails'
    when 'Ruby-Rails-ActiveRecord' then 'active-record'
    when 'Mac-Homebrew' then 'homebrew'
    when 'iOS-Swift-RxSwift' then 'rxswift'
    when 'iOS-Swift' then 'swift'
    when 'iOS-Swift-RxSwift-Scheduler' then 'rxswift-scheduler'
    when '雑記' then 'notebook'
    when '雑記-エンジニアリング' then ''
    when '雑記-育児' then ''
    when '設計' then 'design'
    when 'iOS-UIView' then 'uiview'
    when 'iOS-UIView-SafeArea' then 'ios-safearea'
    when 'Linux-CentOS' then 'centos'
    when 'Ruby-Rails-Controller' then 'rails-controller'
    when 'iOS-Playground' then 'playground'
    when 'iOS-UITableView' then 'uitableview'
    when 'iOS-NSDate' then 'nsdate'
    else category.downcase
    end
  end
end


articles.each do |article|
  file_path = "./_posts/#{article.file_name}"
  File.open(file_path, 'w') do |f|
    f.puts("---")
    f.puts("title: #{article.title}")
    f.puts("description: #{article.title}")
    f.puts("date: #{article.date.strftime('%Y-%m-%d')}")
    if article.categories
      f.puts("categories: #{article.categories.join(' ')}")
      f.puts("tags: #{article.categories.join(' ')}")
    end
    if article.image
      f.puts("image:")
      f.puts("  path: #{article.image}")
    end
    f.puts('draft: true')
    f.puts("---")
    f.puts(article.body)
  end
end

