# What's Simple Cache
Simple Cache put your model objects associated with a base model into Memcached. Memcached is used as the backend cache store, and if the model objects are not in the Memcached(a cache miss), those objects would be loaded from the database.

If you commit transaction in your program, the model objects would be removed from Memcached and loaded from the database again. 

# How it works 
Just only add this Gem! Nothing needs to be done! 

# Notes
- If you specify options besides the following value for `has_many` or `has_one`, the model objects would not be cached in Memcached.
- Only stored the objects associated by `has_many` or `has_one`, not supported `belongs_to`, `has_and_belongs_to_many`.


## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/begaborn/simple_cache. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).