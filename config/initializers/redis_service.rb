class RedisService
    def self.config
      config = {
        url: ENV['CACHE_1_URL'] || 'redis://localhost:6379',
        reconnect_attempts: 20,
        reconnect_delay: 0.2,
        reconnect_delay_max: 15,
      }
    end
  
    def self.instance
      @_redis_service_instance ||= Redis.new(config)
    end
  end
  