require 'webrick'

server = WEBrick::HTTPServer.new(:Port => 8080)

server.mount_proc '/' do |req,res|
  
  res.body = req.path
  res["Content-Type"] = "text/text"
end

trap "INT" do  
  server.shutdown 
end

server.start