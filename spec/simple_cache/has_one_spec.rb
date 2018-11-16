RSpec.describe SimpleCache::HasOne do
  describe "When you include SimpleCache::HasOne" do
    let(:user) { User.take }

    context "when option 'cache' is false" do
      let(:cache_key) { user.cache_key_by(:account) }

      subject { user.account }

      it { is_expected.to be_an(Account) }

      it "should not cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        subject
        expect(SimpleCache.store.read(cache_key)).to be_nil
      end
    end

    context "when specifying option 'class_name' + 'foreing_key'" do
      let(:last_credit_card) { user.credit_cards.last }
      let(:cache_key) { last_credit_card.cache_key_by(:previous) }

      subject { last_credit_card.previous }

      it { is_expected.to eq(user.credit_cards.first) }

      its(:after_id) { is_expected.to eq(last_credit_card.id) }

      it "should cache the association objects" do
        expect(SimpleCache.store.read(cache_key)).to be_nil
        cached_object = subject
        expect(SimpleCache.store.read(cache_key)).to eq(cached_object)
      end

      context "after committing a transaction" do
        let!(:changed_after_id) { 2 }
        let!(:org_after_id) { last_credit_card.previous.after_id }

        subject do
          last_credit_card.previous.after_id = changed_after_id
          last_credit_card.previous.save!
          last_credit_card.previous
        end

        after do
          last_credit_card.previous.after_id = org_after_id
          last_credit_card.previous.save!
        end

        it "should remove the association objects from the cache store" do
          subject
          expect(SimpleCache.store.read(last_credit_card.cache_key_by(:previous))).to be_nil
        end

        its(:after_id) { is_expected.to eq(changed_after_id) }
      end
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
        user.account_with_cache
        user = User.take
        user.account_with_cache
      end

      "Number of SQL Queries = #{query_count}"
      expect(query_count).to eq(3)
    end
  end
end
