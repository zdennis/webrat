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
