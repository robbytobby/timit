RSpec::Matchers.define :have_association do |type, name|
  match do |model|
    model.class.reflections[name].macro == type
  end

  failure_message_for_should do |model|
    verb = type == :has_many ? 'have many' : 'belong to'
    "expected #{model.class} to #{verb} #{name}, but it does not\n"
  end

  failure_message_for_should_not do |model|
    verb = type == :has_many ? 'have many' : 'belong to'
    "expected #{model.class} to not #{verb} #{attribute}, but it does"
  end
end
