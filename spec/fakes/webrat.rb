module Webrat #:nodoc:
  def self.session_class(config=Webrat.configuration) #:nodoc:
    case config.mode
    when :selenium
      SeleniumSession
    else 
      TestSession
    end
  end
end