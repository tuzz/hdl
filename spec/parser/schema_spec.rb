require "spec_helper"

describe SchemaParser do

  describe "schema" do
    valid([
      "nand(a=a, b=b, out=x)
       nand(a=x, b=x, out=out)",
      "not(in = sel, out = nots)
       and(a=a, b=nots, out=t_1)
       and(a=b, b=sel,  out=t_2)

       or(a=t_1, b=t_2, out=out)",
      "not(in = sel, out = not_sel)
       and(a=in, b=not_sel, out=a)
       and(a=in, b=sel, out=b)",
      "\n\n\tnand(a=T, b=0, out=out)"
    ])

    invalid([
      "",
      "nand()",
      "nand(a=a, b=b, out=out);",
      "nand(xor(a=a, b=b, out=out), b=b, out=out)",
      "xor(a=2, b=b, out=out)",
      "Nand(a=a, b=b, out=out)",
      "not(a=a, b=b);",
      "not(a=1,)",
      "nand(a=a, a=a=a)",
      "mux(a)"
    ])

    describe "to_array" do
      it "returns an array of nested hashes for the schema" do
        "nand(a=a, b=b, out=x)
         nand(a=x, b=1, out=out)"

         expectations = {
           "not(in=in, out=out)" => [
             { :not => { :in => :in, :out => :out } }
           ],

           "nand(a=a, b=b, out=x)
            nand(a=x, b=x, out=out)" => [
              { :nand => { :a => :a, :b => :b, :out => :x } },
              { :nand => { :a => :x, :b => :x, :out => :out } }
           ],

           "\nnot(in = sel, out = not_sel)
           and(a=in, b=not_sel, out=a)
           and(a=in, b=sel, out=b)" => [
             { :not => { :in => :sel, :out => :not_sel } },
             { :and => { :a => :in, :b => :not_sel, :out => :a } },
             { :and => { :a => :in, :b => :sel, :out => :b } }
           ],

           "mux( foo = bar, baz = T, qux = 0 )
            not(in=bar, out=out)" => [
              { :mux => { :foo => :bar, :baz => true, :qux => false } },
              { :not => { :in => :bar, :out => :out } }
           ]
         }

         expectations.each do |input, output|
           subject.parse(input).to_array.should == output
         end
      end
    end
  end

  describe "chip" do
    valid([
      "nand(a=a,b=b,out=out)",
      "xor(a=foo_bar, bar_baz=x, out=q)",
      "chip_1(input_1=arg1, output_1=out1)",
      "a_b_c(a=T, b=0, c=F)",
      "a(a=0)",
      "not(   in = \t T, out  \n = o  )"
    ])

    invalid([
      " not(in=in, out=out)",
      "not(in=in, out=out) ",
      "not(in=in , out=out)",
      "Not(in=in, out=out)",
      "not()",
      "not(in=2, out=out)",
      "not(in=, out=out)",
      "not(=in, out=out)",
      "not[in=in, out=out]",
      "not(in=not(in=in, out=out), out=out)"
    ])

    describe "name" do
      it "returns the name of the chip" do
        expectations = {
          "nand(a=a, b=b, out=out)" => :nand,
          "not(in=in, out=out)" => :not,
          "foo123(bar=baz)" => :foo123,
          "asd(   a = b, c=T   )" => :asd
        }

        expectations.each do |input, output|
          subject.parse(input).name.should == output
        end
      end
    end
  end

  describe "arguments" do
    valid([
      "a=a,b=b,out=out",
      "   a    = a,     b\t\n=b,out = out",
      "a_1=a, b=b_2, c=ccc",
      "a=1",
      "b=F",
      "a_1=1, b_0=0, c=T, d=F",
    ])

    invalid([
      "a=a,b",
      "a=2",
      "a=_",
      "a=Test",
      "a=a , b=b",
      "a= aT, b=F",
      "a=1, 1=b",
      "a=a,b=b,c=c,d=d,e=E"
    ])

    describe "#to_hash" do
      it "returns a symbolized hash of the arguments" do
        expectations = {
          "a=a, b=b, out=out" => { :a => :a, :b => :b, :out => :out },
          "in=x, out=y" => { :in => :x, :out => :y },
          "foo_123 = test, test = T" => { :foo_123 => :test, :test => true },
          "a=0, b=1, c=F" => { :a => false, :b => true, :c => false }
        }

        expectations.each do |input, output|
          subject.parse(input).to_hash.should == output
        end
      end
    end
  end

  describe "argument" do
    valid(["a=a", "b= b", "cc =cc", "d = d", " e =e", "f\t\n= f", "g=T", "h=0"])
    invalid(["a==a", "b=5", "c=_a", "d=d=d", "e=e,f=f", "T=a", "0=b"])

    describe "left" do
      it "returns a symbol for the left side of the assigment" do
        expectations = {
          "a=b" => :a, "cc =dd" => :cc, "g=T" => :g, "h=0" => :h
        }

        expectations.each do |input, output|
          subject.parse(input).left.should == output
        end
      end
    end

    describe "right" do
      it "returns a symbol or boolean for the left side of the assigment" do
        expectations = {
          "a=b" => :b, "cc =dd" => :dd, "g=T" => true, "h=0" => false
        }

        expectations.each do |input, output|
          subject.parse(input).right.should == output
        end
      end
    end
  end
end
