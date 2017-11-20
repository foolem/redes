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
		@my_port = @socket.gets.chomp.to_i
    @id = @socket.gets
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
		@socket.puts @my_port
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
    choice_file = gets.to_i
    @socket.puts choice_file
    puts @socket.gets
    puts "--------------------------------------\n\r"

		file_to_send = clients[choice][:files][choice_file]
		ip = clients[choice][:client_ip]
		port = clients[choice][:port]
		ncat_s = "ncat -l -p #{@my_port} > #{file_to_send}"
		puts ncat_s
		@socket.puts ncat_s.to_s

		`ncat -w 3 #{ip} #{port} < #{file_to_send}`

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



end
Fclient.new.main
