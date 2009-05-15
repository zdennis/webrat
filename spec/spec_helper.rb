require "rubygems"
require "test/unit"
require "spec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

webrat_path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(webrat_path) unless $LOAD_PATH.include?(webrat_path)

require "webrat"
Dir[File.dirname(__FILE__) + '/spec_helpers/*.rb'].each{ |f| require f }
$LOAD_PATH << File.dirname(__FILE__) + '/fakes/'
require File.expand_path(File.dirname(__FILE__) + "/fakes/webrat")
require 'webrat/selenium'

module Webrat
  # @@previous_config = nil
  # 
  # def self.cache_config_for_test
  #   @@previous_config = Webrat.configuration.clone
  # end
  # 
  # def self.reset_for_test
  #   @@configuration = @@previous_config if @@previous_config
  # end
end

Spec::Runner.configure do |config|
  include Webrat::Methods
  config.extend SimulatorMethods

  # config.before :each do
  #   Webrat.cache_config_for_test
  # end
  # 
  # config.after :each do
  #   Webrat.reset_for_test
  # end
end

Webrat.configuration.mode = :merb

at_exit do
  $browser.stop if $browser
end

RAILS_ROOT = File.expand_path("spec/selenium/apps/rails")
