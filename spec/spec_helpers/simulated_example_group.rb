class SimulatedExampleGroup < Spec::Example::ExampleGroup
  def webrat_session
    unless @_webrat_session
      config = Webrat::Configuration.new
      config.mode = :test
      @_webrat_session = ::Webrat.session_class(config).new
    end
    @_webrat_session
  end
  
  def with_html(html)
    raise "This doesn't look like HTML. Wrap it in a <html> tag" unless html =~ /^\s*<[^Hh>]*html/i
    webrat_session.response_body = html
  end  
  
  Spec::Example::ExampleGroupFactory.register(:simulated, self)
end