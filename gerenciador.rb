class Gerenciador
  require "socket"

  def initialize #initialize é a primeira função que o ruby procura
    @server = TCPServer.open(5151) #abre um servidor na porta 5151
    @server.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, 1)
    @clients = [] #lista de clientes, declaro como vazia

    main #chamo a função main
  end

  def main
    loop do #loop infinito
      Thread.fork(@server.accept) do |client| #pra cada cliente eu crio uma Thread
        sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr
        @ipv4 = client.gets.chomp
        @socket_port client.gets.chomp
        client.puts remote_port
        client.puts remote_ip
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
    puts client.gets.chomp
    puts client.gets.chomp
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
      :server_port => @port,
      :client_ip => remote_ip,
      :files => files
    })



  end

end
Gerenciador.new.main
