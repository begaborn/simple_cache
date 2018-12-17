RSpec.describe SimpleCache::BelongsTo do
  describe "When you include SimpleCache::BelongsTo" do
    let(:player) { Player.take }
    let(:item) { Item.take }

    context "when option 'cache' is true" do
      let(:cache_key) { "simple_cache:user.#{player.user_id}.has_many.Player" }

      subject { player.user }

      it { is_expected.to be_an(User) }

      it { is_expected.to eq(User.find(player.user_id)) }

      it "should cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        subject
        expect(SimpleCache.store.read(cache_key)).to eq(player.user)
      end

      context "after committing a transaction" do
        let(:changed_name) { 'changed name' }

        subject do
          object_with_cache = player.user
          object_with_cache.name = changed_name
          object_with_cache.save!
          player.user
        end

        it "should remove the association objects from the cache store" do
          subject
          expect(SimpleCache.store.read(cache_key)).to be_nil
        end

        its(:name) { is_expected.to eq(changed_name) }
      end

      context "when updating the objects" do

        let(:changed_name) { 'changed name' }

        subject do
          object_with_cache = player.user
          object_with_cache.name = changed_name
          object_with_cache.save!
          Player.take.user
        end

        its(:name) { is_expected.to eq(changed_name) }

        it "should cache the association objects" do
          expect(SimpleCache.store.read(cache_key)).to be_nil
          cached_objects = subject
          expect(SimpleCache.store.read(cache_key)).to eq(cached_objects)
        end
      end
    end

    context "when specifying the options 'class_name' + 'foreign_key' and scope " do

      let(:cache_key) { "simple_cache:player.#{item.hero.id}.has_many.Item" }

      subject { item.hero }

      it { is_expected.to be_an(Player) }

      it { is_expected.to eq(Player.find(item.hero.id)) }

      it "should cache the association objects" do
        subject
        expect(SimpleCache.store.read(cache_key)).to eq(item.hero)
      end

      context "after committing a transaction" do

        let(:changed_name) { 'changed name' }

        subject do
          object_with_cache = item.hero
          object_with_cache.name = changed_name
          object_with_cache.save!
          item.hero
        end

        it "should remove the association objects from the cache store" do
          subject
          expect(SimpleCache.store.read(cache_key)).to be_nil
        end

        its(:name) { is_expected.to eq(changed_name) }
      end

      context "when updating the objects" do

        let(:changed_name) { 'changed name' }

        subject do
          object_with_cache = item.hero
          object_with_cache.name = changed_name
          object_with_cache.save!
          Item.take.hero
        end

        its(:name) { is_expected.to eq(changed_name) }

        it "should cache the association objects" do
          cached_objects = subject
          expect(SimpleCache.store.read(cache_key)).to eq(cached_objects)
        end
      end
    end
  end
end
