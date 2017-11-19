def server
	@server = TCPServer.open(@port)

	@clients = []
	loop do
		Thread.fork(@server.accept) do |client|
			listen(client)
			client.close
		end
	end
end

def listen(client)
	sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr

	loop do
		command = client.gets.chomp
		puts command
		puts "De: #{remote_ip}:#{remote_port} pedido: #{command}"

		if command == "upload"
			source_ip = client.gets.chomp
			source_port = client.gets.chomp
			file = client.gets.chomp
			client.puts "Encontrado"

			Thread.fork do
				puts "Trying to connect with: #{source_ip}:#{source_port}"
				@socket_file = TCPSocket.open(source_ip, source_port.to_i)
				@socket_file.puts "DOWNLOAD"

				@socket_file.puts(file)
				file = open("#{file}", "rb")
				fileContent = file.read
				@socket_file.puts(fileContent)
				@socket_file.puts "end"

				puts "ENVIANDO SAIDA"
			end

		elsif command == "DOWNLOAD"

			puts "RECEBENDO"

			file = client.gets.chomp
			time = Time.now.strftime "%Y%m%d%H%M%S"
			destFile = File.open("FClient_x_#{time}_#{file}", 'wb')
			loop do
				data = client.gets
				if data.chomp == "end"
					break
				end
				destFile.print data
			end
			destFile.close

			puts "Arquivo Recebido"
		end

	end
end
