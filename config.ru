require 'rack'
require 'puma'
require 'rack/handler/puma'
require 'redis'

class Application
  attr_reader :redis

  def initialize
    @redis = Redis.new
  end

  def call(env)
    if env['rack.hijack?']
      env['rack.hijack'].call
      io = env['rack.hijack_io']
      redis.subscribe("ruby") do |on|
        on.message do |channel, message|
          puts message.inspect
          io.write(message)
        end
      end
      #Thread.new do
        #loop do
          #sleep 5
          #io.write("I'm awake...")
        #end
      #end
    else
      ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
    end
  end
end

Rack::Handler::Puma.run Application.new
