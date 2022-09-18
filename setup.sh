#!/bin/sh

echo "Upgrading packages"
yes | sudo apt update
yes | sudo apt upgrade

echo "------------Installing required packages------------"
# yes | sudo apt install unzip git-all
sudo apt install unzip
sudo add-apt-repository ppa:deadsnakes/ppa && apt-get update
pkgs="wget make g++ automake autoconf sox gfortran libtool subversion python2.7 python3.8 zlib1g-dev"
sudo apt-get install $pkgs

echo "------------Installing Kaldi------------"
echo "------------Installing Kaldi - Tools install------------"
git clone https://github.com/kaldi-asr/kaldi.git kaldi --origin upstream
cd ./kaldi/tools
# extras/install_mkl.sh
make
cd ../src
./configure
make
extras/check_dependencies.sh

echo "Did you receive the \`all OK.\` message? (y/n)"
read response
if [ $response == "n" ]; then
	echo "Please install all required dependencies and then continue the installation with ./kaldi/tools/INSTALL"
	exit
fi

echo "Installing Kaldi - Src install"
cd ../src
./configure --shared
if [ 1 == "$cores" ]; then
	yes | make CXX=g++
	yes | make depend CXX=g++
else
	yes | make CXX=g++ -j $cores
	yes | make depend CXX=g++ -j $cores
fi

echo "Kaldi Install Complete"
echo "Cloning Project Repository"
cd ../egs
git clone https://github.com/hootan09/kaldiASR.git
cd kaldiASR/s5



