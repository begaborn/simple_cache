RSpec.describe SimpleCache::HasOne do
  describe "When you include SimpleCache" do
    it "should store the objects when option 'cache' is nil(default)" do
      user = User.take
      object_with_cache = user.account
      expect(object_with_cache).to be_an(Account)
      expect(SimpleCache.store.read(user.cache_key_by(:account))).to eq(object_with_cache) 
    end

    it "should reduce number of SQL queries after caching" do
      query_count = 0
      thread = Thread.current
      count_up = lambda do |*_args|
        return unless thread == Thread.current
        query_count += 1
      end

      ActiveSupport::Notifications.subscribed(count_up, 'sql.active_record') do
        user = User.take
        user.account
        user = User.take
        user.account
      end

      "Number of SQL Queries = #{query_count}"
      expect(query_count).to eq(3) 
    end
  end

  describe "When a transaction is committed" do
    it "should remove the objects from the cache and store the objects into the cache the objects after committing transaction" do
      user = User.take        
      user.account.name = 'after commit'
      expect(SimpleCache.store.read(user.cache_key_by(:account))).to eq(user.account)
      user.account.save!

      expect(SimpleCache.store.read(user.cache_key_by(:account))).to be_nil

      user = User.take
      expect(user.account.name).to eq('after commit')
    end
  end
end
