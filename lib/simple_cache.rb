require "simple_cache/version"
require "active_record"
require "active_support/core_ext/module/attribute_accessors"
require "simple_cache/helpable"
require "simple_cache/auto_update"
require "simple_cache/has_many"
require "simple_cache/has_one"
require "simple_cache/find"

module SimpleCache
  extend ActiveSupport::Concern
  include SimpleCache::Helpable
  include SimpleCache::HasMany
  include SimpleCache::HasOne
  include SimpleCache::Find

  def self.store
    @store ||= ActiveSupport::Cache::MemCacheStore.new
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

  def self.sanitize(options)
    options.delete(:cache)
    options || {}
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
end

class ActiveRecord::Base
  include SimpleCache::AutoUpdate
  include SimpleCache
end
