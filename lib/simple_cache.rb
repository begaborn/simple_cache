require "simple_cache/version"
require "active_record"
require "active_support/core_ext/module/attribute_accessors"
require "simple_cache/helpable"
require "simple_cache/auto_update"
require "simple_cache/has_many"
require "simple_cache/has_one"
require "simple_cache/belongs_to"
require "simple_cache/find"
require "simple_cache/cache"
require "simple_cache/key_generatable"
require "simple_cache/reflection"
require "simple_cache/reflection/association"
require "simple_cache/reflection/inverse_association"
require "logger"

module SimpleCache

  LOCK_VAL = -1

  mattr_accessor :cache_namespace
  self.cache_namespace = "SC:#{CACHE_VERSION}".freeze

  def self.store
    @store ||= ActiveSupport::Cache::MemCacheStore.new
  end

  def self.cache
    @cache ||= SimpleCache::Cache.new
  end

  def self.config
    @config ||= begin
      file_name = File.join(SimpleCache.directory, 'config/simple_cache.yml').to_s

      if File.exist?(file_name) || File.symlink?(file_name)
        config ||= HashWithIndifferentAccess.new(YAML.load(ERB.new(File.read(file_name)).result))['cache']
      else
        config ||= HashWithIndifferentAccess.new
      end

      config
    end
  end

  def self.directory
    @directory ||= defined?(::Rails.root) ? Rails.root.to_s : Dir.pwd
  end

  def self.auto_cache?
    @auto_cache ||= (config['auto_cache'].nil? || config['auto_cache'])
  end

  def self.expires_in
    @expires_in ||= (class_eval(SimpleCache.config['expires_in'] || '') || 1.hours)
  end

  def self.not_allowed_options
    [:as, :through, :primary_key, :source, :source_type, :inverse_of, :polymorphic]
  end

  def self.logger
    @logger ||= defined?(::Rails.logger) ? Rails.logger : Logger.new(STDOUT)
  end

  def self.rails4?
    ActiveRecord::VERSION::MAJOR == 4
  end

  def self.rails42?
    rails4? && ActiveRecord::VERSION::MINOR == 2
  end

  def self.rails50?
    ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR == 0
  end

  def self.atleast_rails50?
    ActiveRecord::VERSION::MAJOR >= 5
  end

  def self.rails51?
    ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR == 1
  end

  def self.rails52?
    ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR == 2
  end

  def self.atleast_rails51?
    ActiveRecord::VERSION::MAJOR > 5 || (ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR >= 1)
  end

  def self.atleast_rails52?
    ActiveRecord::VERSION::MAJOR > 5 || (ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR > 1)
  end

  def self.sanitize(scope, options)
    org_options = {}
    if options == {} && scope.is_a?(Hash)
      org_options = scope.dup
      scope.delete(:cache)
    else
      org_options = options.dup
      options.delete(:cache)
    end
    org_options
  end

  def self.use?(options = {})
    if auto_cache?
      (options[:cache].nil? || options[:cache])
    else
      (options[:cache].present? && options[:cache])
    end && (options.keys & not_allowed_options).size.zero?
  end

  def self.cachable?(kls, id, method_name)
    store.read(key(kls, id, method_name)) != -1
  end

  def self.delete(kls, id, method_name)
    store.delete(key(kls, id, method_name))
  end

  def self.lock(kls, id, method_name)
    store.write(key(kls, id, method_name), -1, expires_in: 2.minutes)
  end

  def self.key(kls, id, method_name)
    "simple_cache:#{kls.name.split('::').first.underscore}.#{id}.#{method_name}"
  end
end

class ActiveRecord::Base
  include SimpleCache::Helpable
  include SimpleCache::KeyGeneratable

  if SimpleCache.auto_cache?
    include SimpleCache::AutoUpdate
    include SimpleCache::HasMany
    include SimpleCache::HasOne
    include SimpleCache::BelongsTo
    include SimpleCache::Find
  end
end
