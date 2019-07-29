class Account < ActiveRecord::Base
  belongs_to :user
end

class Weapon < ActiveRecord::Base
  has_one_cached :item, as: :item
  belongs_to_cached :player
end

class Weapon::Armor < Weapon
end

class Weapon::Sword < Weapon
end

class Potion < ActiveRecord::Base
  has_one_cached :item, as: :item
end

class Item < ActiveRecord::Base
  belongs_to_cached :player
  belongs_to_cached :hero, ->(o) { where(is_hero: true) }, class_name: :Player, foreign_key: :player_id
  belongs_to_cached :item, polymorphic: true
end

class CreditCard < ActiveRecord::Base
  belongs_to_cached :user
  has_one_cached    :previous, class_name: 'CreditCard', foreign_key: 'after_id'
end


class Player < ActiveRecord::Base
  has_many   :items
  belongs_to_cached :user
end

class User < ActiveRecord::Base
  has_many :players
  has_many :p1, class_name: :Player do
    def hero
      @hero ||= find_by(is_hero: true)
    end
  end

  has_many_cached_ids_of :p2, -> { where(is_hero: false) }, class_name: :Player, foreign_key: :user_id
  has_many :credit_cards
  has_one  :account
  has_one_cached  :account_with_cache, class_name: :Account
end
