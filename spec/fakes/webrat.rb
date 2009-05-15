module Webrat #:nodoc:
  def self.session_class(config=nil) #:nodoc:
    case config.mode
    when :test
      TestSession
    when :selenium
      SeleniumSession
    end
  end
end