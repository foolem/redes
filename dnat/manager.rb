class Manager
	require "socket"

	def initialize
		@server = TCPServer.open(5151)
		puts "Server port: 5151"
		puts "Waiting for connections..."

		@file_list = {}
		server
	end

	def server
		@client_list = {}
		loop do
			Thread.fork(@server.accept) do |client|
				listener(client)
				client.close
			end
		end
	end

	def listener(client)
		sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr

		loop do
			command = client.gets.chomp
			puts "FROM: #{info(client)} REQUEST: #{command}"

			if command == "SIGNUP"
				sign_up(client)

			elsif command == "LIST"
				send_list(client)

			elsif command == "DOWNLOAD"
				download(client)

			elsif command == "EXIT"
				disconnect(client)
				break
			end
		end

	end

	def sign_up(client)
		client_port = client.gets.chomp

		client.puts "CONNECTION ACCEPTED"
		sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr

		client_file_list = []
		while file = client.gets
			if file.chomp == "END"
				break
			end
			client_file_list.push file.chomp
			puts "FROM: #{remote_ip} ADD: #{file.chomp}"
		end

		@file_list[client] = client_file_list
		client.puts "FILE LIST UPDATED"
		puts "FROM: #{remote_ip} FILE LIST UPDATED"

		puts "PORT: #{client_port}"
		@client_list[client] = client_port
	end

	def send_list(client)
		client.puts file_list(client).push("END")
	end

	def download(client)
		info = client.peeraddr

		file = client.gets.chomp
		owner = find_owner(file)
		owner_server_port = @client_list[owner]
		owner_info = owner.peeraddr

		Thread.fork do
			@owner_socket = TCPSocket.open(owner_info[3], owner_server_port)
			@owner_socket.puts "UPLOAD"
			@owner_socket.puts info[3], @client_list[client], file
			message = @owner_socket.gets

			puts "FROM: #{info(client)} #{message}"
			puts "FILE: #{file} FROM: #{server_info(owner)} TO: #{server_info(client)}"
		end

		client.puts "SENDING FILE WISH"
	end

	def disconnect
		info = client.peeraddr
		puts "FROM: #{info[3]}:#{info[1]} DISCONNECT"
		@client_list.delete(client)
		@file_list.delete(client)
	end

	def find_owner(file)
		@file_list.each do |key, value|
			value.each do |v|
				if v.eql? file.chomp
					return key
				end
			end
		end
	end

	def file_list(client)
		result = []
		@file_list.each do |key, value|
			if key != client
				value.each do |v|
					result.push v
				end
			end
		end
		result
	end

	def info(sock)
		info = sock.peeraddr
		"#{info[3]}:#{info[1]}"
	end

	def server_info(sock)
		info = sock.peeraddr
		"#{info[3]}:#{@client_list[sock]}"
	end

end

Manager.new.server
