if ENV["REDIS_URL"].present?
  require 'redis'
  Redis.current = Redis.new(thread_safe: true)
end
