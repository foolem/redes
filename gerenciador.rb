class Gerenciador
  require "socket"

  def initialize

    @server = TCPServer.open(5151)
    loop do
      Thread.fork(@server.accept) do |client|
        puts "Nova conexão"
        request = client.gets.chomp
        puts "#{request}"
        client.puts "fodac"
       end
     end
   end

 end

 Gerenciador.new
