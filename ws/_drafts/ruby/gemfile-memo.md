# Gemネタ
gemの紹介記事として使う↓

CarrierWave
gem 'signet'
OAuth2

gem 'browser'
ブラウザまわりごねごね.
UA分析とか

gem 'paranoia'
論理削除gem

gem "paranoia_uniqueness_validator"
paranoia の論理削除によるユニーク制約弊害を解決

gem 'draper'
いわゆる presenter 層

gem 'yaml_db'
db dump/restore 時にdb依存しない形式

gem 'devise'
認証パッケージ

gem 'carrierwave'
画像アップロード

gem 'rmagick', require: false
画像リサイズとか

gem 'fog'
クラウドサービスプロバイダ

gem 'kaminari'
ページネーション

gem 'haml'
haml

gem 'active_link_to'

gem 'foreman'
gem 'thin'
gem 'simple_form', '~> 3.1.0.rc1'
gem 'rails_config'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'validates_email_format_of'
gem 'gon'
#gem 'prawn'
gem 'thinreports-rails'
gem 'httparty'
gem 'httmultiparty'
#gem 'exception_notification', github: 'smartinez87/exception_notification'
gem "breadcrumbs_on_rails"
gem 'compass-rails', '>= 2.0.0'
gem 'acts_as_list'
gem 'aws-sdk', '~> 1.0'
gem 'aws-ses'

gem 'newrelic_rpm'
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem 'rubyzip'
gem 'virtus'
gem 'similar_text'
gem 'ransack'
gem 'jpmobile'
gem 'omniauth-yahoojp'
gem "omniauth-facebook"
gem 'activerecord-import', '>= 0.9.0'
gem 'dalli'
gem 'dalli-elasticache'
gem 'date_validator'
gem "remotipart", "~> 1.2"
gem "woothee"
gem "rails_autolink"
gem "haml-underscore-template"
gem "log4r"
gem "cancancan", "~> 1.9"
gem "htmlentities", "~> 4.3.2"
gem "bitly"

## クローラ用
gem 'zen_to_i'
gem 'capybara'
gem 'capybara-user_agent'
gem "capybara-screenshot"
gem "cucumber"
gem "nokogiri"
gem "poltergeist"
gem "rtesseract"
gem "savon"
gem "rest-client"

# for crontab
gem 'whenever', :require => false

# API Support
gem 'grape'

gem 'twilio-ruby', '~> 3.12'

gem "gmail_api", git: "https://github.com/itandi/gmail_api.git", branch: "v3"
gem "after_do"

gem 'gmo_payment', path: 'lib/gmo_payment'

# Apps
gem 'apns'
gem 'gcm'

gem 'era_ja'

gem "lockfile"
# notifier
gem 'slack-notifier'
gem 'exception_notification'

gem "ckeditor"
gem "mini_magick"
gem "romaji"

gem 'sitemap_generator'
gem 'webpay'

gem 'holiday_jp'

gem "delayed_job_active_record"
gem "daemons"

gem 'pg'

gem 'render_anywhere', :require => false
gem 'systemu'

gem 'meta_events'
gem 'mixpanel-ruby'
gem 'mysql_dump_slow'

gem 'rumoji'

gem 'redis'

gem 'finance', path: 'lib/finance'

gem 'td-logger'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'pry-debugger'
  gem 'pry-doc'
  gem 'hirb'
  gem 'awesome_print'
  gem 'quiet_assets'
  gem 'bullet'
  gem 'tapp'
  gem 'rack-mini-profiler'
  gem 'erb2haml'
  gem 'ruby-prof'
end

group :development, :test do
  gem "selenium-webdriver"
  gem 'terminal-notifier-guard'
  gem 'spork'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'pry-rails'
  gem "rails_best_practices"
  gem 'rails-erd'
  gem 'factory_girl_rails'
  gem "faker"
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'database_rewinder'
  gem "launchy", "~> 2.3.0"
  # Deploy
  gem 'capistrano', '~> 3.2.1'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano3-unicorn'
  gem 'capistrano3-delayed-job', '~> 1.0'
end
