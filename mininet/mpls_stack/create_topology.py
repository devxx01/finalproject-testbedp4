net = NetworkAPI()

# Network general options
net.setLogLevel('info')

# Network definition
net.addP4Switch('s1', cli_input='switch1_flow_rules.txt')
net.addP4Switch('s2', cli_input='switch2_flow_rules.txt')
net.addP4Switch('s3', cli_input='switch3_flow_rules.txt')
net.addP4Switch('s4', cli_input='switch4_flow_rules.txt')
net.setP4SourceAll('stacked.p4')

net.addHost('h1')
net.addHost('h2')

net.addLink("h1", "s1", port2=1)
net.addLink("s1", "s2", port1=2, port2=1)
net.addLink("s1", "s3", port1=3, port2=1)
net.addLink("s2", "s4", port1=2, port2=1)
net.addLink("s3", "s4", port1=2, port2=2)
net.addLink("s4","h2", port1=3)

# Assignment strategy
net.l3()

# Set Bandwidth
net.setBwAll(1000)

# Nodes general options
net.enablePcapDumpAll()
net.enableLogAll()
net.enableCli()
net.startNetwork()
