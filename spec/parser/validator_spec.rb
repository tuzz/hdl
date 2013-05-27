require "spec_helper"
require "validator_helper"

describe HDL::Parser::Validator do
  include ValidatorHelper
  let(:klass) { HDL::Parser::Validator }

  it "validates the fixtures without raising an error" do
    fixtures   = Dir.glob("spec/fixtures/*.hdl")
    contents   = fixtures.map { |f| File.read(f) }
    parser     = HDLParser.new
    results    = contents.map { |c| parser.parse(c) }

    valid(results.map(&:structured))
  end

  context "for a schema definition" do
    let(:definition) do
      {
        :inputs => [:in],
        :outputs => [:out],
        :schema => [
          { :not => { :in => :in, :out => :out } }
        ]
      }
    end

    it "validates against the schema subclass" do
      klass::SchemaValidator.should_receive(:validate!)
      klass::TableValidator.should_not_receive(:validate!)

      klass.validate!(definition)
    end
  end

  context "for a table definition" do
    let(:definition) do
      {
        :inputs => [:in],
        :outputs => [:out],
        :table => [
          { :in => false, :out => true  },
          { :in => true,  :out => false }
        ]
      }
    end

    it "validates against the schema subclass" do
      klass::TableValidator.should_receive(:validate!)
      klass::SchemaValidator.should_not_receive(:validate!)

      klass.validate!(definition)
    end
  end

end
