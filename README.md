# What's Simple Cache?
Simple Cache stores your model objects, associated with a base model, into a Memcached. If he model objects are in the Memcached(a cache hit), they will be loaded from Memcached instead of the database. If you commit a transaction in your program, the model objects will be removed from Memcached and retrieved from the database again.

# How it works 
Only just add this Gem! Nothing more needs to be done! 

## Install
Add this line to Gemfile:

```
gem 'ar-simple-cache', github: 'begaborn/simple_cache'
```
Currently, SimpleCache support Rails 4.2 or later. 


```
bundle install
```

# Principle 
Let's say there are the following two models. 
```ruby:user.rb
class User < ApplicationRecord
  has_many :players
end
``` 
```ruby:player.rb
class Player < ApplicationRecord
end
``` 

At first, the `players` objects, which are associated with `user` object, will be retrieved from the database when executing the following code. At the same time, the `players` objects will be stored in the Memcached.

When executing the following code again, `players` objects will be retrieved from the Memcached, not database.
```
User.take.players
```


<img width="643" alt="screen shot 2018-11-12 at 8 01 53 pm" src="https://user-images.githubusercontent.com/12689917/48343478-d4e44980-e6b5-11e8-90ad-b75e3356c9c9.png">


# Notes
1. If you specify options for `has_many` or `has_one` except the following values, the model objects wll not be cached in the Memcached.
```
:class_name, :foreign_key, :dependent, :counter_cache, :auto_save, :extend
```

2. Only objects associated with `has_many` or `has_one` will be stored and `belongs_to` or `has_and_belongs_to_many` is not supported.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/begaborn/simple_cache. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
