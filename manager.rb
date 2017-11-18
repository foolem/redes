class Manager
	require "socket"

	def initialize
		@server = TCPServer.open(5151)
		@client_list = []
		@file_list = {}
	end

	def main
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
			puts "FROM: #{remote_ip} REQUEST: #{command}"

			if command == "SIGNUP"
				sign_up(client)
			elsif command == "LIST"
				client.puts file_list.push("END")

			elsif command == "DOWNLOAD"
				file = client.gets
				owner = find_owner(file)

				Thread.fork(owner) do
					owner_sock_domain, owner_remote_port, owner_remote_hostname, owner_remote_ip = owner.peeraddr
					@owner_socket = TCPSocket.open("localhost", owner_remote_port + 1)
					@owner_socket.puts "FILE_SEND"
					@owner_socket.puts remote_ip, remote_port, file
					message = @owner_socket.gets
					puts "FROM: #{remote_ip} #{message}"
					puts "FILE: #{file.chomp} FROM: #{owner_remote_ip} TO: #{remote_ip}"
				end

				client.puts "SENDING"
				#client.puts "FROM: #{owner_remote_ip} REQUEST: SEND FILE"

			elsif command == "EXIT"
				puts "FROM: #{remote_ip} BYE BYE"
				@client_list.delete(client)
				@file_list.delete(client)
				break
			end
		end
	end

	def sign_up(client)
		client.puts "Nova conexão"
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

	def file_list
		result = []
		@file_list.each do |key, value|
			value.each do |v|
				result.push v
			end
		end
		result
	end

end

Manager.new.main
