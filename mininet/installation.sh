cd ~/p4c
mkdir build
cd build
cmake ..
make -j4
make -j4 check

sudo apt-get install -y arping autoconf automake bash-completion bridge-utils build-essential ca-certificates cmake cpp curl emacs gawk git git-review g++ htop libboost-dev libboost-filesystem-dev libboost-program-options-dev libboost-test-dev libc6-dev libevent-dev libgc1c2 libgflags-dev libgmpxx4ldbl libgmp10 libgmp-dev libffi-dev libtool libpcap-dev linux-headers-$KERNEL make nano pkg-config python3 python3-dev python3-pip python3-setuptools tmux traceroute vim wget xcscope-el xterm zip

#Instalasi library python yang dibutuhkan
sudo pip3 install cffi ipaddress ipdb ipython pypcap scapy

sudo apt-get -y install wireshark
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure wireshark-common
sudo apt-get -y --no-install-recommends install tcpdump tshark

#Protobuf dependencies installation
sudo apt-get install -y --no-install-recommends unzip

#Protobuf installation
git clone https://github.com/protocolbuffers/protobuf protobuf

cd protobuf
git checkout ${PROTOBUF_COMMIT}
git submodule update --init --recursive

# Build protobuf C++
export CFLAGS="-Os"
export CXXFLAGS="-Os"
export LDFLAGS="-Wl,-s"

./autogen.sh
./configure --prefix=/usr
make -j${NUM_CORES}
sudo make install
sudo ldconfig
make clean

git clone https://github.com/grpc/grpc.git grpc
cd grpc
git checkout ${GRPC_COMMIT}
git submodule update --init --recursive

# Build grpc
export LDFLAGS="-Wl,-s"

make -j${NUM_CORES}
sudo make install
sudo ldconfig
make clean

unset LDFLAGS

#sysrepo dependencies
sudo apt-get install -y --no-install-recommends libavl-dev libev-dev libpcre3-dev libprotobuf-c-dev protobuf-c-compiler

git clone https://github.com/CESNET/libyang.git libyang
d libyang
git checkout v0.16-r1

# Build libyang
if [ ! -d build ]; then
    mkdir build
else
    rm -R build
    mkdir build
fi
cd build
cmake ..
make -j${NUM_CORES}
sudo make install
sudo ldconfig

# Clone source sysrepo
cd ${BUILD_DIR}
if [ ! -d sysrepo ]; then
    git clone https://github.com/sysrepo/sysrepo.git sysrepo
fi
cd sysrepo
git checkout v0.7.5

# Build sysrepo
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=Off -DCALL_TARGET_BINS_DIRECTLY=Off ..
make -j${NUM_CORES}
sudo make install
sudo ldconfig

cd ${BUILD_DIR}
if [ ! -d libyang ]; then
    git clone https://github.com/CESNET/libyang.git libyang
fi
cd libyang
git checkout ${LIBYANG_COMMIT}

# Build libyang
if [ ! -d build ]; then
    mkdir build
else
    rm -R build
    mkdir build
fi
cd build
cmake -DENABLE_LYD_PRIV=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr \
        -D CMAKE_BUILD_TYPE:String="Release" ..
make -j${NUM_CORES}
sudo make install
sudo ldconfig
#dependencies installation
sudo apt-get install -y \
git autoconf automake libtool make libreadline-dev texinfo pkg-config libpam0g-dev libjson-c-dev bison flex python3-pytest libc-ares-dev python3-dev libsystemd-dev python-ipaddress python3-sphinx install-info build-essential libsystemd-dev libsnmp-dev perl libcap-dev libelf-dev

#FRRouting installation
cd ${BUILD_DIR}
git clone https://github.com/FRRouting/frr.git frr
cd frr
git checkout ${FRROUTING_COMMIT}
# Build FRRouting
./bootstrap.sh
./configure --enable-fpm --enable-protobuf --enable-multipath=8
make -j${NUM_CORES}
sudo make install
sudo ldconfig

#PI Dependencies
sudo apt-get install -y --no-install-recommends libboost-system-dev libboost-thread-dev libjudy-dev libreadline-dev libtool-bin valgrind

