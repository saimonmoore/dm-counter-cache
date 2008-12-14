module DataMapper
  # CounterCacheable allows you to transparently maintain counts on collection association of this model on the parent model.
  # You can also specify a custom counter cache column by providing a column name instead of a true/false value 
  # to this option (e.g., :counter_cache => :my_custom_counter.)
  module CounterCacheable

    def self.included(klass)      
      DataMapper::Associations::ManyToOne.module_eval {
        extend DataMapper::CounterCacheable::ClassMethods
        (class << self; self; end).class_eval do
          alias_method :setup_without_counter_caching, :setup
          alias_method :setup, :setup_with_counter_caching
        end
      }
    end

    module ClassMethods
      
      def setup_with_counter_caching(name, model, options = {})
        counter_cache_attribute = options.delete(:counter_cache)
        relationship = setup_without_counter_caching(name, model, options)
        
        if counter_cache_attribute
          case counter_cache_attribute
            when String, Symbol
              counter_cache_attribute = counter_cache_attribute.intern
            else
              counter_cache_attribute = "#{model.storage_name}_count".intern
          end

          relationship.parent_model.class_eval <<-EOS, __FILE__, __LINE__
            property :#{counter_cache_attribute}, Integer, :default => 0, :lazy => false          
          EOS
          
          parent_name = relationship.parent_model.name.downcase

          model.class_eval <<-EOS, __FILE__, __LINE__            
            after :create, :increment_counter_cache_for_#{parent_name}
            after :destroy, :decrement_counter_cache_for_#{parent_name}
          
            def increment_counter_cache_for_#{parent_name}
              self.#{parent_name}.update_attributes(:#{counter_cache_attribute} => self.#{parent_name}.#{counter_cache_attribute}.succ)
            end

            def decrement_counter_cache_for_#{parent_name}
              self.#{parent_name}.update_attributes(:#{counter_cache_attribute} => self.#{parent_name}.#{counter_cache_attribute} - 1)
            end
            
          EOS
        end

        relationship
      end

    end # ClassMethods

  end # CounterCacheable
end # DataMapper

if $0 == __FILE__
  require 'rubygems'

  gem 'dm-core', '~>0.9.8'
  require 'dm-core'

  FileUtils.touch(File.join(Dir.pwd, "migration_test.db"))
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/migration_test.db")

  class Post
    include DataMapper::Resource

    property :id, Integer, :serial => true
    has n, :comments
  end
  Post.auto_migrate!
  
  class Comment
    include DataMapper::Resource
    include DataMapper::CounterCacheable

    belongs_to :post, :counter_cache => true
  end
  Comments.auto_migrate!

  Post.create.comments.create
end
