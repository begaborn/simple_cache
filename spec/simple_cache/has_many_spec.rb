RSpec.describe SimpleCache::HasMany do
  describe "When you include SimpleCache" do
    it "should not store the objects when option 'cache' is false" do
      user = User.take
      objects_without_cache = user.credit_cards
      expect(objects_without_cache.size).to eq(3)
      expect(objects_without_cache.first).to be_an(CreditCard) 
      expect(SimpleCache.store.read(user.cache_key_by(:credit_cards))).to be_nil
    end

    it "should store the objects when option 'cache' is nil(default)" do
      user = User.take
      objects_with_cache = user.players
      expect(objects_with_cache.size).to eq(3)
      expect(objects_with_cache.first).to be_an(Player)
      expect(SimpleCache.store.read(user.cache_key_by(:players))).to eq(objects_with_cache) 
    end

    it "should reduce number of SQL queries after caching" do
      query_count = 0
      thread = Thread.current
      count_up = lambda do |*_args|
        return unless thread == Thread.current
        query_count += 1
      end

      ActiveSupport::Notifications.subscribed(count_up, 'sql.active_record') do
        player = Player.take 
        weapons = player.weapons
        player = Player.take 
        weapons = player.weapons # SQL Query wll not be executed because of caching the objects
      end

      "Number of SQL Queries = #{query_count}"
      expect(query_count).to eq(3) 
    end
  end

  describe "When a transaction is committed" do
    it "should remove the objects from the cache and store the objects into the cache the objects after committing transaction" do
      user = User.take        
      user.players[0].name = 'after commit'
      expect(SimpleCache.store.read(user.cache_key_by(:players))).to eq(user.players)
      user.players[0].save!

      expect(SimpleCache.store.read(user.cache_key_by(:players))).to be_nil

      user = User.take
      expect(user.players.size).to eq(3)
      expect(user.players[0].name).to eq('after commit')
    end
  end
end
