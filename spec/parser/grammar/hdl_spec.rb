require "spec_helper"

describe HDLParser do

  describe "hdl" do
    valid(Dir.glob("spec/fixtures/*.hdl").map { |f| File.read(f) })

    describe "structured" do
      it "returns structured data for the parse" do
        expectations = {
          File.read("spec/fixtures/and.hdl") => {
            :inputs => [:a, :b],
            :outputs => [:out],
            :schema => [
              { :nand => { :a => :a, :b => :b, :out => :x } },
              { :nand => { :a => :x, :b => :x, :out => :out } }
            ]
          },

          File.read("spec/fixtures/nand.hdl") => {
            :inputs => [:a, :b],
            :outputs => [:out],
            :table => [
              { :a => false, :b => false, :out => true  },
              { :a => false, :b => true,  :out => true  },
              { :a => true,  :b => false, :out => true  },
              { :a => true,  :b => true,  :out => false }
            ]
          },

          File.read("spec/fixtures/mux.hdl") => {
            :inputs => [:a, :b, :sel],
            :outputs => [:out],
            :schema => [
              { :not => { :in => :sel, :out => :nots } },
              { :and => { :a => :a, :b => :nots, :out => :t1 } },
              { :and => { :a => :b, :b => :sel, :out => :t2 } },
              { :or => { :a => :t1, :b => :t2, :out => :out } }
            ]
          }
        }

        expectations.each do |input, output|
          subject.parse(input).structured.should == output
        end
      end
    end
  end

end
