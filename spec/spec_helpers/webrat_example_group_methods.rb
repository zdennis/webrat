module WebratExampleGroupMethods
  def self.disable_automated
    define_method :automated do
      #no-op
    end
  end
  
  def self.disable_simulated
    define_method :simulated do
      #no-op
    end
  end
  
  def automated(desc, &blk)
    example_group = Class.new(AutomatedExampleGroup)
    before_each_parts.each do |a|
      example_group.before_each_parts << a
    end
    example_group.it "#{description} #{desc}" do
      automate do
        instance_eval &blk
      end
    end
  end
  
  def simulated(desc, &blk)
    example_group = Class.new(SimulatedExampleGroup)
    before_each_parts.each do |a|
      example_group.before_each_parts << a
    end
    example_group.it "#{description} #{desc}" do
      simulate do
        instance_eval &blk
      end
    end
  end
  
  def with_html(html)
    before(:each) do
      with_html html
    end
  end
end
