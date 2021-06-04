# What's Simple Cache?
Simple Cache is a library which caches the model objects and their associations.
It's simple! Nothing needs to be done to cache and refresh the model objects!

Let's say there are the following two models with a one-to-many relationship.
```ruby:user.rb
class User < ApplicationRecord
  has_one_cached :player
end
```
```ruby:player.rb
class Player < ApplicationRecord
end
```

At first, the `player` object, which are the `user` object's associations, will be retrieved from the database when executing the following sample snippet. At the same time, the `player` object ids will be stored in the Memcached automatically.
When executing the following code again, `player` object ids will be retrieved from the Memcached, not the database.
```
User.take.cached_player
```

<img width="643" alt="screen shot 2018-11-12 at 8 01 53 pm" src="https://user-images.githubusercontent.com/12689917/48343478-d4e44980-e6b5-11e8-90ad-b75e3356c9c9.png">

Simple Cache removes the objects from the Memcached when committing a transaction in your program, to keep them up-to-date.
Then they are retrieved from the database and stored onto the Memcached again.

## Install
Add this line to Gemfile:
```
gem 'ar-simple-cache', github: 'begaborn/simple_cache'
```
Currently, SimpleCache supports Rails 4.2 or later.

```
bundle install
```

# Usage
## Cache the object for `find`
```ruby:user.rb
class User < ApplicationRecord
  use_find_cache # Delare that you'll use method 'find_cache'
end

User.find_cache(1)
```

## Cache the association object for `has_one`
```ruby:user.rb
class User < ActiveRecord::Base
  has_one_cached :account
end

User.take.cached_account

```

## Cache the association objects for `has_many`
```ruby:user.rb
class User < ActiveRecord::Base
  has_many_cached_ids_of :players
end

User.cached_player_ids
# => [1, 2, 3] # Array [Player's ids]
```

## Cache the association object for `belongs_to`
```ruby:user.rb
class Player < ActiveRecord::Base
  belongs_to_cached :user
end
```

# Notes
1. If any option below is specified for `has_many`, `has_one`, `belongs_to` the model objects will not be cached.
```
:as, :through, :primary_key, :source, :source_type, :inverse_of, :polymorphic
```

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/begaborn/simple_cache. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
