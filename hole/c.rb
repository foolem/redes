class Client
  require "socket"

  def initialize
    @server_port = 50000
    @client_port = 60000

    @try = 0
    connect
  end

  def connect
    puts "Tentando conexão..."

    begin
      @socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)

      in_addr = Socket.pack_sockaddr_in(@client_port, "200.0.0.1")
      @socket.bind(in_addr)
      out_addr = Socket.pack_sockaddr_in(@server_port, "200.0.0.2")
      @socket.connect(out_addr)

      puts "DEU CERTO"
      @socket.puts "HELLO"
      puts "Answare: #{@socket.gets.chomp}"
      @socket.close

    rescue
      puts "Retry"
      retry if (@try += 1) < 50000
    end

    puts "Chega!"
  end

end

Client.new
