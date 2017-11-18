class FClient
  require "socket"

  DOWNLOAD = 1

  def initialize(id)
    ports = [60001, 60002, 60003, 60004, 60005]
    @id = id.to_i
    @my_port = ports[(@id -1)]

    @socket = TCPSocket.open("localhost", 5151)
    Thread.fork { server }
  end

  def connect
    system "clear"
    sign_up

    loop do
      choose = select_option
      if choose == DOWNLOAD
        file_list
        if @file_list.length != 0
          file_request(@file_list[select_file])
        else
          puts "\nNenhum arquivo disponível."
        end
      else
        disconnect
        break
      end
    end

    @socket.close
  end

  def print_menu
    puts "+------- Menu -------+"
    puts "+ 1 - Download file  +"
    puts "+ 2 - Exit           +"
    puts "+--------------------+"
    print "-> Option: "
  end

  def select_option
    loop do
      print_menu
      chose = gets
      chose = chose.to_i

      if chose <= 2 and chose >= 1
        return chose
      end
      puts "\nEntrada inválida..."
    end
  end

  def select_file
    loop do
      print_file_list
      print "-> File index: "
      file_index = gets
      file_index = file_index.to_i

      if file_index <= @file_list.length and file_index >= 0
        return file_index
      end
      puts "\nEntrada inválida..."
    end
  end

  def sign_up
    @file_list = []
    command = "SIGNUP"
    @socket.puts command
    @socket.puts @my_port

    puts @socket.gets
    @socket.puts get_file_list
    puts @socket.gets

  end

  def file_request(file)
    command = "DOWNLOAD"
    @socket.puts command
    @socket.puts file
  #puts @socket.gets
  end

  def file_list
    command = "LIST"
    @socket.puts command
    @file_list.clear

    while file = @socket.gets
      if file.chomp == "END"
        break
      end
      @file_list.push(file.chomp)
    end
  end

  def print_file_list
    puts "\nINDEX\t FILE"
    @file_list.each.with_index do |fi, index|
      puts "#{index}\t #{fi}"
    end
  end

  def get_file_list
      if Dir.exist?("files")
        Dir.chdir("files") do
          return Dir.glob("*").push("END")
        end
      else
        Dir.mkdir("files")
        return ["END"]
      end
  end

  def server
    @server = TCPServer.open(@my_port)

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
          file = open("files/#{file}", "rb")
      		fileContent = file.read
          @socket_file.puts(fileContent)
          @socket_file.puts "END"

          puts "ENVIANDO SAIDA"
        end

      elsif command == "DOWNLOAD"

        puts "RECEBENDO"

        file = client.gets.chomp
        time = Time.now.strftime "%Y%m%d%H%M%S"
        destFile = File.open("files/FClient_x_#{time}_#{file}", 'wb')
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

  def disconnect
    command = "EXIT"
    @socket.puts command
    system "clear"
    puts "\nGodbye!"
  end

end

print "Client id: "
id = gets

FClient.new(id).connect
