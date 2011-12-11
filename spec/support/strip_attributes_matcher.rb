RSpec::Matchers.define :strip_attributes do |attributes|
  match do |model|
    [attributes].flatten.each do |attr|
      model.send(attr.to_s + '=',' test ')
      model.valid?
      model.send(attr).should == 'test'
    end
  end

  failure_message_for_should do |model|
    "expected #{model.class} to strip #{attributes.to_s}, but it does not\n"
  end

  failure_message_for_should_not do |model|
    "expected #{model.class} not to strip #{attributes.to_s}, but it does\n"
  end
end

