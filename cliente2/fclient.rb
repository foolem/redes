class Fclient
  require 'socket'

  def initialize
    @socket = TCPSocket.open('localhost', 5151) #abre a conexão com o gerenciador
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

    puts "-----------------MENU----------------"
    puts "|      1 - Lista de arquivos locais  |"
    puts "|      2 - Lista de Fclients         |"
    puts "|      3 - Lista de arquivos fclients|"
    puts "|      4 - Sair                      |"
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
      puts file_list #escrevo na tela a lista dos meus arquivos locais que mandei pro servidor
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
      puts clients_list
      "--------------------------------------"
    end

    if command == 4 #se o command for 2, envia essa mensagem pro gerenciador
      @socket.puts command #envia
      @socket.close # e fecha a conexão
    end

    end
  end

  def get_file_list #função pra pegar meus arquivos locais
    return Dir.glob("*").push("end") #adiciono ao final da lista um "end", pra controle de quando acabar a lista
  end

end
Fclient.new.main
