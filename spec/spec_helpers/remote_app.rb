class RemoteApp
  def initialize(selenium)
    @selenium = selenium
  end
    
  def params
    @selenium.wait_for_page_to_load
    JSON.parse(@selenium.get_body_text)
  end
end
