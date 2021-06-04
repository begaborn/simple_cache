RSpec.describe SimpleCache::HasMany do
  describe "When you include SimpleCache::HasMany" do
    let(:user) { User.take }

    context "when option 'cache' is false" do
      let(:cache_key) { user.simple_cache_association_key(:credit_cards) }

      subject { user.credit_cards }

      it { is_expected.to be_an(ActiveRecord::Associations::CollectionProxy) }

      its(:size) { is_expected.to eq(User.take.credit_cards.size) }

      its(:first) { is_expected.to be_an(CreditCard) }

      it "should not cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        subject
        expect(SimpleCache.store.read(cache_key)).to be_nil
      end
    end

    context "when using cache" do
      let(:cache_key) { "#{user.simple_cache_association_key(:players)}:ids" }
      let(:org_name) { user.players.first.name }
      let(:changed_name) { 'changed name' }
      let!(:org_size) { user.players.size }

      subject { user.cached_player_ids }


      it { is_expected.to eq(user.player_ids) }

      it "should cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        subject
        expect(SimpleCache.store.read(cache_key)).to eq(user.player_ids)
      end
    end

    context "when specifying the options 'class_name' + 'foreign_key' and scope " do
      let(:cache_key) { "#{user.simple_cache_association_key(:p2)}:ids" }
      let(:org_name) { user.p2.first.name }
      let(:changed_name) { 'changed name' }
      let!(:org_size) { user.p2.size }
      let(:player_ids) { user.players.where(is_hero: false).pluck(:id) }

      subject { user.cached_p2_ids }

      it { is_expected.to eq(player_ids) }

      it "should cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        subject
        expect(SimpleCache.store.read(cache_key)).to eq(user.p2_ids)
      end

      context "after committing a transaction" do
        before do
          User.take.cached_p2_ids
        end

        subject do
          Player.create(name: 'test', user: User.take, is_hero: false)
        end

        after do
          Player.last.delete
        end

        it "should remove the association objects from the cache store" do
          expect(SimpleCache.store.read(cache_key).size).to eq(org_size)
          subject
          expect(SimpleCache.store.read(cache_key)).to be_nil
          p2_ids = User.take.p2_ids
          cached_ids = User.take.cached_p2_ids
          expect(cached_ids).to eq(p2_ids)
          expect(SimpleCache.store.read(cache_key)).to eq(p2_ids)
          expect(cached_ids.size).to eq(org_size + 1)
        end
      end
    end

    context "when refreshing the objects after committing by creating" do
      let(:cache_key) { "#{user.simple_cache_association_key(:p2)}:ids" }

      subject do
        User.take.cached_p2_ids
        Player.create(name: 'test', user: User.take, is_hero: false)
        User.take.cached_p2_ids
      end

      after do
        Player.last.delete
      end

      it { is_expected.to eq(user.p2_ids) }

      it "should cache the association objects" do
        cached_ids = subject
        expect(SimpleCache.store.read(cache_key)).to eq(cached_ids)
      end
    end

    context "when refreshing the objects after committing by deleting" do
      let(:cache_key) { "#{user.simple_cache_association_key(:p2)}:ids" }

      subject do
        ActiveRecord::Base.transaction do
          User.take.cached_p2_ids
          p = Player.last
          p.destroy
        end
        User.take.cached_p2_ids
      end

      after do
        Player.create(name: 'test', user: User.take, is_hero: false)
      end

      its(:size) { is_expected.to eq(1) }

      it "should cache the association objects" do
        cached_ids = subject
        player_ids = User.take.p2_ids
        expect(cached_ids).to eq(player_ids)
        expect(SimpleCache.store.read(cache_key)).to eq(player_ids)
      end
    end

    context "while locking" do
      let(:user) { User.take }
      let(:cache_key) { user.simple_cache_association_key(:players) }

      before do
        SimpleCache.cache.lock(cache_key)
      end

      subject { user.players }

      it { is_expected.to be_an(ActiveRecord::Associations::CollectionProxy) }

      its(:size) { is_expected.to eq(User.take.players.size) }

      its(:first) { is_expected.to be_an(Player) }

      it "should not cache the association objects" do
        subject
        expect(SimpleCache.store.read(cache_key)).to eq(SimpleCache::LOCK_VAL)
      end
    end

    context "commit a transaction while locking" do
      let(:user) { User.take }
      let(:cache_key) { "#{user.simple_cache_association_key(:players)}:ids" }

      before do
        SimpleCache.cache.lock(cache_key)
      end

      subject do
        Player.create(name: 'test', user: User.take, is_hero: false)
        User.take.cached_player_ids
      end

      it { is_expected.to eq(User.take.player_ids) }

      it "should not cache the association objects" do
        cached_ids = subject
        expect(SimpleCache.store.read(cache_key)).to eq(cached_ids)
      end
    end

    context "when caching the objects" do
      it "should reduce number of SQL queries after caching" do
        query_count = 0
        thread = Thread.current
        count_up = lambda do |*_args|
          return unless thread == Thread.current
          query_count += 1
        end

        ActiveSupport::Notifications.subscribed(count_up, 'sql.active_record') do
          player = Player.take
          items = player.cached_item_ids
          player = Player.take
          items = player.cached_item_ids # SQL Query wll not be executed because of caching the objects
        end

        expect(query_count).to eq(3)
      end
    end
  end
end
