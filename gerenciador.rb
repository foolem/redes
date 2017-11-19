class Gerenciador
  require "socket"

  def initialize #initialize é a primeira função que o ruby procura
    @server = TCPServer.open(5151) #abre um servidor na porta 5151
    @clients = [] #lista de clientes, declaro como vazia

    main #chamo a função main
  end

  def main
    loop do #loop infinito
      Thread.fork(@server.accept) do |client| #pra cada cliente eu crio uma Thread, aceita varios clientes ao mensmo tempo
        @ipv4 = client.gets.chomp

        listen(client) #chamo a função listen e dou como parâmetro o cliente atual
        client.close #caso saia da função listen, ele fecha a conexão com esse cliente
      end
    end
  end

  def listen(client)

    sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr #esse .peeraddr é um vetor da biblioteca socket
    remote_ip = @ipv4
    #ele contém todas essas informações que eu estou atribuindo às variáveis de cima
    #sock_domain é a posição 0, client.peeraddr[0] e assim por diante
    sign_up(client) #chamo a função sign_up e dou como parâmetro esse cliente


    puts "-----------------------------------------"
    puts "Conectado"
    puts "IP: #{remote_ip}"
    puts "Porta: #{remote_port}"

    loop do #loop infinito
      command = client.gets.chomp.to_i #espero um command do cliente
      puts "De: #{remote_ip} Pedido: #{command}"


      if command == 1
        send_list(client)
      elsif command == 2
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
    choice = client.gets.chomp.to_i #choice tem o ip escolhido
    files_to_send = @clients[choice][:files]
    client.puts files_to_send.to_s

    file = client.gets.chomp.to_i #file tem o arquivo escolhido
    file_to_send = @clients[choice][:files][file]
    client.puts file_to_send


    info = client.peeraddr

		owner = @clients[choice][:client]
		owner_server_port = @clients[choice][:port]
		owner_info = owner.peeraddr

		Thread.fork do
			@owner_socket = TCPSocket.open(owner_info[3], owner_server_port)
			@owner_socket.puts "upload"
			@owner_socket.puts info[3], @client_server_port, file_to_send
			message = @owner_socket.gets

			puts "FROM: #{info(client)} #{message}"
			puts "FILE: #{file} FROM: #{server_info(owner)} TO: #{server_info(client)}"
		end

		client.puts "SENDING FILE WISH"

  end

  def disconnect(client)
    delete_ip = client.gets.chomp
    puts delete_ip

    @clients.delete_if { |hash| hash[:client_ip] == delete_ip }

    client.puts "Tchau" #se dois só mando um tchauzao
  end

  def list_hosts(client)

    choice = client.gets.chomp.to_i
    files_to_send = @clients[choice][:files]
    client.puts files_to_send.to_s
  end

  def send_hosts(client)
    clients = @clients.to_s
    client.puts clients
  end

  def sign_up(client)
    remote_ip = @ipv4
    @client_server_port = client.gets.chomp.to_i
    @clients.delete_if { |hash| hash[:client_ip] == remote_ip } #se o ip que entrou já está na lista ele exclui pra não duplicar

    puts "-------------------------------------------"
    puts "Recebendo lista de arquivos de #{remote_ip}"

    files = instance_eval(client.gets) #recebe a string e percebe que é um vetor e transforma

    files.each do | file | #cada posição do vetor vira um file. o each significa um for
      puts "De: #{remote_ip} Adicionado: #{file.chomp}"
    end

    @clients.push({
      :client => client,  #pega o id da coenxão com esse fcliente
      :port => @client_server_port,
      :client_ip => @ipv4, #pega o ip
      :files => files #pega os arquivos
    })
  end

end
Gerenciador.new.main
