module SimpleCache
  module RailsVersion
    def self.v4?
      ActiveRecord::VERSION::MAJOR == 4
    end

    def self.v42?
      rails4? && ActiveRecord::VERSION::MINOR == 2
    end

    def self.v50?
      ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR == 0
    end

    def self.atleast_v50?
      ActiveRecord::VERSION::MAJOR >= 5
    end

    def self.v51?
      ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR == 1
    end

    def self.v52?
      ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR == 2
    end

    def self.atleast_v51?
      ActiveRecord::VERSION::MAJOR > 5 || (ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR >= 1)
    end

    def self.atleast_v52?
      ActiveRecord::VERSION::MAJOR > 5 || (ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR > 1)
    end
  end
end
