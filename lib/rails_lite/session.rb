require 'json'
require 'webrick'
require 'debugger'
class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req) 
    @my_cookie = req.cookies.find { |cookie| cookie.name == '_rails_lite_app'}
    if @my_cookie
      @session = JSON.parse(@my_cookie.value)
    else
      @session = {}
    end
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  
  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @session.to_json)
  end
end
