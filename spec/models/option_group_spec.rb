require 'spec_helper'

describe OptionGroup do
  it { should have_many(:options).dependent(:destroy) }
end
