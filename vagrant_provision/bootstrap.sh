if [ -f "/.bootstrap.done" ]; then
    exit
fi

## Ставим необходимые пакеты

apt-get -y install g++

## Ставим node.js (собираем)
wget http://nodejs.org/dist/v0.10.31/node-v0.10.31.tar.gz
tar zxvf node-v0.10.31.tar.gz
cd node-v0.10.31
./configure
make
make install
cd ..
rm -rf node-v0.10.31
rm node-v0.10.31.tar.gz

touch /.bootstrap.done