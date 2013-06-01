require "spec_helper"

describe HDL::Dependency do
  let(:klass) { HDL::Dependency }

  describe ".create" do
    it "raises an error on graph cycles" do
      expect {
        klass.create("foo", "foo")
      }.to raise_error(CircularError, /itself/)

      klass.create("foo", "bar")

      expect {
        klass.create("bar", "foo")
      }.to raise_error(CircularError, /each other/)

      klass.create("bar", "baz")
      expect {
        klass.create("baz", "foo")
      }.to raise_error(CircularError, /each other/)
    end

    context "for a new dependency" do
      it "creates" do
        klass.create("foo", "bar")
        klass.all.to_a.first.should == { "foo" => "bar" }
      end
    end

    context "for an existing dependency" do
      before do
        klass.create("foo", "bar")
      end

      it "does not create" do
        expect {
          klass.create("foo", "bar")
        }.to_not change { klass.all }
      end
    end
  end

  describe ".all" do
    it "returns the underlying set" do
      klass.create("foo", "bar")
      klass.create("baz", "qux")

      set = klass.all
      set.should be_a(Set)
      set.size.should == 2
    end
  end

  describe ".where" do
    before do
      klass.create("foo", "bar")
      klass.create("foo", "baz")
      klass.create("bar", "baz")
    end

    it "can filter by dependee" do
      klass.where(:dependee => "foo").to_a.
        should =~ [{"foo" => "bar"}, {"foo" => "baz"}]

      klass.where(:dependee => "bar").to_a.
        should == [{"bar" => "baz"}]

      klass.where(:dependee => "baz").to_a.
        should == []
    end

    it "can filter by dependent" do
      klass.where(:dependent => "foo").to_a.
        should == []

      klass.where(:dependent => "bar").to_a.
        should == [{"foo" => "bar"}]

      klass.where(:dependent => "baz").to_a.
        should =~ [{"foo" => "baz"}, {"bar" => "baz"}]
    end

    it "can filter by both" do
      klass.where(
        :dependee => "foo",
        :dependent => "baz"
      ).should == [{"foo" => "baz"}]
    end
  end

  describe "recursion" do
    before do
      klass.create("foo", "bar")
      klass.create("foo", "baz")
      klass.create("bar", "qux")
      klass.create("baz", "bar")
    end

    #            foo
    #           /   \
    #          /   baz
    #          |  /
    #          bar
    #           |
    #          qux

    describe ".dependees_for" do

      # Read up the graph

      it "returns an array of recursive dependees" do
        klass.dependees_for("foo").
          should == []

        klass.dependees_for("bar").
          should =~ ["foo", "baz"]

        klass.dependees_for("baz").
          should == ["foo"]

        klass.dependees_for("qux").
          should =~ ["foo", "bar", "baz"]
      end
    end

    describe ".dependents_for" do

      # Read down the graph

      it "returns an array of recursive dependents" do
        klass.dependents_for("foo").
          should =~ ["bar", "baz", "qux"]

        klass.dependents_for("bar").
          should =~ ["qux"]

        klass.dependents_for("baz").
          should == ["bar", "qux"]

        klass.dependents_for("qux").
          should == []
      end
    end
  end

end
