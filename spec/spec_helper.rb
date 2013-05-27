require "rspec"
require "hdl"

RSpec.configure do |config|
  config.before do
    HDL.path = nil # Reset to default
    HDL.path << "spec/fixtures"
  end
end

def valid(array)
  root = description
  before { subject.root = root }

  it "matches valid" do
    array.each do |v|
      subject.parse(v).should_not be_nil,
        [subject.failure_reason, v].join("\n")
    end
  end
end

def invalid(array)
  root = description
  before { subject.root = root }

  it "does not match invalid" do
    array.each do |i|
      subject.parse(i).should be_nil, i
    end
  end
end
