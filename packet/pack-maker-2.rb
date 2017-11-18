require 'packetfu'

config = PacketFu::Utils.whoami?

synpkt = PacketFu::TCPPacket.new(config: config, flavor: "Linux")
synpkt.ip_daddr      = "216.58.221.142" # ip of google.com
synpkt.tcp_dst       = 80               # port of google.com
synpkt.tcp_flags.syn = 1                # SYN
synpkt.recalc
