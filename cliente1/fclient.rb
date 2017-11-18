class Fclient
  require 'socket'
  Socket::ip_address_list

  def ipv4
    ip=Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
    ip.ip_address if ip
  end

  def initialize
    @socket = TCPSocket.open('localhost', 5151) #abre a conexão com o gerenciador
    @socket.puts ipv4
    #uso futuro @port = 5001
  end

  def main
    puts "conectado"
    system "clear"
    sign_up #chama a função sign_up
    menu #chama a função menu após voltar da sign_up
    @socket.close #caso saia do loop do menu, fecha o socket
  end

  def sign_up #função pro registro dos arquivos
    files = get_file_list #a variável files recebe o retorno da função get_file_list
    @socket.puts files #eu mando pro socket a variável (lista de arquivos locais)
    puts "Lista de arquivos enviada"

  end


def menu #menuzão massa
  loop do
    file_list = [] #zero a lista de arquivos locais dessa função toda vez que o loop acontece
    clients_list = []
    command = 5
    puts "-----------------MENU----------------"
    puts "|   1 - Lista de arquivos locais    |"
    puts "|   2 - Lista de Fclients           |"
    puts "|   3 - Lista de arquivos fclients  |"
    puts "|   4 - Sair                        |"
    puts "-------------------------------------"

    command = gets #espero do teclado um comando
    command = command.to_i #to_i eu forço a conversão de command para inteiro, pra não ocorrer falhas
    system "clear"
    if command == 1
      @socket.puts command # aqui ele envia pro gerenciador se for 1
      while files = @socket.gets #enquanto estou recebendo a lista de arquivos (um por um)
        if files.chomp == "end" #end é minha string de controle, se eu encontrar ela, ele para de esperar mais arquivos
          break
        end
        file_list.push files.chomp #vou adicionando cada arquivo ao final do meu array file_list
      end

      puts "--------------Arquivos------------"
      file_list.each_with_index do | files, key |
        file_list[key] = instance_eval(files)
        puts "#{key}: #{file_list[key][:files]}"
      end
      puts "----------------------------------"
    end

    if command == 2
      @socket.puts command
      while clients = @socket.gets
        if clients.chomp == "end"
          break
        end
        clients_list.push clients.chomp
      end
      "----------------Fclients--------------"
      clients_list.each do | client |
        puts instance_eval(client)[:client_ip]
      end
      "--------------------------------------"
    end

    if command == 3
      @socket.puts command
      while clients = @socket.gets
        if clients.chomp == "end"
          break
        end
        clients_list.push clients.chomp
      end
      "----------------Fclients--------------"
      clients_list.each_with_index do | client, key |
        clients_list[key] = instance_eval(client)
        puts "Fclient => #{key}: #{clients_list[key][:client_ip]}"
      end
      "--------------------------------------"

      puts "Escolha um Fclient para receber a lista de arquivo"
      choice = gets.to_i
      while choice < 0 || choice > clients_list.length
        puts "Escolha um Fclient para receber a lista de arquivo"
        puts choice
        choice = gets.to_i
      end
      puts "Fclient: #{clients_list[choice][:client_ip]}"
      @socket.puts choice
      o_files_list = []
      while o_client_files = @socket.gets.chomp
        if o_client_files == "end"
          break
        end
        o_files_list.push o_client_files
      end
      puts o_files_list
    end

    if command == 4 #se o command for 2, envia essa mensagem pro gerenciador
      @socket.puts command #envia
      @socket.close # e fecha a conexão
      exit
    end

    end
  end

  def get_file_list #função pra pegar meus arquivos locais
    return Dir.glob("*").push("end") #adiciono ao final da lista um "end", pra controle de quando acabar a lista
  end

end
Fclient.new.main
