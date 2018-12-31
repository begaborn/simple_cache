class Account < ActiveRecord::Base
  belongs_to :user
end

class Weapon < ActiveRecord::Base
  has_one :item, as: :item, cache: true
  belongs_to :player, cache: true
end

class Weapon::Armor < Weapon
end

class Weapon::Sword < Weapon
end

class Potion < ActiveRecord::Base
  has_one :item, as: :item, cache: true
end

class Item < ActiveRecord::Base
  belongs_to :player, cache: true
  belongs_to :hero, ->(o) { where(is_hero: true) }, class_name: :Player, foreign_key: :player_id, cache: true
  belongs_to :item, polymorphic: true, cache: true
end

class CreditCard < ActiveRecord::Base
  belongs_to :user, cache: true
  has_one    :previous, class_name: 'CreditCard', foreign_key: 'after_id', cache: true
end

class Player < ActiveRecord::Base
  has_many   :items, cache: true
  belongs_to :user, cache: true
end

class User < ActiveRecord::Base
  find_method_use_cache
  has_many :players, cache: true
  has_many :p1, class_name: :Player, cache: true do
    def hero
      find_by(is_hero: true)
    end
  end

  has_many :p2, -> { where(is_hero: false) }, class_name: :Player, foreign_key: :user_id, cache: true
  has_many :credit_cards
  has_one  :account
  has_one  :account_with_cache, class_name: :Account, cache: true
end
