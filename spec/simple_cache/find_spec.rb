RSpec.describe SimpleCache::Find do
  describe "When you include SimpleCache::Find" do
    let(:user) { User.take }
    let(:cache_key) { SimpleCache.key(User, user.id, :find) }

    let(:org_name) { user.players.first.name }
    let(:changed_name) { 'changed name' }

    context "when parameter is not array and one" do

      subject { User.find(user.id) }

      it { is_expected.to be_an(User) }

      its(:id) { is_expected.to eq(user.id) }

      it "should cache the object" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        cached_object = subject
        expect(SimpleCache.store.read(cache_key)).to eq(cached_object)
      end
    end

    context "after committing a transaction" do

      before do
        User.find(user.id)
      end

      subject do
        user.name = changed_name
        user.save!
      end

      after do
        user.name = org_name
        user.save!
      end

      it "should remove the object from the cache store" do
        expect(SimpleCache.store.read(cache_key)).to eq(user)
        subject
        expect(SimpleCache.store.read(cache_key)).to be_nil
      end
    end

    context "when reloading the objects again" do
      subject do
        user.name = changed_name
        user.save!
        User.find(user.id)
      end

      it { is_expected.to eq(user) }

      its(:name) { is_expected.to eq(changed_name) }

      it "should remove the object from the cache store" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        cached_object = subject
        expect(SimpleCache.store.read(cache_key)).to eq(cached_object)
      end
    end
  end
end
