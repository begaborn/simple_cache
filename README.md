# What's Simple Cache
Simple Cache stores your model objects, which is associated with a base model, into Memcached. Memcached is used as the backend cache store, and if they are not in the Memcached(a cache miss), they will be loaded from the database.

If you commit transactions in your program, the model objects will be removed from Memcached and retrieved from the database again.

# How it works 
Just only add this Gem! Nothing more needs to be done! 

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

At first, the `players` objects, which is associated with `user` object, will be retrieved from the database when executing the following code. At the same time, the `players` objects will be stored in Memcached.

When executing the following code, `players` objects will be retrieved from Memcached, not database.
```
User.take.players
```


<img width="643" alt="screen shot 2018-11-12 at 8 01 53 pm" src="https://user-images.githubusercontent.com/12689917/48343478-d4e44980-e6b5-11e8-90ad-b75e3356c9c9.png">


# Notes
1. If you specify options besides the following values for `has_many` or `has_one`, the model objects wll not be cached in Memcached.
```
:class_name, :foreign_key, :dependent, :counter_cache, :auto_save, :extend
```

2. Only stored the objects associated by `has_many` or `has_one`, not supported `belongs_to`, `has_and_belongs_to_many`.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/begaborn/simple_cache. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
