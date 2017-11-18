class Client
  require "socket"

  def initialize
    @server_port = 50000
    @client_port = 60000
    #open_way
    server
  end

  def open_way

    @s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    @s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, 1)

    in_addr = Socket.pack_sockaddr_in(@server_port, "0.0.0.0")
    out_addr = Socket.pack_sockaddr_in(@client_port, "200.0.0.1")

    @s.bind(in_addr)
    @times = 0
    begin
      @s.connect(out_addr)
      puts "Conectei... Não deveria"
    rescue
      puts "Abrindo caminho #{@times}"
      retry if (@times += 1) < 30
    end
    @s.close
  end

  def server

    @server = TCPServer.open(@server_port)
    puts "Listening on: #{@server_port}"

    loop do
      Thread.fork(@server.accept) do |client|
        sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr
        #listener(client)
        puts "Conection accepted..."
        puts client.gets.chomp
        client.puts "Welcome to: #{@server_port}"
        #client.puts "#{remote_ip}:#{remote_port}"
        client.close
      end
    end

  end
end

Client.new
