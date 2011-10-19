require 'chef/mash'
require 'mocha'

require './libraries/user.rb'


describe GenericUsers::User do
  describe "#initialize" do
    it "sets proper attributes" do
      u = GenericUsers::User.new({ "id" => "test", "foo" => "bar", "baz" => "quux" })
      u.data[:id].should == "test"
      u.data[:foo].should == "bar"
      u.data["foo"].should == "bar"
      u.data[:username].should == "test"

      u = GenericUsers::User.new({ "id" => "test", "username" => "te.st" })
      u.data[:id].should == "test"
      u.data[:username].should == "te.st"
    end

    it "ensures :groups is an array" do
      u = GenericUsers::User.new({ "id" => "test", "groups" => ["bar"] })
      u.data[:groups].should == ["bar"]

      u = GenericUsers::User.new({ "id" => "test", "groups" => ["bar", "baz"] })
      u.data[:groups].should == ["bar", "baz"]

      u = GenericUsers::User.new({ "id" => "test", "groups" => "bar" })
      u.data[:groups].should == ["bar"]
    end
  end

  describe "#inspect" do
    it "returns sensible value" do
      u = GenericUsers::User.new({ "id" => "test", "groups" => "bar" })
      u.inspect.should =~ /^\#<GenericUsers::User:0x[0-9a-f]+ test>/
    end
  end

  describe "#[]" do
    it "maps to @data" do
      [ GenericUsers::User.new({ "id" => "test", "foo" => "bar", "baz" => "quux" }),
        GenericUsers::User.new({ "id" => "test", "username" => "te.st" })
      ].each do |u|
        u.data.each_key do |k|
          u[k].should == u.data[k]
          u[k.to_sym].should == u.data[k.to_sym]
        end
      end
    end

    it "defaults to group attributes" do
      u = GenericUsers::User.new({ "id" => "test", "groups" => [ "t" ], "foo" => "bar" })
      u.stubs(:groups).returns( [
          Mash::new(
            :id => "t",
            :user_attributes => Mash::new(:foo => "xyzzy", :baz => "quux")) 
        ] )
      u[:foo].should == 'bar'
      u[:baz].should == 'quux'
    end
  end

  describe "#get_all" do
    it "returns an unflattened array without a block" do
      u = GenericUsers::User.new({ "id" => "test", "groups" => [ "t" ], "foo" => "bar" })
      u.stubs(:groups).returns( [
          Mash::new(
            :id => "t",
            :user_attributes => Mash::new(:foo => "xyzzy", :baz => "quux")) 
        ] )

      u.get_all(:foo).should == [["bar"], ["xyzzy"]]

      u.stubs(:groups).returns( [
          Mash::new(
            :id => "t",
            :user_attributes => Mash::new(:foo => ["quux", "xyzzy"], :baz => "quux")) 
        ] )
      u.get_all(:foo).should == [["bar"], ["quux", "xyzzy"]]
    end

    it "returns a flattened array with a block" do
      u = GenericUsers::User.new({ "id" => "test", "groups" => [ "t" ], "foo" => "bar" })
      u.stubs(:groups).returns( [
          Mash::new(
            :id => "t",
            :user_attributes => Mash::new(:foo => "xyzzy", :baz => "quux")) 
        ] )

      u.get_all(:foo, &:+).should == ["bar", "xyzzy"]

      u.stubs(:groups).returns( [
          Mash::new(
            :id => "t",
            :user_attributes => Mash::new(:foo => ["quux", "xyzzy"], :baz => "quux")) 
        ] )
      u.get_all(:foo, &:+).should == ["bar", "quux", "xyzzy"]
    end

    it "works with &:+ and &:|" do
      u = GenericUsers::User.new({ "id" => "test", "groups" => [ "t" ], "foo" => ["bar", "quux"] })
      u.stubs(:groups).returns( [
          Mash::new(
            :id => "t",
            :user_attributes => Mash::new(:foo => ["quux", "xyzzy"], :baz => "quux")) 
        ] )
      u.get_all(:foo, &:+).should == ["bar", "quux", "quux", "xyzzy"]
      u.get_all(:foo, &:|).should == ["bar", "quux", "xyzzy"]
    end
  
  end
end
