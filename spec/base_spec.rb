require "spec_helper"

describe HDL do
  let(:klass) { subject }

  describe ".path" do
    it "returns the HDL load path" do
      klass.path.should == %w(. spec/fixtures)

      klass.path << "chips"
      klass.path.should == %w(. spec/fixtures chips)
    end
  end

  describe ".load" do
    let(:name) { "and" }
    let(:definition) { File.read("spec/fixtures/and.hdl") }

    it "parses the named hdl file from the path" do
      klass.should_receive(:parse).with(
        name,
        definition,
        :path => "spec/fixtures/and.hdl"
      )
      klass.load(name)
    end

    context "when the file does not exist" do
      let(:name) { "missing" }

      it "raises a file not found error" do
        expect {
          klass.load(name)
        }.to raise_error(FileNotFound, /missing/)
      end
    end
  end

  describe ".parse" do
    pending
  end

end
