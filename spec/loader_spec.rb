require "spec_helper"

describe HDL::Loader do
  let(:klass) { subject.class }
  let(:name) { "and" }
  let(:definition) { File.read("spec/fixtures/and.hdl") }

  describe ".path" do
    it "returns the HDL load path" do
      klass.path.should == %w(. spec/fixtures)

      klass.path << "chips"
      klass.path.should == %w(. spec/fixtures chips)
    end
  end

  describe ".load" do
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

    context "when the file has already been loaded" do
      before do
        klass.stub(:parse) # fixme
      end

      it "returns a memoized version" do
        File.should_receive(:read).exactly(:once)
        2.times { klass.load(name) }
      end

      context "and the 'force' option is set" do
        it "does not return a memoized version" do
          File.should_receive(:read).exactly(:twice)
          2.times { klass.load(name, :force => true) }
        end

        it "still memoizes the result for future loads" do
          File.should_receive(:read).exactly(:twice)

          klass.load(name)
          klass.load(name, :force => true)
          klass.load(name)
        end
      end
    end
  end

end
