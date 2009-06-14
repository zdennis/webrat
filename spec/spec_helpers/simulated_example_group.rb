module SimulatedExampleMethods  
  def webrat_session
    unless @_webrat_session
      config = Webrat.configuration
      config.mode = :merb
      @_webrat_session = ::Webrat.session_class.new
    end
    @_webrat_session
  end
  
  def with_html(html)
    raise "This doesn't look like HTML. Wrap it in a <html> tag" unless html =~ /^\s*<[^Hh>]*html/i
    webrat_session.response_body = html
  end  
end

class SimulatedExampleGroup < Spec::Example::ExampleGroup
  extend ::WebratExampleGroupMethods
  include SimulatedExampleMethods
  Spec::Example::ExampleGroupFactory.register(:simulated, self)
end