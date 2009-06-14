class AutomatedExampleGroup < Spec::Example::ExampleGroup
  extend ::WebratExampleGroupMethods
  
  def webrat_session
    unless @_webrat_session
      config = Webrat.configuration
      config.mode = :selenium
      @_webrat_session = ::Webrat.session_class.new
    end
    @_webrat_session
  end  
  
  def page
    webrat.selenium
  end
  
  def remote_app
    RemoteApp.new(webrat_session.selenium)
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
  end

  before :all do
    webrat.selenium
  end
  
  Spec::Example::ExampleGroupFactory.register(:automated, self)
end
