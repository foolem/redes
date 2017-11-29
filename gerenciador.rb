class Gerenciador
  require "socket"

  def initialize #initialize é a primeira função que o ruby procura
    @server = TCPServer.open(5151) #abre um servidor na porta 5151
    @clients = [] #lista de clientes, declaro como vazia

    main #chamo a função main
  end

  def main
    loop do #loop infinito
      Thread.fork(@server.accept) do |client| #pra cada cliente eu crio uma Thread
        sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr
        @ipv4 = client.gets.chomp
        client.puts client.peeraddr[1]

        listen(client) #chamo a função listen e dou como parâmetro o cliente atual
        client.close #caso saia da função listen, ele fecha a conexão com esse cliente
      end
    end
  end

  def listen(client)

    sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr #esse .peeraddr é um vetor da biblioteca socket
    #ele contém todas essas informações que eu estou atribuindo às variáveis de cima
    #sock_domain é a posição 0, client.peeraddr[0] e assim por diante
    sign_up(client) #chamo a função sign_up e dou como parâmetro esse cliente


    puts "-----------------------------------------"
    puts "Conectado"
    puts "IP: #{remote_ip}"
    puts "Porta: #{remote_port}"

    loop do #loop infinito
      command = client.gets.chomp #espero um command do cliente
      command = command.to_i #forço o command a ser inteiro
      puts "De: #{remote_ip} Pedido: #{command}"


      if command == 2
        send_hosts(client)
      elsif command == 3
        list_hosts(client)
      elsif command == 4
        download(client)
      elsif command == 5
        disconnect(client)
      end
    end
  end

  def download(client)
    client.puts @clients.to_s
    choice = client.gets.chomp.to_i
    files_to_send = @clients[choice][:files]
    client.puts files_to_send.to_s

    file = client.gets.chomp.to_i

    file_to_send = @clients[choice][:files][file]
    client.puts file_to_send

		owner_server_port = @clients[choice][:port_server]
    owner_port = @clients[choice][:socket_port]
		owner_ipv4 = @clients[choice][:client_ip]

		Thread.fork do
			@owner_socket = TCPSocket.open(owner_ipv4, owner_port)
			@owner_socket.puts "UPLOAD"
			@owner_socket.puts @ipv4, client.socket_port, file_to_send
			message = @owner_socket.gets

			puts "FROM: #{@ipv4} #{message}"
			puts "FILE: #{file} FROM: #{@ipv4} TO: #{owner_ipv4}"
		end

  end

  def disconnect(client)
    delete_ip = client.gets.chomp
    puts delete_ip

    @clients.delete_if { |hash| hash[:client_ip] == delete_ip }

    client.puts "Tchau" #se dois só mando um tchauzao
  end

  def list_hosts(client)
    client.puts @clients.to_s

    choice = client.gets.chomp.to_i
    files_to_send = @clients[choice][:files]
    client.puts files_to_send.to_s
  end

  def send_hosts(client)
    clients = @clients.to_s
    client.puts clients
  end



  def sign_up(client)
    sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr #esse .peeraddr é um vetor da biblioteca socket
    @ipv4 = remote_ip
    @clients.delete_if { |hash| hash[:client_ip] == remote_ip }

    puts @clients.length

    puts "-------------------------------------------"
    puts "Recebendo lista de arquivos de #{remote_ip}"

    files = instance_eval(client.gets)
    @port = client.gets.chomp.to_i

    files.each do | file |
      puts "De: #{remote_ip} Adicionado: #{file.chomp}"
    end

    @clients.push({
      :socket_port => remote_port,
      :port_server => @port,
      :client_ip => remote_ip,
      :files => files
    })



  end

end
Gerenciador.new.main
