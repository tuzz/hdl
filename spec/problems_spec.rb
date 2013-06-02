require "spec_helper"

describe HDL do

  it "handles problem cases gracefully" do
    HDL.path << "spec/fixtures/problems"

    expect {
      HDL.load("circular_a")
    }.to raise_error(/depend on each other/)

    expect {
      HDL.load("circular_b")
    }.to raise_error(/depend on each other/)

    expect {
      HDL.load("missing")
    }.to raise_error(/Could not locate/)

    expect {
      HDL.load("multi_output")
    }.to raise_error(/`out' is connected multiple times/)

    expect {
      HDL.load("self_referential")
    }.to raise_error(/cannot depend on itself/)

    expect {
      HDL.load("table_dup")
    }.to raise_error(/appears multiple times/)

    expect {
      HDL.load("table_partial")
    }.to raise_error(/4 rows are required/)

    expect {
      HDL.load("unknowable")
    }.to raise_error(/Unknowable internal pins/)

    expect {
      HDL.load("unused_inputs")
    }.to raise_error(/input `in' is not connected/)

    expect {
      HDL.load("unused_outputs")
    }.to raise_error(/output `out' is not connected/)

    expect {
      HDL.load("missing_internal")
    }.to raise_error(/Unknown internal pin/)

    expect {
      HDL.load("dual_internal")
    }.to raise_error(/Unknown internal pin/)

    expect {
      HDL.load("multi_internal")
    }.to raise_error(/internal pin `x' is set multiple times/)
  end

end
