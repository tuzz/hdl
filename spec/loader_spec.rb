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

      chip.should be_a(HDL::SchemaChip)
      chip.name.should == "and"
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
        HDL::SchemaChip.should_receive(:new).exactly(:once)
        2.times { klass.load(name) }
      end

      context "and the 'force' option is set" do
        it "does not return a memoized version" do
          HDL::SchemaChip.should_receive(:new).exactly(:twice)
          2.times { klass.load(name, :force => true) }
        end

        it "still memoizes the result for future loads" do
          HDL::SchemaChip.should_receive(:new).exactly(:twice)

          klass.load(name)
          klass.load(name, :force => true)
          klass.load(name)
        end
      end
    end

    context "when given a definition string" do
      it "does not raise a file not found" do
        expect do
          foo = klass.load(
            "foo", :definition => <<-HDL
              inputs a, b
              outputs out

              and(a=a, b=b, out=out)
            HDL
          )

          foo.name.should be_nil
        end.to_not raise_error(FileNotFound)
      end

      it "keeps track of the definition" do
          foo = klass.load(
            "foo", :definition => <<-HDL
              inputs a, b
              outputs out

              and(a=a, b=b, out=out)
            HDL
          )

          expect {
            klass.load(
              "bar", :definition => <<-HDL
                inputs a, b
                outputs out

                foo(a=a, b=b, out=out)
              HDL
            )
          }.to_not raise_error(FileNotFound)
      end
    end
  end

end
