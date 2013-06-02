require "spec_helper"

describe HDL do
  let(:klass) { subject }

  describe ".path" do
    it "delegates to the loader" do
      HDL::Loader.should_receive(:path)
      klass.path
    end
  end

  describe ".load" do
    it "delegates to the loader and forces" do
      HDL::Loader.should_receive(:load).
        with("and", :force => true)

      klass.load("and")
    end
  end

  describe ".parse" do
    it "delegates to the loader, forces and sets def" do
      HDL::Loader.should_receive(:load).
        with("foo", :force => true, :definition => "def")

      klass.parse("foo", "def")
    end
  end

end
