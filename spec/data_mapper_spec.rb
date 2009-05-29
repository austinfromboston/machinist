require File.dirname(__FILE__) + '/spec_helper'
require 'machinist/data_mapper'

module MachinistDataMapperSpecs
  
  class Person
    include DataMapper::Resource
    property :id,       Serial
    property :name,     String
    property :type,     String
    property :password, String
    property :admin,    Boolean, :default => false
  end

  class Post
    include DataMapper::Resource
    property :id,        Serial
    property :title,     String
    property :body,      Text
    property :published, Boolean, :default => true
    has n, :comments
  end

  class Comment
    include DataMapper::Resource
    property :id,        Serial
    property :post_id,   Integer
    property :author_id, Integer
    belongs_to :post
    belongs_to :author, :class_name => "Person", :child_key => [:author_id]
  end

  describe Machinist, "DataMapper adapter" do  
    before(:suite) do
      DataMapper::Logger.new(File.dirname(__FILE__) + "/log/test.log", :debug)
      DataMapper.setup(:default, "sqlite3::memory:")
      DataMapper.auto_migrate!
    end

    before(:each) do
      Person.clear_blueprints!
      Post.clear_blueprints!
      Comment.clear_blueprints!
    end

    describe "make method" do 
      it "should save the constructed object" do
        Person.blueprint { }
        person = Person.make
        person.should_not be_new_record
      end
  
      it "should create an object through belongs_to association" do
        Post.blueprint { }
        Comment.blueprint { post }
        Comment.make.post.class.should == Post
      end

      it "should create an object through belongs_to association with a class_name attribute" do
        Person.blueprint { }
        Comment.blueprint { author }
        Comment.make.author.class.should == Person
      end

      it "should raise an exception if the object can't be saved"
    end

      describe "make_unsaved method" do
      it "should not save the constructed object" do
        Person.blueprint { }
        person = Person.make_unsaved
        person.should be_new_record
      end
  
      it "should not save associated objects" do
        Post.blueprint { }
        Comment.blueprint { post }
        comment = Comment.make_unsaved
        comment.post.should be_new_record
      end
  
      it "should save objects made within a passed-in block" do
        Post.blueprint { }
        Comment.blueprint { }
        comment = nil
        post = Post.make_unsaved { comment = Comment.make }
        post.should be_new_record
        comment.should_not be_new_record
      end
    end
  
  end
end

