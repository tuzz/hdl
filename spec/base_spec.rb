require "spec_helper"

describe HDL do
  let(:klass) { subject }

  describe ".path" do
    it "delegates to the loader" do
      HDL::Loader.should_receive(:path)
      klass.path
    end
  end

end
