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
    it "returns an instance of chip" do
      chip = klass.load(name)

      chip.should be_a(HDL::Chip)
      chip.name.should == :and
      chip.path.should == "spec/fixtures/and.hdl"
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
      it "returns a memoized version" do
        HDL::Chip.should_receive(:new).exactly(:once)
        2.times { klass.load(name) }
      end

      context "and the 'force' option is set" do
        it "does not return a memoized version" do
          HDL::Chip.should_receive(:new).exactly(:twice)
          2.times { klass.load(name, :force => true) }
        end

        it "still memoizes the result for future loads" do
          HDL::Chip.should_receive(:new).exactly(:twice)

          klass.load(name)
          klass.load(name, :force => true)
          klass.load(name)
        end
      end
    end

    describe "loading dependencies" do
      let(:name)  { "mux" }
      let(:dependencies) { %w(not and or) }

      it "loads chips that this chip depends on" do
        expectations = [name] + dependencies

        expectations.each do |e|
          HDL::Chip.should_receive(:new).
            with(e, anything, anything).
            exactly(:once)
        end

        chip = klass.load(name)
        pending "waiting on chip implementation"
        chip.dependencies.map(&:name).should == dependencies
      end

      it "acts recursively" do
        HDL::PrimitiveChip.should_receive(:new).
          with("nand", anything, anything).
          exactly(:once)

        klass.load(name)
      end

      it "treats primitives as the base case" do
        HDL::Chip.should_not_receive(:new)

        HDL::PrimitiveChip.should_receive(:new).
          with("nand", anything, anything).
          exactly(:once)

        klass.load("nand")
      end
    end

  end

end
