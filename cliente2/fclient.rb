class Fclient
  require 'socket'
  Socket::ip_address_list

  def ipv4
    ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
    @ipv4 = ip.ip_address if ip
  end

  def initialize
    @socket = TCPSocket.open('localhost', 5151) #abre a conexão com o gerenciador
    @socket.puts ipv4
    #uso futuro @port = 5001

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
    files = get_file_list #a variável files recebe o retorno da função get_file_list

    @socket.puts files.to_s #eu mando pro socket a variável (lista de arquivos locais)
    puts "Lista de arquivos enviada\n\r"
  end

def menu #menuzão massa
  loop do
    puts "-----------------MENU----------------"
    puts "|   1 - Lista de arquivos locais    |"
    puts "|   2 - Lista de Fclients           |"
    puts "|   3 - Lista de arquivos fclients  |"
    puts "|   4 - Sair                        |"
    puts "-------------------------------------"
    print "Opção: "

    command = gets
    command = command.to_i #to_i eu forço a conversão de command para inteiro, pra não ocorrer falhas

    system "clear"

    if command == 1
      @socket.puts command

      files = get_file_list

      puts "--------------Arquivos------------\n\r"

      files.each_with_index do | file, key |
        puts "#{key}: #{file}"
      end

      puts "\n\r"
    end

    if command == 2
      @socket.puts command

      clients = instance_eval(@socket.gets)

      puts "----------------Fclients--------------\n\r"

      clients.each do | client |
        puts client[:client_ip]
      end

      puts "\n\r"
    end

    if command == 3
      @socket.puts command

      clients = instance_eval(@socket.gets)

      "----------------Fclients--------------\n\r"
      clients.each_with_index do | client, key |
        puts "Fclient => #{key}: #{client[:client_ip]}"
      end
      "--------------------------------------\n\r"

      puts "Escolha um Fclient para receber a lista de arquivo"

      choice = gets.to_i

      while choice < 0 || choice > clients.length
        puts "Escolha um Fclient para receber a lista de arquivo"
        puts choice

        choice = gets.to_i
      end

      puts "Fclient: #{clients[choice][:client_ip]}"

      @socket.puts choice

      files = @socket.gets
      puts instance_eval(files).class

      # files.each do | file |
        # puts file
      # end
    end

    #se o command for 2, envia essa mensagem pro gerenciador
    if command == 4
      @socket.puts command
      @socket.puts @id

      puts @socket.gets

      @socket.close # e fecha a conexão
      exit
    end

  end
end

  def get_file_list #função pra pegar meus arquivos locais
    return Dir.glob("*") #adiciono ao final da lista um "end", pra controle de quando acabar a lista
  end

end
Fclient.new.main
