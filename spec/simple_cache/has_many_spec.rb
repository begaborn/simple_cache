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
      let(:cache_key) { user.simple_cache_association_key(:players) }
      let(:org_name) { user.players.first.name }
      let(:changed_name) { 'changed name' }
      let(:org_size) { user.players.size }

      subject { user.players }

      it { is_expected.to be_an(ActiveRecord::Associations::CollectionProxy) }

      its(:size) { is_expected.to eq(User.take.players.size) }

      its(:first) { is_expected.to be_an(Player) }

      it "should cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        subject
        expect(SimpleCache.store.read(cache_key)).to eq(user.players)
      end

      context "after committing a transaction" do
        subject do
          objects_with_cache = user.players
          objects_with_cache.first.name = changed_name
          objects_with_cache.first.save!
          user.players.first
        end

        after do
          user.players.first.name = org_name
          user.players.first.save!
        end

        it "should remove the association objects from the cache store" do
          subject
          expect(SimpleCache.store.read(cache_key)).to be_nil
        end

        its(:name) { is_expected.to eq(changed_name) }
      end

      context "when reloading the objects again" do
        subject do
          objects_with_cache = user.players
          objects_with_cache.first.name = changed_name
          objects_with_cache.first.save!
          User.take.players
        end

        its(:size) { is_expected.to eq(org_size) }

        it "should change the name" do
          expect(subject.first.name).to eq(changed_name)
        end

        it "should cache the association objects" do
          expect(SimpleCache.store.read(cache_key)).to be_nil
          cached_objects = subject
          expect(SimpleCache.store.read(cache_key)).to eq(cached_objects)
        end
      end
    end

    context "when specifying the options 'class_name' + 'foreign_key' and scope " do
      let(:cache_key) { user.simple_cache_association_key(:p2) }
      let(:org_name) { user.p2.first.name }
      let(:changed_name) { 'changed name' }
      let(:org_size) { user.p2.size }

      subject { user.p2.first }

      it { is_expected.to be_an(Player) }

      its(:is_hero) { is_expected.to be_falsey }

      it "should cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        subject
        expect(SimpleCache.store.read(cache_key)).to eq(user.p2)
      end

      context "after committing a transaction" do
        subject do
          user.p2.first.name = changed_name
          user.p2.first.save!
          user.p2.first
        end

        after do
          user.p2.first.name = org_name
          user.p2.first.save!
        end

        it "should remove the association objects from the cache store" do
          subject
          expect(SimpleCache.store.read(cache_key)).to be_nil
        end

        its(:name) { is_expected.to eq(changed_name) }
      end

      context "when reloading the objects again" do
        subject do
          user.p2.first.name = changed_name
          user.p2.first.save!
          User.take.p2
        end

        its(:size) { is_expected.to eq(org_size) }

        it "should change the name" do
          expect(subject.first.name).to eq(changed_name)
        end

        it "should cache the association objects" do
          expect(SimpleCache.store.read(cache_key)).to be_nil
          cached_objects = subject
          expect(SimpleCache.store.read(cache_key)).to eq(cached_objects)
        end
      end
    end

    context "when refreshing the objects after committing by creating" do
      let(:cache_key) { user.simple_cache_association_key(:p2) }

      subject do
        User.take.p2
        Player.create(name: 'test', user: User.take, is_hero: false)
        User.take.p2
      end

      after do
        Player.last.delete
      end

      its(:size) { is_expected.to eq(3) }

      it "should cache the association objects" do
        cached_objects = subject
        expect(SimpleCache.store.read(cache_key)).to eq(cached_objects)
      end
    end

    context "when refreshing the objects after committing by deleting" do
      let(:cache_key) { user.simple_cache_association_key(:p2) }

      subject do
        ActiveRecord::Base.transaction do
          User.take.p2
          p = Player.last
          p.destroy
        end
        User.take.p2
      end

      after do
        Player.create(name: 'test', user: User.take, is_hero: false)
      end

      its(:size) { is_expected.to eq(1) }

      it "should cache the association objects" do
        cached_objects = subject
        expect(SimpleCache.store.read(cache_key)).to eq(cached_objects)
      end
    end

    context "when specifying a block" do
      let(:cache_key) { user.simple_cache_association_key(:p1) }
      let(:org_name) { user.p1.hero.name }
      let(:changed_name) { 'changed name' }
      let(:org_size) { user.p1.size }

      subject { user.p1.hero }

      it { is_expected.to be_an(Player) }

      its(:is_hero) { is_expected.to be_truthy }

      it "should cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        subject
        expect(SimpleCache.store.read(cache_key)).to eq(user.p1)
      end

      context "after committing a transaction" do
        subject do
          user.p1.hero.name = changed_name
          user.p1.hero.save!
          user.p1.hero
        end

        after do
          user.p1.hero.name = org_name
          user.p1.hero.save!
        end

        it "should remove the association objects from the cache store" do
          subject
          expect(SimpleCache.store.read(cache_key)).to be_nil
        end

        its(:name) { is_expected.to eq(changed_name) }
      end

      context "when reloading the objects again" do
        subject do
          user.p1.hero.name = changed_name
          user.p1.hero.save!
          User.take.p1
        end

        its(:size) { is_expected.to eq(org_size) }

        it "should change the name" do
          expect(subject.hero.name).to eq(changed_name)
        end

        it "should cache the association objects" do
          expect(SimpleCache.store.read(cache_key)).to be_nil
          cached_objects = subject
          expect(SimpleCache.store.read(cache_key)).to eq(cached_objects)
        end
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
      let(:cache_key) { user.simple_cache_association_key(:players) }

      before do
        SimpleCache.cache.lock(cache_key)
      end

      subject do
        user.players.first.name = "test name"
        user.players.first.save!
        User.take.players
      end

      it { is_expected.to be_an(ActiveRecord::Associations::CollectionProxy) }

      its(:size) { is_expected.to eq(User.take.players.size) }

      its(:first) { is_expected.to be_an(Player) }

      it "should not cache the association objects" do
        cached_obj = subject
        expect(SimpleCache.store.read(cache_key)).to eq(cached_obj)
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
          items = player.items
          player = Player.take
          items = player.items # SQL Query wll not be executed because of caching the objects
        end

        expect(query_count).to eq(3)
      end
    end
  end
end
