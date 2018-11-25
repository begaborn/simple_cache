RSpec.describe SimpleCache::Helpable do
  describe "#inverse_reflections" do
    it "should add the associated models to 'inverse_reflections'" do
      user = User.take
      player = user.players.first
      p1 = user.p1
      p2 = user.p2.first
      i1 = player.items.first
      inverse_reflections = Player.inverse_reflections

      expect(inverse_reflections['User'].first[:name]).to eq(:players)
      expect(inverse_reflections['User'].first[:foreign_key]).to eq(:user_id)

      expect(inverse_reflections['User'].second[:name]).to eq(:p1)
      expect(inverse_reflections['User'].second[:foreign_key]).to eq(:user_id)

      expect(inverse_reflections['User'].third[:name]).to eq(:p2)
      expect(inverse_reflections['User'].third[:foreign_key]).to eq(:user_id)
    end
  end

  describe "#use_cache?" do
    subject { SimpleCache.use?(options) }

    describe "When the specified options are not allowed" do
      let(:options) { {through: :subscriptions} }
      it "should be false" do
        expect(subject).to be_falsey
      end
    end

    describe "When the specified options[:cache] is false" do
      let(:options) { {cache: false} }
      it "should be false" do
        expect(subject).to be_falsey
      end
    end

    describe "When the specified options are allowed" do
      let(:options) { {class_name: :Player} }
      it "should be true" do
        expect(subject).to be_truthy
      end
    end
  end
end
