#### install with Setup shell (Ubuntu 22.04 LTS):
```sh
$ wget https://raw.github.com/hootan09/kaldiASR/master/Setup_Kaldi/setup.sh
$ sudo bash setup.sh 10 # 10 is the number of cpu cores for install kaldi
# or 
# $ y | sudo bash setup.sh 10
# or install Manually with http://kaldi-asr.org/doc/tutorial_setup.html
```

### Known Error:
```sh

# Check Dependency
sudo ./kaldi/tools/extras/check_dependencies.sh

# Add python2.7 to path
sudo ./kaldi/tools/env.sh /usr/bin/python2.7
sudo ln -fs /usr/bin/python2.7 ./tools/python/python2

#utils/prepare_lang.sh: line 547: fstaddselfloops: command not found
#ERROR: FstHeader::Read: Bad FST header: standard input
wget http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-1.6.5.tar.gz
tar zxvf openfst-1.6.5.tar.gz
./configure
make
make install
```

## Running:
#### 
```sh
# we can use Vosk for all Platform & Languages like Go ,C# ,Node.js ,Python ...
https://github.com/alphacep/vosk-api

# Other

```