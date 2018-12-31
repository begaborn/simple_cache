module SimpleCache
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

  def self.auto_cache?
    config['auto_cache']
  end

  def self.expires_in
    @expires_in ||= (class_eval(SimpleCache.config['expires_in'] || '') || 1.hours)
  end

end
