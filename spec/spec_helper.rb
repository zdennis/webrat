require "rubygems"
require "test/unit"
require "spec"
require 'ruby-debug'

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

webrat_path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(webrat_path) unless $LOAD_PATH.include?(webrat_path)

require "webrat"
require File.expand_path(File.dirname(__FILE__) + "/fakes/webrat/test")
require File.dirname(__FILE__) + '/spec_helpers/webrat_example_group_methods'

Dir[File.dirname(__FILE__) + '/spec_helpers/**/*.rb'].each{ |f| require f }

module Webrat
  @@previous_config = nil
  
  def self.cache_config_for_test
    @@previous_config = Webrat.configuration.clone
  end
  
  def self.reset_for_test
    @@configuration = @@previous_config if @@previous_config
  end
end

Spec::Example::ExampleGroupFactory.default SimulatedExampleGroup
Spec::Runner.configure do |config|
  include Webrat::Methods

  config.include SimulatedExampleMethods
  config.extend WebratExampleGroupMethods

  if ENV["WEBRAT"] == "automated"
    require 'webrat/selenium'
    WebratExampleGroupMethods.disable_simulated
    RAILS_ROOT = File.expand_path("spec/selenium/apps/rails")
    at_exit { $browser.stop if $browser }
  else
    WebratExampleGroupMethods.disable_automated
  end

  config.before :each do
    Webrat.cache_config_for_test
  end
  
  config.after :each do
    Webrat.reset_for_test
  end
end

