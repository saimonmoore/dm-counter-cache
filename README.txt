== README

DataMapper::CounterCacheable automates the dec/incrementing of association counter fields. This is
similar to counter caches in ActiveRecord.

Example:

class Post
  include DataMapper::Resource

  has n :comments

  property :id, Integer, :serial => true
  property :comments_count, Integer, :default => 0
end

class Comment
  include DataMapper::Resource
  include DataMapper::CounterCacheable  

  belongs_to :post, :counter_cache => true

end
