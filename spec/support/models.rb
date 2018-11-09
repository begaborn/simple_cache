class Account < ActiveRecord::Base
  belongs_to :user
end

class Weapon < ActiveRecord::Base
  belongs_to :player 
end

class CreditCard < ActiveRecord::Base
  belongs_to :user
end

class Player < ActiveRecord::Base
  has_many   :weapons
  belongs_to :user
end

class User < ActiveRecord::Base
  has_many :weapons, foreign_key: :u_id
  has_many :players
  has_many :p1, class_name: :Player do 
    def hero
      where(is_hero: true)
    end
  end

  has_many :p2, -> { where(is_hero: false) }, class_name: :Player, foreign_key: :user_id 
  has_many :credit_cards, cache: false
  has_one  :account
end
