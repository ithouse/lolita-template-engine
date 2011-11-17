require "rubygems"
require "bundler/setup"

begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

TEST_THEMES_PATH = File.expand_path('spec/test_themes')
require File.expand_path('lib/lolita-template-engine')

RSpec.configure do |config|
  config.mock_with :rspec
end