require "spec_helper"

describe HDL::Parser::Validator do
  let(:klass) { HDL::Parser::Validator }
  let(:t) { true  }
  let(:f) { false }

  def valid(array)
    array.each do |hash|
      expect { klass.validate!(hash) }.to_not raise_error
    end
  end

  def invalid(array)
    array.each do |hash|
      expect { klass.validate!(hash) }.to raise_error,
        "no error raised for: #{hash.inspect}"
    end
  end

  it "validates the fixtures without raising an error" do
    fixtures   = Dir.glob("spec/fixtures/*.hdl")
    contents   = fixtures.map { |f| File.read(f) }
    parser     = HDLParser.new
    results    = contents.map { |c| parser.parse(c) }

    valid(results.map(&:structured))
  end

  it "checks that inputs cannot also be outputs" do
    valid([
      {
        :inputs => [:a, :b],
        :outputs => [:c, :d],
        :schema => []
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
  end

  describe "schemas" do

  end

  describe "truth tables" do
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
    end
  end

end
