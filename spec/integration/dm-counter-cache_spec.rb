require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::CounterCacheable do
  before :all do
    class Post
      include DataMapper::Resource

      property :id, Integer, :serial => true
      property :comments_count, Integer, :default => 0
      has n, :comments
    end
    
    class Comment
      include DataMapper::Resource
      include DataMapper::CounterCacheable  

      property :id, Integer, :serial => true
      belongs_to :post, :counter_cache => true

    end
    
    class User
      include DataMapper::Resource

      property :id, Integer, :serial => true
      property :groups_count, Integer, :default => 0      

      has n, :group_memberships
      has n, :groups, :through => :group_memberships, :class_name => "Group", :remote_name => :group, :parent_key => [:id], :child_key => [:user_id]
    end
    
    class Group
      include DataMapper::Resource

      property :id, Integer, :serial => true
      property :members_count, Integer, :default => 0
      has n, :group_memberships
      has n, :members, :through => :group_memberships, :class_name => "User", :remote_name => :user, :parent_key => [:id], :child_key => [:group_id]
    end

    class GroupMembership
      include DataMapper::Resource
      include DataMapper::CounterCacheable

      property :id, Serial

      belongs_to :group, :counter_cache => :members_count
      belongs_to :member, :class_name => "User", :child_key => [:user_id], :counter_cache => :groups_count
    end    

    GroupMembership.auto_migrate!
    User.auto_migrate!
    Group.auto_migrate!
    Comment.auto_migrate!
    Post.auto_migrate!
  end

  before(:each) do
    @post = Post.create
    @user = User.create
    @group = Group.create
  end

  it "should increment comments_count" do
    @post.comments.create
    @post.reload.comments_count.should == 1
    
    @user.group_memberships.create(:group => @group)
    @user.reload.groups_count.should == 1
    @group.reload.members_count.should == 1
  end

  it "should decrement comments_count" do
    comment1 = @post.comments.create    
    comment2 = @post.comments.create
    comment2.destroy
    @post.reload.comments_count.should == 1
    
    gm1 = @user.group_memberships.create(:group => @group)
    gm2 = @user.group_memberships.create(:group => @group)
    gm2.destroy
    @user.reload.groups_count.should == 1
    @group.reload.members_count.should == 1    
  end

end
