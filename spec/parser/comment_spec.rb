require "spec_helper"

describe "Comments" do

  describe PinsParser do
    describe "pins" do
      valid([
        "inputs a, b # This is a comment.
        outputs out",

        "inputs a, b #
        outputs out",

        "inputs a, b
          outputs #comment
             out",

        "inputs a, b
          # comment
          outputs out",
        
        "inputs a, # comment
            # comment
                b  # comment
            # comment
          outputs # comment
             out"
      ])
      
      invalid([
        "inputs # comment a
         outputs out",

        "inp#commentuts a, b
         outputs out"
      ])

      it "ignores comments" do
        expectations = {
          "inputs a, b # comment \n outputs out" => [[:a, :b], [:out]],
          "inputs in \n # comment \n outputs out" => [[:in], [:out]]
        }

        expectations.each do |input, (i, o)|
          subject.parse(input).input_array.should == i
          subject.parse(input).output_array.should == o
        end
      end
    end
  end

  describe SchemaParser do
    describe "schema" do
      valid([
        "not(in=in, out=out) # comment
         not(in=in, out=out)",

        "not(           # comment
              in = in,  # comment
              out = out # comment
            )",

        "not(in=in, out=out)
          # comment
          #
          # comment

          not(in=in, out=out)"
      ])

      invalid([
        "not(in=in#comment\n,out=out)",
        "not#comment\n(in=in, out=out)"
      ])

      it "ignores comments" do
        expectations = {
          "not(in=in, out=out) # comment
           not(in=in, out=out)" => [
            { :not => { :in => :in, :out => :out } },
            { :not => { :in => :in, :out => :out } }
          ],

          "not(           # comment
                in = in,  # comment
                out = out # comment
              )" => [
            { :not => { :in => :in, :out => :out } }
          ]
        }

        expectations.each do |input, output|
          subject.parse(input).to_array.should == output
        end
      end
    end
  end

  describe TableParser do
    describe "table" do
      valid([
        "| a | b | out | # comment
         # comment
         #
         | 0 | 0 | # comment
           1 | # comment
         | 0 | 1 | 0 |"
      ])

      invalid([
        "| a #comment | b | out |
         | 0          | 0 |  1  |"
      ])
    end
  end
end
