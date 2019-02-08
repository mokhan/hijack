#app = lambda do |env|
#io = env['rack.hijack_io']
#begin
#io.write("Status: 200\r\n")
#io.write("Connection: close\r\n")
#io.write("Content-Type: text/plain\r\n")
#io.write("\r\n")
#10.times do |i|
#io.write("Line #{i + 1}!\n")
#io.flush
#sleep 1
#end
#ensure
#io.close
#end
#end

#run app

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
