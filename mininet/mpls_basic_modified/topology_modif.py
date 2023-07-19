from p4utils.mininetlib.network_API import NetworkAPI

net = NetworkAPI()
net.setLogLevel('info')

net.addP4Switch('s1', cli_input='sx-commands/s1-new4-commands.txt')
net.addP4Switch('s2', cli_input='sx-commands/s2-new4-commands.txt')
net.addP4Switch('s3', cli_input='sx-commands/s3-new4-commands.txt')
net.addP4Switch('s4', cli_input='sx-commands/s4-new4-commands.txt')
net.setP4SourceAll('basics_new3.p4')

net.addHost('h1')
net.addHost('h2')
net.addHost('h3')
net.addHost('h4')

net.addLink("h1", "s1", port2=1)
net.addLink("s1", "s2", port1=2, port2=1)
net.addLink("s1", "s3", port1=3, port2=1)
net.addLink("h2", "s1", port2=4)
net.addLink("s2", "s4", port1=2, port2=1)
net.addLink("s3", "s4", port1=2, port2=2)
net.addLink("s4", "h3", port1=3)
net.addLink("s4", "h4", port1=4)

# Assignment strategy
net.l3()

# Set Bandwidth
net.setBwAll(1000)

# Nodes general options
net.enablePcapDumpAll()
net.enableLogAll()
net.enableCli()
net.startNetwork()
