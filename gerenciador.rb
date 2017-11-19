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
        client.puts client.object_id

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

        #se o command for 1 eu mando a lista de arquivos pro cliente
        client.puts @clients.to_s

        puts "Lista enviada"
      elsif command == 2
        clients = @clients.to_s
        client.puts clients
      elsif command == 3
        client.puts @clients.to_s

        choice = client.gets.chomp.to_i

        files_to_send = @clients[choice][:files]
        client.puts files_to_send.to_s

      elsif command == 4
        delete_id = client.gets.to_i
        puts delete_id

        @clients.each do |client|
          client.delete_if { |key, value| key == :client_id && value == delete_id }
        end

        client.puts "Tchau" #se dois só mando um tchauzao
      end
    end
  end


  def sign_up(client)
    remote_ip = @ipv4

    @clients.delete_if { |hash| hash[:client_ip] == remote_ip }

    puts @clients.length

    puts "-------------------------------------------"
    puts "Recebendo lista de arquivos de #{remote_ip}"

    files = instance_eval(client.gets)

    files.each do | file |
      puts "De: #{remote_ip} Adicionado: #{file.chomp}"
    end

    @clients.push({
      :client_id => client.object_id,
      :client_ip => @ipv4,
      :files => files
    })
  end

end
Gerenciador.new.main
