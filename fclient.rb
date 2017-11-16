class Fclient
  require 'socket'

  def initialize
    @socket = TCPSocket.open('localhost', 5151)
    puts "conectei"
    @socket.puts "oi"
    answer = @socket.gets.chomp
    puts answer

    @socket.close
  end

end
Fclient.new
