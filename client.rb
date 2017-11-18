class Client
  require "socket"

  def initialize
      @socket = TCPSocket.open('localhost', 5151)
      @port = @socket.addr[1] + 1

      Thread.fork do
         server
      end

      @file_list = []
  end

  def sign_up
    command = "SIGNUP"
    @socket.puts command
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

  def get_out
    command = "EXIT"
    @socket.puts command
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
			puts "FROM: #{remote_ip} REQUEST: #{command}"

      if command == "FILE_SEND"
        source_ip = client.gets.chomp
        source_port = client.gets.chomp
        file = client.gets.chomp
        client.puts "FOUND SERVER"

        Thread.fork do

          @socket_file = TCPSocket.open(source_ip, source_port.to_i + 1)
          @socket_file.puts "INDO"

          @socket_file.puts(file)
          file = open("files/#{file}", "rb")
      		fileContent = file.read
          @socket_file.puts(fileContent)
          @socket_file.puts "END"

          puts "ENVIANDO SAIDA"
        end
      elsif command == "INDO"

        puts "RECEBENDO"

        file = client.gets.chomp
        time = Time.now.strftime "%Y%m%d%H%M%S"
        destFile = File.open("files/#{time}-#{file}", 'wb')
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

  def main
    sign_up

    loop do
      chose = 3
      loop do
        #system "clear"
        puts "+------- Menu -------+"
        puts "+ 1 - Download file  +"
        puts "+ 2 - Exit           +"
        puts "+--------------------+"
        print "-> Option: "

        chose = gets
        chose = chose.to_i
        if chose > 2 || chose < 1
            puts "Entrada inválida..."
        else
          break
        end
      end

      if chose == 1
        file_list

        wish = -1
        loop do
          print "-> File index: "
          wish = gets
          wish = wish.to_i

          if wish > @file_list.length || wish < 0
              puts "Entrada inválida..."
          else
            break
          end
        end
        file_request(@file_list[wish.to_i])
      else
        get_out
        puts "\nGodbye!"
        break
      end
    end

    @socket.close
  end
end

Client.new.main
