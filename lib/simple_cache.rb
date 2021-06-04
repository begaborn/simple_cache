require "active_record"
require "active_support/core_ext/module/attribute_accessors"
require "logger"
require "simple_cache/version"
require "simple_cache/config"
require "simple_cache/rails_version"
require "simple_cache/helpable"
require "simple_cache/auto_update"
require "simple_cache/has_many"
require "simple_cache/has_one"
require "simple_cache/belongs_to"
require "simple_cache/find"
require "simple_cache/cache"
require "simple_cache/key_generatable"
require "simple_cache/reflection"

module SimpleCache
  def self.store
    @store ||= defined?(::Rails.cache) ? Rails.cache : ActiveSupport::Cache::MemCacheStore.new
  end

  def self.cache
    @cache ||= SimpleCache::Cache.new
  end

  def self.rails_version
    SimpleCache::RailsVersion
  end

  def self.directory
    @directory ||= defined?(::Rails.root) ? Rails.root.to_s : Dir.pwd
  end

  def self.logger
    @logger ||= defined?(::Rails.logger) ? Rails.logger : Logger.new(STDOUT)
  end

  def self.not_allowed_options
    [:as, :through, :primary_key, :source, :source_type, :polymorphic]
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
    (options.keys & not_allowed_options).size.zero?
  end
end

class ActiveRecord::Base
  @@simple_cache_classses = []

  def self.simple_cache_classses
    @@simple_cache_classses
  end

  def self.add_simple_cache_classses(val)
    @@simple_cache_classses |= [val]
  end

  include SimpleCache::Helpable
  include SimpleCache::KeyGeneratable
  include SimpleCache::AutoUpdate
  include SimpleCache::HasMany
  include SimpleCache::HasOne
  include SimpleCache::BelongsTo
  include SimpleCache::Find
end
