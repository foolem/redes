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
        @ipv4 = client.gets.chomp
        # sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr
        # @clients_ip.push remote_ip
        #adiciono ao final da lista de clientes o ip do cliente que acabou de se conectar


        #puts @clients[0][:client_id]

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
			command = client.gets.chomp #espero um command do cliente
      command = command.to_i #forço o command a ser inteiro
			puts "De: #{remote_ip} Pedido: #{command}"

      if command == 1
        puts "Enviando lista"
        client.puts @clients.push("end") #se o command for 1 eu mando a lista de arquivos pro cliente
        puts "Lista enviada"
      elsif command == 2
        clients = @clients.push("end")
        client.puts clients
      elsif command == 3
        client_list = @clients.push("end")
        client.puts client_list
        choice = client.gets.chomp.to_i

        files_to_send = @clients[choice][:files]
        client.puts files_to_send.push("end")

      elsif command == 4
        client.puts "Tchau" #se dois só mando um tchauzao
      end
    end
	end


  def sign_up(client)
    sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr #mesmas configs do cliente, só pego elas novamente
    remote_ip = @ipv4
    list = []
    puts "-------------------------------------------"
    puts "Recebendo lista de arquivos de #{remote_ip}"
    while files = client.gets #enquanto estou recebendo arquivos do cliente
      if files.chomp == "end" #para se achar a string "end"
        break
      end
      list.push files.chomp
      puts "De: #{remote_ip} Adicionado: #{files.chomp}"
    end
    @clients.push({
      :client_id => client.object_id,
      :client_ip => @ipv4,
      :files => list
    })

  end

end
Gerenciador.new.main
