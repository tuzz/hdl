require "spec_helper"
require "validator_helper"

describe HDL::Parser::Validator::TableValidator do
  include ValidatorHelper
  let(:klass) { HDL::Parser::Validator::TableValidator }

  it "checks that inputs match table headers" do
    valid([
      {
        :inputs => [:in],
        :outputs => [:out],
        :table => [
          { :in => f, :out => t },
          { :in => t, :out => f },
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:a, :b, :c],
        :table => [
          { :in => f, :a => f, :b => f, :c => f },
          { :in => t, :a => t, :b => t, :c => t }
        ]
      }
    ])

    invalid([
      {
        :inputs => [:a, :b],
        :outputs => [:c, :d],
        :table => [
          { :b => f, :c => t, :d => t },
          { :b => t, :c => f, :d => f }
        ]
      },

      {
        :inputs => [:a, :b],
        :outputs => [:c, :d],
        :table => [
          { :a => f, :b => t, :c => t },
          { :a => t, :b => f, :c => f }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:out],
        :table => [
          { :in => t, :out => f, :missing => f },
          { :in => f, :out => t, :missing => t }
        ]
      }
    ])

    expect {
      klass.validate!(
        :inputs => [:a, :b],
        :outputs => [:c, :d],
        :table => [
          { :b => f, :c => t, :d => t },
          { :b => t, :c => f, :d => f }
        ]
      )
    }.to raise_error(/expecting table headers a,b,c,d/)
  end

  it "checks that rows correspond to unique input combinations" do
    valid([
      {
        :inputs => [:in],
        :outputs => [:out],
        :table => [
          { :in => f, :out => t },
          { :in => t, :out => f }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:a, :b],
        :table => [
          { :in => f, :a => t, :b => t },
          { :in => t, :a => f, :b => f }
        ]
      },

      {
        :inputs => [:a, :b],
        :outputs => [:out],
        :table => [
          { :a => f, :b => f, :out => f },
          { :a => f, :b => t, :out => f },
          { :a => t, :b => f, :out => f },
          { :a => t, :b => t, :out => t }
        ]
      },

      {
        :inputs => [:a, :b],
        :outputs => [:c, :d],
        :table => [
          { :a => f, :b => f, :c => f, :d => t },
          { :a => f, :b => t, :c => f, :d => t },
          { :a => t, :b => f, :c => f, :d => t },
          { :a => t, :b => t, :c => t, :d => f }
        ]
      }
    ])

    invalid([
      {
        :inputs => [:in],
        :outputs => [:out],
        :table => [
          { :in => f, :out => t }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:out],
        :table => [
          { :in => f, :out => t },
          { :in => f, :out => f }
        ]
      },

      {
        :inputs => [:in],
        :outputs => [:out],
        :table => [
          { :in => f, :out => t },
          { :in => t, :out => f },
          { :in => t, :out => f }
        ]
      }
    ])

    expect {
     klass.validate!(
        :inputs => [:a, :b, :c, :d],
        :outputs => [:out],
        :table => [
          { :a => t, :b => t, :c => t, :d => t, :out => f }
        ]
      )
    }.to raise_error(/16 rows are required/)

    expect {
      klass.validate!(
        :inputs => [:in],
        :outputs => [:out],
        :table => [
          { :in => t, :out => f },
          { :in => t, :out => f }
        ]
      )
    }.to raise_error(/appears multiple times/)
  end
end
