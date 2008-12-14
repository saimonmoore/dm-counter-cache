require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::CounterCacheable do
  before :all do
    class Post
      include DataMapper::Resource

      property :id, Integer, :serial => true
      has n, :comments
    end
    
    class Comment
      include DataMapper::Resource
      include DataMapper::CounterCacheable  

      property :id, Integer, :serial => true
      belongs_to :post, :counter_cache => true

    end
    
    Comment.auto_migrate!
    Post.auto_migrate!
  end

  before(:each) do
    @post = Post.create
  end

  it "should increment comments_count" do
    @post.comments.create
    @post.reload.comments_count.should == 1
  end

  it "should decrement comments_count" do
    comment1 = @post.comments.create    
    comment2 = @post.comments.create
    comment2.destroy
    @post.reload.comments_count.should == 1
  end

end
