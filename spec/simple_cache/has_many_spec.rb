RSpec.describe SimpleCache::HasMany do
  describe "When you include SimpleCache::HasMany" do
    let(:user) { User.take }

    context "when option 'cache' is false" do
      let(:cache_key) { user.cache_key_by(:credit_cards) }

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
      let(:cache_key) { user.cache_key_by(:players) }

      subject { user.players }

      it { is_expected.to be_an(ActiveRecord::Associations::CollectionProxy) }

      its(:size) { is_expected.to eq(User.take.players.size) }

      its(:first) { is_expected.to be_an(Player) }

      it "should cache the association objects" do
        expect(SimpleCache.store.read(user.cache_key_by(:players))).to be_nil
        subject
        expect(SimpleCache.store.read(user.cache_key_by(:players))).to eq(user.players)
      end

      context "after committing a transaction" do
        let(:org_name) { user.players.first.name }
        let(:changed_name) { 'changed name' }
        let(:org_size) { user.players.size }

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
          expect(SimpleCache.store.read(user.cache_key_by(:players))).to be_nil
        end

        its(:name) { is_expected.to eq(changed_name) }

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
            expect(SimpleCache.store.read(user.cache_key_by(:players))).to be_nil
            cached_objects = subject
            expect(SimpleCache.store.read(user.cache_key_by(:players))).to eq(cached_objects)
          end
        end
      end
    end

    context "when specifying the options 'class_name' + 'foreign_key' and scope " do
      let(:cache_key) { user.cache_key_by(:p2) }

      subject { user.p2.first }

      it { is_expected.to be_an(Player) }

      its(:is_hero) { is_expected.to be_falsey }

      it "should cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        subject
        expect(SimpleCache.store.read(cache_key)).to eq(user.p2)
      end

      context "after committing a transaction" do
        let(:org_name) { user.p2.first.name }
        let(:changed_name) { 'changed name' }
        let(:org_size) { user.p2.size }

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
    end

    context "when specifying a block" do
      let(:cache_key) { user.cache_key_by(:p1) }

      subject { user.p1.hero }

      it { is_expected.to be_an(Player) }

      its(:is_hero) { is_expected.to be_truthy }

      it "should cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        subject
        expect(SimpleCache.store.read(cache_key)).to eq(user.p1)
      end

      context "after committing a transaction" do
        let(:org_name) { user.p1.hero.name }
        let(:changed_name) { 'changed name' }
        let(:org_size) { user.p1.size }

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
    end

    context "while locking" do
      let(:user) { User.take }
      let(:cache_key) { user.cache_key_by(:players) }

      before do
        allow(user).to receive(:cachable?).and_return(false)
      end

      subject { user.players }

      it { is_expected.to be_an(ActiveRecord::Associations::CollectionProxy) }

      its(:size) { is_expected.to eq(User.take.players.size) }

      its(:first) { is_expected.to be_an(Player) }

      it "should not cache the association objects" do
        subject
        expect(SimpleCache.store.read(cache_key)).to be_nil
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

        "Number of SQL Queries = #{query_count}"
        expect(query_count).to eq(3)
      end
    end
  end
end
