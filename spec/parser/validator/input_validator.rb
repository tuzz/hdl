require "spec_helper"
require "validator_helper"

describe HDL::Parser::Validator::InputValidator do
  include ValidatorHelper
  let(:klass) { HDL::Parser::Validator::InputValidator }

  it "checks that inputs cannot also be outputs" do
    valid([
      {
        :inputs => [:a, :b],
        :outputs => [:c, :d],
        :schema => [
          { :nand => { :a => :a, :b => :b, :out => :c } },
          { :nand => { :a => :a, :b => :b, :out => :d } }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:a, :b],
        :table => [
          { :in => t, :a => t, :b => t },
          { :in => f, :a => t, :b => t }
        ]
      }
    ])

    invalid([
      {
        :inputs => [:a, :b],
        :outputs => [:b, :c],
        :table => [
          { :a => t, :b => t, :c => f },
          { :a => t, :b => f, :c => t },
          { :a => f, :b => t, :c => t },
          { :a => f, :b => f, :c => f }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:in],
        :table => [
          { :in => t },
          { :in => f }
        ]
      },

      {
        :inputs => [:a, :b],
        :outputs => [:a, :b],
        :table => [
          { :a => t, :b => t },
          { :a => f, :b => t },
          { :a => f, :b => f },
          { :a => t, :b => f }
        ]
      }
    ])

    expect {
      klass.validate!({ :inputs => [:in], :outputs => [:in] })
    }.to raise_error(/`in' is both/)

    expect {
      klass.validate!({ :inputs => [:a, :b], :outputs => [:a, :b] })
    }.to raise_error(/`a', `b'/)
  end

end
