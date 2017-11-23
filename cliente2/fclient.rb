class Fclient
	require 'socket'
	Socket::ip_address_list #ip diferente de 127

	def ipv4
		ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?} #busca ipv4 no método ip_address_list da biblioteca Socket
		@ipv4 = ip.ip_address if ip #ip_address transforma ipv4 binário em ipv4 humano (decimal)
	end

	def initialize
    @socket = TCPSocket.open('localhost', 5151) #abre a conexão com o gerenciador
    @socket.puts ipv4
    @port = 5000
		Thread.fork { server }

    @id = @socket.gets
		@my_id = gets.to_i
  end

  def main
  	puts "conectado"

  	system "clear"

    sign_up #chama a função sign_up
    menu #chama a função menu após voltar da sign_up

    @socket.close #caso saia do loop do menu, fecha o socket
  end

  def sign_up #função pro registro dos arquivos
    files = get_file_list #a variável files recebe um vetor o retorno da função get_file_list

		@socket.puts files.to_s #eu mando pro socket a variável string (lista de arquivos locais)
		@socket.puts @port.to_i
		puts "Lista de arquivos enviada\n\r"
  end


  def menu #menuzão massa
    loop do
      puts "-----------------MENU----------------"
      puts "|   1 - Lista de arquivos locais    |"
      puts "|   2 - Lista de Fclients           |"
      puts "|   3 - Lista de arquivos fclients  |"
      puts "|   4 - Download de arquivos        |"
      puts "|   5 - Desconectar                 |"
      puts "-------------------------------------"
      print "Opção: "


      command = gets.to_i

      system "clear"

      if command == 1
        list_files(command)
      end

      if command == 2
        list_hosts(command)
      end

      if command == 3
        list_hosts_files(command)
      end

      if command == 4
        download(command)
      end

      if command == 5
        disconnect(command)
      end

    end
  end
  def disconnect(command)
    @socket.puts command
    @socket.puts @ipv4.to_s

    puts @socket.gets
    @socket.close # e fecha a conexão
    exit
  end

  def download(command)

    @socket.puts command

    clients = instance_eval(@socket.gets)

    "----------------Fclients--------------\n\r"

    clients.each_with_index do | client, key |
      puts "Fclient => #{key}: #{client[:client_ip]}"
    end
    "--------------------------------------\n\r"

    puts "Escolha um Fclient para receber arquivo"

    choice = gets.to_i

    while choice < 0 || choice > clients.length
      puts "Escolha um Fclient para receber a arquivo"
      puts choice
      choice = gets.to_i
    end

    puts "Fclient: #{clients[choice][:client_ip]}"

    @socket.puts choice

    o_files = instance_eval(@socket.gets.chomp)

    puts "--------------Arquivos------------\n\r"

    o_files.each_with_index do | file, key |
      puts "#{key} => #{file}"
    end

    puts "Escolha o arquivo a ser baixado"
    choice = gets.to_i
    @socket.puts choice
    puts @socket.gets
    puts "--------------------------------------\n\r"

  end


  def list_hosts_files(command)
    @socket.puts command

    clients = instance_eval(@socket.gets)

    puts "----------------Fclients--------------\n\r"

    clients.each_with_index do | client, key |
      puts "Fclient => #{key}: #{client[:client_ip]}"
    end
    puts "--------------------------------------\n\r"

    choice = -1

    while choice < 0 || choice > clients.length
      puts "Escolha um Fclient para receber a lista de arquivo"
			choice = gets.to_i
      puts choice
    end

    puts "Fclient: #{clients[choice][:client_ip]}"

    @socket.puts choice



    o_files = instance_eval(@socket.gets)
    # puts instance_eval(files)

    puts "--------------Arquivos------------\n\r"

    o_files.each do | file |
      puts file
    end

  end

  def list_hosts(command)
    @socket.puts command
    clients = instance_eval(@socket.gets)

    puts "----------------Fclients--------------\n\r"

    clients.each do | client |
      puts client[:client_ip]
    end
  end

  def list_files(command)
    @socket.puts command

    files = get_file_list

    puts "--------------Arquivos------------\n\r"

    files.each_with_index do | file, key |
      puts "#{key}: #{file}"
    end

    puts "\n\r"
  end

  def get_file_list #função pra pegar meus arquivos locais
    return Dir.glob("*") #adiciono ao final da lista um "end", pra controle de quando acabar a lista
  end

	def server
    @server = TCPServer.open(@port)

    @client_list = []
    loop do
      Thread.fork(@server.accept) do |client|
        @client_list.push client
        listener(client)
        client.close
      end
    end
  end

  def listener(client)
    sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr

    loop do
			command = client.gets.chomp
      puts command
			puts "FROM: #{remote_ip}:#{remote_port} REQUEST: #{command}"

      if command == "UPLOAD"
        source_ip = client.gets.chomp
        source_port = client.gets.chomp
        file = client.gets.chomp
        client.puts "FOUND SERVER"

        Thread.fork do
					puts "Trying to connect with: #{source_ip}:#{source_port}"
          @socket_file = TCPSocket.open(source_ip, source_port.to_i)
          @socket_file.puts "DOWNLOAD"

          @socket_file.puts(file)
          file = open("#{file}", "rb")
      		fileContent = file.read
          @socket_file.puts(fileContent)
          @socket_file.puts "END"

          puts "ENVIANDO SAIDA"
        end

      elsif command == "DOWNLOAD"

        puts "RECEBENDO"

        file = client.gets.chomp
        time = Time.now.strftime "%Y%m%d%H%M%S"
        destFile = File.open("FClient_#{@my_id}_#{time}_#{file}", 'wb')
        loop do
          data = client.gets
          if data.chomp == "END"
            break
          end
          destFile.print data
        end
        destFile.close

        puts "Arquivo Recebido"
      end

    end
  end

end
Fclient.new.main