git clone https://github.com/p4lang/PI.git
cd PI
git checkout ${PI_COMMIT}
git submodule update --init --recursive

# Build PI
./autogen.sh
if [ "$DEBUG_FLAGS" = true ]; then
    if [ "$SYSREPO" = true ]; then
       ./configure --with-proto --with-sysrepo "CXXFLAGS=-O0 -g"
    else
       ./configure --with-proto "CXXFLAGS=-O0 -g"
     fi
else
    if [ "$SYSREPO" = true ]; then
        ./configure --with-proto --with-sysrepo
    else
        ./configure --with-proto
    fi
fi
make -j${NUM_CORES}
sudo make install
sudo ldconfig
make clean

#dependencies
sudo apt-get install -y --no-install-recommends bison clang flex iptables libboost-graph-dev libboost-iostreams-dev libelf-dev libfl-dev libgc-dev llvm net-tools zlib1g-dev

sudo pip3 install ipaddr pyroute2 ply scapy

#p4c installation
git clone https://github.com/p4lang/p4c.git p4c
cd p4c
git checkout ${P4C_COMMIT}
git submodule update --init --recursive
mkdir -p build
cd build

# Build p4c
if [ "$DEBUG_FLAGS" = true ]; then
    cmake .. -DCMAKE_BUILD_TYPE=DEBUG $*
else
    # Debug build
     cmake ..
fi
make -j${NUM_CORES}
sudo make install
sudo ldconfig
cd ..
rm -rf build/

git clone https://github.com/p4lang/ptf.git ptf
cd ptf
git pull origin master
sudo python3 setup.py install

#dependencies
git clone https://github.com/p4lang/behavioral-model.git bmv2
cd bmv2
git checkout ${BMV2_COMMIT}
./install_deps.sh

bmv2
cd ${BUILD_DIR}
git clone https://github.com/p4lang/behavioral-model.git bmv2
cd bmv2
git checkout ${BMV2_COMMIT}

# Build behavioral-model
./autogen.sh
if [ "$DEBUG_FLAGS" = true ] && [ "$P4_RUNTIME" = true ]; then
    ./configure --with-pi --with-thrift --with-nanomsg 
    --enable-debugger --disable-elogger "CXXFLAGS=-O0 -g"
elif [ "$DEBUG_FLAGS" = true ] && [ "$P4_RUNTIME" = false ]; then
    ./configure --with-thrift --with-nanomsg --enable-debugger
    --enable-elogger "CXXFLAGS=-O0 -g"
elif [ "$DEBUG_FLAGS" = false ] && [ "$P4_RUNTIME" = true ]; then
    ./configure --with-pi --without-nanomsg --disable-elogger 
    --disable-logging-macros 'CFLAGS=-g -O2' 'CXXFLAGS=-g -O2'
else
    ./configure --without-nanomsg --disable-elogger 
    --disable-logging-macros 'CFLAGS=-g -O2' 'CXXFLAGS=-g -O2'
fi
make -j${NUM_CORES}
sudo make install
sudo ldconfig

#simple switch grpc
if [ "$P4_RUNTIME" = true ]; then
    cd targets/simple_switch_grpc
    ./autogen.sh
    if [ "$DEBUG_FLAGS" = true ]; then
        if [ "$SYSREPO" = true ]; then
            ./configure --with-sysrepo --with-thrift 
            "CXXFLAGS=-O0 -g"
        else
            ./configure --with-thrift "CXXFLAGS=-O0 -g"
        fi
    else
        if [ "$SYSREPO" = true ]; then
            ./configure --with-sysrepo --with-thrift
        else
            ./configure --with-thrift
        fi
    fi
    make -j${NUM_CORES}
    sudo make install
    sudo ldconfig
fi

cd $HOME
git clone https://github.com/mininet/mininet mininet
cd mininet
sudo PYTHON=python3 ./util/install.sh -nwv

cd ${BUILD_DIR}sudisudisudisudisudi
if [ ! -d p4-utils ]; then
    git clone https://github.com/nsg-ethz/p4-utils.git p4-utils
fi
cd p4-utils
# Build p4-utils    
sudo ./install.sh

git clone https://github.com/nsg-ethz/p4-learning.git p4-learning
