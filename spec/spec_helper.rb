require "rubygems"
require "test/unit"
require "spec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

webrat_path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(webrat_path) unless $LOAD_PATH.include?(webrat_path)

require "webrat"
# require File.expand_path(File.dirname(__FILE__) + "/fakes/test_session")

module Webrat
  @@previous_config = nil

  def self.cache_config_for_test
    @@previous_config = Webrat.configuration.clone
  end

  def self.reset_for_test
    @@configuration = @@previous_config if @@previous_config
  end
end

# Spec::Runner.configure do |config|
#   include Webrat::Methods
# 
#   def with_html(html)
#     raise "This doesn't look like HTML. Wrap it in a <html> tag" unless html =~ /^\s*<[^Hh>]*html/i
#     webrat_session.response_body = html
#   end
# 
#   def with_xml(xml)
#     raise "This looks like HTML" if xml =~ /^\s*<[^Hh>]*html/i
#     webrat_session.response_body = xml
#   end
# 
#   config.before :each do
#     Webrat.cache_config_for_test
#   end
# 
#   config.after :each do
#     Webrat.reset_for_test
#   end
# end
# 
# Webrat.configure do |config|
#   config.mode = :merb
# end

require 'webrat/selenium'

module SimulatorMethods
  def automated(desc, &blk)
    it desc do 
      automate do
        instance_eval &blk
      end
    end
  end
  
  def simulated(desc, &blk)
    it desc do
      simulate do
        instance_eval &blk
      end
    end
  end
  
  def with_html(html)
    before(:each) do
      with_html html
    end
  end
end

class RemoteApp
  def initialize(selenium)
    @page = page
  end
    
  def params
    page.wait_for_page_to_load
    JSON.parse(page.get_body_text)
  end
end

Spec::Matchers.define :_uncheck do |locator|
  match do |page|
    unchecked = false
    10.times do 
      unchecked = !page.checked?(locator)
      break if unchecked
      sleep 0.2
    end
    unchecked ||
      raise(Spec::Expectations::ExpectationNotMetError, "Locator: #{locator} did not become unchecked")
  end
end


Spec::Runner.configure do |config|
  include Webrat::Methods
  config.extend SimulatorMethods
  
  def page
    webrat.selenium
  end
  
  def remote_app
    RemoteApp.new(page)
  end

  def automate(&blk)
    webrat.automate(&blk)
  end

  def simulate(&blk)
    webrat.simulate(&blk)
  end

  def with_html(html)
    raise "This doesn't look like HTML. Wrap it in a <html> tag" unless html =~ /^\s*<[^Hh>]*html/i
    Dir.chdir "#{RAILS_ROOT}/public" do
      File.open("index.html", "w+"){ |f| f.puts html }
    end
    visit "/"
    # webrat_session.response_body = html
  end

  def with_xml(xml)
    raise "This looks like HTML" if xml =~ /^\s*<[^Hh>]*html/i
    webrat_session.response_body = xml
  end

  config.before :all do
    webrat.selenium
  end

  config.before :each do
    Webrat.cache_config_for_test
  end

  config.after :each do
    Webrat.reset_for_test
  end
end

at_exit do
  $browser.stop
end

Webrat.configure do |config|
  config.mode = :selenium
  config.application_framework = :rails
end

RAILS_ROOT = File.expand_path("spec/selenium/apps/rails")
