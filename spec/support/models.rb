class Account < ActiveRecord::Base
  belongs_to :user
end

class Weapon < ActiveRecord::Base
  has_one :item, as: :item
  belongs_to :player
end

class Weapon::Armor < Weapon
end

class Weapon::Sword < Weapon
end

class Potion < ActiveRecord::Base
  has_one :item, as: :item
end

class Item < ActiveRecord::Base
  belongs_to :player
  belongs_to :hero, ->(o) { where(is_hero: true) }, class_name: :Player, foreign_key: :player_id
  belongs_to :item, polymorphic: true
end

class CreditCard < ActiveRecord::Base
  belongs_to :user
  has_one    :previous, class_name: 'CreditCard', foreign_key: 'after_id'
end

class Player < ActiveRecord::Base
  has_many   :items
  belongs_to :user
  use_find_cache false
end

class User < ActiveRecord::Base
  has_many :players
  has_many :p1, class_name: :Player do
    def hero
      find_by(is_hero: true)
    end
  end

  has_many :p2, -> { where(is_hero: false) }, class_name: :Player, foreign_key: :user_id
  #has_many :credit_cards, cache: false
  has_one  :account, cache: false
  has_one  :account_with_cache, class_name: :Account
end
