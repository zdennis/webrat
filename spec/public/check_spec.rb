require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require 'ruby-debug'
require 'json'

describe "check" do
  context "when no checkbox is found" do
    with_html <<-HTML
      <html>
        <form method="post" action="/login">
        </form>
      </html>
    HTML

    simulated "should raise an error" do
      lambda { 
        check "remember_me" 
      }.should raise_error(Webrat::NotFoundError)
    end
    
    automated "should raise an error" do
      lambda { check "remember_me" }.should raise_error(Selenium::CommandError)
    end
  end

  context "when the input is not a checkbox" do
    with_html <<-HTML
      <html>
        <form method="post" action="/login">
          <input type="text" name="remember_me" />
        </form>
      </html>
    HTML
    
    simulated "should raise an error" do
      lambda { check "remember_me" }.should raise_error(Webrat::NotFoundError)
    end
    
    automated "should not raise an error" do
      lambda { check "remember_me" }.should_not raise_error
    end
  end
  
  context "when checking rails style checkboxes" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" type="checkbox" value="1" />
        <input name="user[tos]" type="hidden" value="0" />
        <label for="user_tos">TOS</label>
        <input type="submit" />
      </form>
      </html>
    HTML
    
    simulated "should check the checkbox" do
      webrat_session.should_receive(:get).with("/login", "user" => {"tos" => "1"})
      check "TOS"
      click_button
    end
    
    automated "should check the checkbox" do
      check "TOS"
      page.checked?("user_tos").should be_true
    end
  end

  context "when posting a form" do
    with_html <<-HTML
      <html>
        <form method="post" action="/login">
          <input type="checkbox" name="remember_me" />
          <input type="submit" />
        </form>
      </html>
    HTML

    simulated "should result in the value being posted" do
      webrat_session.should_receive(:post).with("/login", "remember_me" => "on")
      check "remember_me"
      click_button
    end
    automated "should result in the value being posted" do
      check "remember_me"
      click_button
      remote_app.params.should == {"remember_me" => "on"}
    end
  end

  context "when the checkbox is disabled" do
    with_html <<-HTML
      <html>
        <form method="post" action="/login">
          <input type="checkbox" name="remember_me" disabled="disabled" />
          <input type="submit" />
        </form>
      </html>
    HTML

    simulated "should raise an error" do
      lambda { check "remember_me" }.should raise_error(Webrat::DisabledFieldError)
    end
    automated "should not raise an error or check the checkbox" do
      lambda { check "remember_me" }.should_not raise_error
      page.checked?("remember_me").should be_false
    end
  end

  context "when a custom value is being posted" do
    with_html <<-HTML
      <html>
        <form method="post" action="/login">
          <input type="checkbox" name="remember_me" value="yes" />
          <input type="submit" />
        </form>
      </html>
    HTML

    simulated "should post the custom value" do
      webrat_session.should_receive(:post).with("/login", "remember_me" => "yes")
      check "remember_me"
      click_button
    end
    automated "should post the custom value" do
      check "remember_me"
      click_button
      remote_app.params.should == {"remember_me" => "yes"}
    end
  end
end

describe "uncheck" do
  context "when no checkbox is found" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
      </form>
      </html>
    HTML
  
    simulated "should raise an error" do
      lambda { uncheck "remember_me" }.should raise_error(Webrat::NotFoundError)
    end
    automated "should raise an error" do
      lambda { uncheck "remember_me" }.should raise_error(Selenium::CommandError)
    end
  end
  
  context "when the input is not a checkbox" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="text" name="remember_me" />
      </form>
      </html>
    HTML

    simulated "should raise an error" do
      lambda { uncheck "remember_me" }.should raise_error(Webrat::NotFoundError)
    end
    automated "should not raise an error" do
      lambda { uncheck "remember_me" }.should_not raise_error
    end
  end

  context "when the checkbox is disabled" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="checkbox" name="remember_me" checked="checked" disabled="disabled" />
        <input type="submit" />
      </form>
      </html>
    HTML
    
    simulated "should raise an error" do
      lambda { uncheck "remember_me" }.should raise_error(Webrat::DisabledFieldError)
    end
    automated "should not raise an error" do
      lambda { uncheck "remember_me" }.should_not raise_error
    end
  end

  context "when unchecking rails style checkboxes" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" type="checkbox" value="1" checked="checked" />
        <input name="user[tos]" type="hidden" value="0" />
        <label for="user_tos">TOS</label>
        <input type="submit" />
      </form>
      </html>
    HTML
    
    simulated "should uncheck the checkbox" do
      webrat_session.should_receive(:get).with("/login", "user" => {"tos" => "0"})
      check "TOS"
      uncheck "TOS"
      click_button
    end
    automated "should uncheck the checkbox" do
      check "TOS"
      page.should _uncheck("user_tos")
    end
  end

  context "when posting a form" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="checkbox" name="remember_me" value="yes" checked="checked" />
        <input type="submit" />
      </form>
      </html>
    HTML
    
    simulated "should not post the checkbox value" do
      webrat_session.should_receive(:post).with("/login", {})
      uncheck "remember_me"
      click_button
    end
    automated "should not post the checkbox value" do
      uncheck "remember_me"
      click_button
      remote_app.params.should == {}
    end
  end

  context "when posting a form where multiple checkboxes have the same name" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input id="option_1" name="options[]" type="checkbox" value="1" />
        <label for="option_1">Option 1</label>
        <input id="option_2" name="options[]" type="checkbox" value="2" />
        <label for="option_2">Option 2</label>
        <input type="submit" />
      </form>
      </html>
    HTML
    
    simulated "should post all checkbox values" do
      webrat_session.should_receive(:post).with("/login", {"options" => ["1", "2"]})
      check 'Option 1'
      check 'Option 2'
      click_button
    end
    automated "should post all checkbox values" do
      check 'Option 1'
      check 'Option 2'
      click_button
      remote_app.params.should == { "options" => ["1", "2"] }
    end
  end

  context "when working with rails style checkboxes nested inside a label" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <label>
          TOS
          <input name="user[tos]" type="hidden" value="0" />
          <input id="user_tos" name="user[tos]" type="checkbox" value="1" checked="checked" />
        </label>
        <input type="submit" />
      </form>
      </html>
    HTML
    
    simulated "should uncheck the checkbox" do
      webrat_session.should_receive(:get).with("/login", "user" => {"tos" => "0"})
      uncheck "TOS"
      click_button
    end
    automated "should uncheck the checkbox" do
      uncheck "TOS"
      page.checked?("user_tos").should be_false
    end
  end

end
