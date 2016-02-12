# Demo for MIF WG Multiple Provisioning Domain (PvD) project

In this demo, we simulate network configuration shown in Figure 1. For the
pupose of the demo, we need three host (or virtual) machines:
  - machine 1: provider of PvD 1 (router + dns server + web server)
  - machine 2: provider of PvD 2 (router + dns server + web server)
  - machine 3: client connected to both PvDs at the same time

                   +------------------------------------------+
                   | PvD 1                                    |
                   |                              +--------+  |
                   |                              |  dns   |  |
                   |                       +---o--| server |  |
                   |     +----------+      |      |   1    |  |
                   |     |          |      |      +--------+  |
               +---+--o--+ router 1 |--o---+                  |
               |   |     |          |      |      +--------+  |
               |   |     +----------+      |      |  web   |  |
               |   |                       +---o--| server |  |
               |   |                              |   1    |  |
               |   |                              +--------+  |
+--------+     |   |                                          |
|        |     |   +------------------------------------------+
| client +--o--+
|        |     |   +------------------------------------------+
+--------+     |   | PvD 2                                    |
               |   |                              +--------+  |
               |   |                              |  dns   |  |
               |   |                       +---o--| server |  |
               |   |     +----------+      |      |   2    |  |
               |   |     |          |      |      +--------+  |
               +---+--o--+ router 2 |--o---+                  |
                   |     |          |      |      +--------+  |
                   |     +----------+      |      |  web   |  |
                   |                       +---o--| server |  |
                   |                              |   2    |  |
                   |                              +--------+  |
                   |                                          |
                   +------------------------------------------+

              Figure 1. Network configuration for PvD test

Client is connected to two network providers, each of which provide a network
configuration as an explicit PvD. Router 1 and router 2 announce the PvDs
through RAs.

Client tries to access the web server located at pvdtest.com. Client can choose
which one of the two available PvDs to use to connect to a web server. If PvD 1
is selected, client's requests for domain name resolution are resolved by DNS 1,
while in case PvD 2 is selected, domain names are resolved by DNS 2. However,
these two DNS servers are configured differently and they resolve the same
domain name (pvdtest.com) to two different IP addresses, one belonging to web
server 1, while another belonging to web server 2. This simulates the situation
where an application server on provider's private network is accessible only
from provider's network.

Router 1 uses the following network parameters while sending RAs:
Network prefix: 2001:db8:1111:1111::/64
Router IP:      2001:db8:1111:1111::1
DNS:            2001:db8:1111:1111::1

Router 2 uses the following network parameters while sending RAs:
Network prefix: 2001:db8:2222:2222::/64
Router IP:      2001:db8:2222:2222::1
DNS:            2001:db8:2222:2222::1

To run the demo, we need the following projects from Github:
  * https://github.com/dskvorc/mif-radvd (PvD-aware version of radvd)
  * https://github.com/dskvorc/mif-pvdman (client-side PvD manager)
  * https://github.com/dskvorc/mif-demo (demo configuration scripts)

IMPORTANT:
Put all the projects within the same root directory because configuration
scripts use relative paths. For example:
  * <DEMO_ROOT_DIR>/mif-radvd
  * <DEMO_ROOT_DIR>/mif-pvdman
  * <DEMO_ROOT_DIR>/mif-demo

To run the demo, start three virtual machines that have a network connectivity
among each other.

On machine 1 (router 1 + DNS server 1 + web server 1), run the following:
  $ cd <DEMO_ROOT_DIR>/mif-demo
  $ sudo ./configure.pvd01.sh
  
On machine 2 (router 2 + DNS server 2 + web server 2), run the following:
  $ cd <DEMO_ROOT_DIR>/mif-demo
  $ sudo ./configure.pvd02.sh
  
At this point, machine 1 and machine 2 should have their IP addresses
configured, and following services should be started:
  named (regular DNS server)
  httpd (regular web server)
  radvd (PvD-aware version of radvd)
  
On machine 3 (client), run the following:
  $ cd <DEMO_ROOT_DIR>/mif-pvdman
  $ sudo python3 main.py

At this point, machine 3 should start to periodically receive RAs from both
machine 1 and machine 2 and, as a consequence, configure two PvDs on its network
interface. Each PvD is configured in different network namespace.

To check the namespaces created to host PvDs, run the following on machine 3
(client):
  $ sudo ip netns list
You should see something like:
  mifpvd-4
  mifpvd-3
  mifpvd-2
  mifpvd-1
  mifpvd-default
You may have other namespaces listed too if your system is using them, but for
the purpose of the PvD configuration, only those prefixed with mifpvd-* are
relevant. Namespace mifpvd-default is default network namespace, while others
namespaces are created to host two implicit and two explicit PvDs. You can look
at the stderr log of the mif-pvdman to check which namespace is associated with
particular PvD.

Let's assume that PvD 1 is configured in mifpvd-2, while PvD 2 is configured in
mifpvd-4. To test the client's connectivity, run the following on machine 3
(client):
  $ firefox
  type pvdtest.com into the web browser's address bar
  (you should get Server not found error because default network namespace is
  not aware of any PvD and pvdtest.com is not resolvable by default DNS)
  
  $ sudo ip netns exec mifpvd-2 firefox
  type pvdtest.com into the web browser's address bar
  (you should get a web page from web server 1)

  $ sudo ip netns exec mifpvd-4 firefox
  type pvdtest.com into the web browser's address bar
  (you should get a web page from web server 2)
