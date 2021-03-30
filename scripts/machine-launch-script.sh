#!/bin/bash

set -ex
set -o pipefail

echo "machine launch script started" > /home/centos/machine-launchstatus

{
sudo yum install -y mosh
sudo yum groupinstall -y "Development tools"
sudo yum install -y gmp-devel mpfr-devel libmpc-devel zlib-devel vim git java java-devel
curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
sudo yum install -y sbt texinfo gengetopt libffi-devel
sudo yum install -y expat-devel libusb1-devel ncurses-devel cmake "perl(ExtUtils::MakeMaker)"
# deps for poky
sudo yum install -y python36 patch diffstat texi2html texinfo subversion chrpath git wget
# deps for qemu
sudo yum install -y gtk3-devel
# deps for firesim-software (note that rsync is installed but too old)
sudo yum install -y python36-pip python36-devel rsync
# Install GNU make 4.x (needed to cross-compile glibc 2.28+)
sudo yum install -y centos-release-scl
sudo yum install -y devtoolset-8-make

# install DTC
sudo yum -y install dtc

# get a proper version of git
sudo yum -y remove git
sudo yum -y install epel-release
sudo yum -y install https://repo.ius.io/ius-release-el7.rpm
sudo yum -y install git224

# install verilator
git clone http://git.veripool.org/git/verilator
cd verilator/
git checkout v4.034
autoconf && ./configure && make -j4 && sudo make install
cd ..

# bash completion for manager
sudo yum -y install bash-completion

# graphviz for manager
sudo yum -y install graphviz python-devel

# used for CI
sudo yum -y install expect

python3 -m pip install -U pip setuptools
python3 -m pip install fabric==1.14.0
python3 -m pip install boto3==1.6.2
python3 -m pip install colorama==0.3.7
python3 -m pip install argcomplete==1.9.3
python3 -m pip install graphviz==0.8.3
# for some of our workload plotting scripts
python3 -m pip install --upgrade --ignore-installed pyparsing
python3 -m pip install numpy==1.16.6
python3 -m pip install kiwisolver==1.1.0
python3 -m pip install matplotlib==2.2.2
python3 -m pip install pandas==0.22.0
# new awscli on 1.6.0 AMI is broken with our versions of boto3
python3 -m pip install awscli==1.15.76

activate-global-python-argcomplete --user

} 2>&1 | tee /home/centos/machine-launchstatus.log

# get a regular prompt
echo "PS1='\u@\H:\w\\$ '" >> /home/centos/.bashrc
echo "machine launch script completed" >> /home/centos/machine-launchstatus
