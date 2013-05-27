require "spec_helper"
require "validator_helper"

describe HDL::Parser::Validator::SchemaValidator do
  include ValidatorHelper
  let(:klass) { HDL::Parser::Validator::SchemaValidator }

  it "checks that every input has been read" do
    valid([
      {
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :nand => { :a => :in, :b => :out } }
        ]
      },

      {
        :inputs => [:a, :b],
        :outputs => [:c, :d],
        :schema => [
          { :nand => { :a => :a, :b => :b, :out => :c } },
          { :nand => { :a => :b, :b => :a, :out => :d } }
        ]
      },

      {
        :inputs => [:a, :b],
        :outputs => [:out],
        :schema => [
          { :and => { :a => :b, :b => :a, :out => :x } },
          { :not => { :in => :x, :out => :out } }
        ]
      }
    ])

    invalid([
      {
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :not => { :in => true, :out => false } }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :nand => { :in => false, :out => :out } }
        ]
      },

      {
        :inputs => [:a, :b],
        :outputs => [:out],
        :schema => [
          { :nand => { :a => false, :b => true, :out => :out } }
        ]
      }
    ])

    expect {
      klass.validate!(
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :not => { :in => true, :out => :out } }
        ]
      )
    }.to raise_error(/`in' is not connected/)

    expect {
      klass.validate!(
        :inputs => [:a, :b],
        :outputs => [:out],
        :schema => [
          { :nand => { :a => false, :b => true, :out => :out } }
        ]
      )
    }.to raise_error(/inputs are not connected: a, b/)
  end

  it "checks that every output pin has been written" do
    valid([
      {
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :not => { :in => :in, :out => :out } }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:a, :b],
        :schema => [
          { :not => { :in => :in, :out => :a } },
          { :nand => { :a => :in, :b => :in, :out => :b } }
        ]
      }
    ])

    invalid([
      {
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :not => { :in => :in, :out => :x } }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:a, :b],
        :schema => [
          { :nand => { :a => :in, :b => :in, :out => :b } }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:a, :b, :out],
        :schema => [
          { :nand => { :a => :in, :b => :in, :out => :a } },
          { :not => { :in => :in, :out => :out } }
        ]
      }
    ])

    expect {
      klass.validate!(
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :not => { :in => :in, :out => :x } }
        ]
      )
    }.to raise_error(/`out' is not connected/)
  end

  it "checks that outputs are only written once" do
    invalid([
      {
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :not => { :in => :in, :out => :out } },
          { :not => { :in => true, :out => :out } }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :not => { :in => :in, :out => :out } },
          { :not => { :in => :in, :out => :out } }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:a, :b],
        :schema => [
          { :nand => { :a => :in, :b => true, :out => :a } },
          { :nand => { :a => false, :b => :in, :out => :b } },
          { :not => { :in => :in, :out => :a } }
        ]
      }
    ])

    expect {
      klass.validate!(
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :not => { :in => :in, :out => :out } },
          { :not => { :in => :in, :out => :out } }
        ]
      )
    }.to raise_error(/`out' is connected multiple times/)

    expect {
      klass.validate!(
        :inputs => [:in],
        :outputs => [:a, :b],
        :schema => [
          { :foo => { :in => :in, :a => :a, :b => :b } },
          { :foo => { :in => :in, :a => :a, :b => :b } },
        ]
      )
    }.to raise_error(/outputs are connected multiple times: a, b/)
  end

end
