
require 'redis'

redis = Redis.new
redis.publish("ruby", "I love ruby")
