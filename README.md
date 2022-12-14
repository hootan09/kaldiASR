# Under Construction (Not Complete Yet) ...

### KALDI Installation & Train

[Kaldi Simple Learning](https://github.com/hootan09/kaldiASR/tree/main/doc_learning)

#### install Dependency with Setup shell (Ubuntu 22.04 LTS):
```sh
$ wget https://raw.github.com/hootan09/kaldiASR/master/setup.sh
$ sudo bash setup.sh
```

### Known Error:
```sh

# Check Dependency
sudo ./kaldi/tools/extras/check_dependencies.sh

# Add python2.7 to path
sudo ./kaldi/tools/env.sh /usr/bin/python2.7
sudo ln -fs /usr/bin/python2.7 ./tools/python/python2
```

## Running Model with Vosk:
#### 
```sh
# we can use Vosk for all Platform & Languages like Go ,C# ,Node.js ,Python ...
https://github.com/alphacep/vosk-api
```

# Build model for Vosk
This guide tries to explain how to create your own compatible model with [Vosk](https://alphacephei.com/vosk/), with the use of [Kaldi](https://kaldi-asr.org/).

# Preparation (Not Needed already done with setup.sh)
If you are going to do the training with the GPU, download and install cuda before you go ahead and check compatibility between cuda and version of gcc and g++.

As a first step to start creating your dataset, you need to download the Kaldi project from github with the following command:
```sh 
git clone https://github.com/kaldi-asr/kaldi.git
```     
Once downloaded, you have to compile all the programs that you will need and will help you with dataset preparation and training. Then run the following command:
```sh 
cd kaldi/tools/; make; cd ../src; ./configure; make    
``` 
If you are NOT going to use the GPU for training, the command `./configure` must become:
```sh
./configure --use-cuda=no    
``` 
> ℹ️ If you are going to use Kaldi with software such as GridEngine, Tork, slurm and so on, you can overlook this change. If you want more specific information on which parallelization script to use, see [here](https://kaldi-asr.org/doc/queue.html#parallelization_specific).

Finally you have to download this project too:
```sh 
git clone https://github.com/hootan09/kaldiASR.git   
``` 
make the scripts executable:
```sh 
chmod +x kaldiASR/*.sh    
``` 
and copy them to the right directory:
```sh 
mv kaldiASR PATH_TO_KALDI/egs/.
```
create softlink (for utils & step) if not exists:
```sh
sudo ln -s ../../wsj/s5/utils .
sudo ln -s ../../wsj/s5/steps/ .
```
Then you have to edit the file `cmd.sh` under `kaldi/egs/kaldiASR/s5` (**which is the directory where you will work until the end of the guide**). Replace all `queue.pl` with `run.pl`.

# Data Creation
Thanks to this [guide](https://kaldi-asr.org/doc/data_prep.html), you will be able to create the `data/train` directory with its necessary training files.

The directory will have to look something like this:
```sh
$ ls data/train
cmvn.scp data/ frame_shift text utt2num_frames wav.scp conf/ feats.scp spk2utt utt2dur utt2spk
``` 
There are only 3 files you have to create manually: `text`, `wav.scp` and `utt2spk`.
 
### text
In the file you have to insert the utterance-id with the respective sentence. The utterance-id is simply a string that you can choose at random, but I suggest you to use this type of formatting: `speakerName-incrementalNumber`.
```sh 
$ head -3 data/train/text
matteo-0 This is an example sentence
marco-1 This is an example sentence
veronica-2 This is an example sentence
```      
### wav.scp 
In the file you have to insert the utterance-id with the respective absolute or relative path (depending on where you run the command, not where the wav.scp file is) of the audio file.
```sh 
$ head -3 data/train/wav.scp
matteo-0 /home/kaldi/egs/mini_librispeech/s5/audio/test1.wav
marco-1 audio/test2.wav
veronica-2 audio/test3.wav
```     
 
### utt2spk
In the file you have to insert the utterance-id with the respective name of the speaker.
```sh 
$ head -3 data/train/utt2spk
matteo-0 matteo
marco-1 marco
veronica-2 veronica
```

### Files you don't need to create yourself
 
#### spk2utt
```sh
utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
```     

#### feats.scp 
> ℹ️ If you did not use `run.pl` as a parallelization script, edit the following command.
```sh 
steps/make_mfcc.sh --nj 10 --cmd "run.pl" data/train exp/make_mfcc/train $mfccdir
```     
 
#### cmvn.scp
```sh 
steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir
``` 
The files `data/train/segments`, `data/train/reco2file_and_channel` and `data/train/spk2gender` are optional, so it's up to you to choose if they are needed for your model.
 
> ⚠️ The audio files that you are going to record or download from the internet for your dataset must have a format similar to: `RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, mono 16000 Hz`. You can check this with the `file` command, if you are on a linux distribution. Otherwise you may have problems, for example with the command `steps/make_mfcc.sh --nj 10 --cmd "run.pl" data/train exp/make_mfcc/train $mfccdir`.
 
Once you have created all the files, you can check if everything is correct with the following commands:
```sh 
utils/validate_data_dir.sh data/train
utils/fix_data_dir.sh data/train (in case of errors with the previous command)
```     

# Lang Creation 
To create the `data/lang` directory you only need to create one file, namely `data/local/dict/lexicon.txt`. This file consists of every single word in your utterances and its phoneme. Looking for a free program that allows to have the phoneme of a word of the Italian dictionary, but not only, I found espeak that with the command `espeak -q -v fa --ipa=3 test` returns the phoneme, in this example, of the word 'test'.
 
The `-q` option is for not playing any voices, `-v` indicates the language, `--ipa` displays the phoneme according to the International Phonetic Alphabet, and the `3` argument in the `--ipa` option indicates that the output of the phoneme will be broken up by underscores. This will be useful since in the file `data/local/dict/lexicon.txt` the phoneme should have a form like:
```sh 
$ head -2 lexicon.txt
test t ˈɛ s t
hi h ˈaɪ
```      
So with a script in python, bash and so on, you can replace the underscores with a space.

When you are done with `data/local/dict/lexicon.txt`, you can start creating the other files under `data/local/dict/`.
 
### nonsilence_phones.txt
```sh 
cut -d ' ' -f 2- data/local/dict/lexicon.txt | sed 's/ /\n/g' | sort -u > data/local/dict/nonsilence_phones.txt
```     
> ⚠️ After running this command check, with any text editor, if the first line of the file is not empty, otherwise you have to delete it.
 
### silence_phones.txt
```sh 
echo -e 'SIL\noov\nSPN\n' > data/local/dict/silence_phones.txt
```     
 
### optional_silence.txt
```sh 
echo 'SIL\n' > data/local/dict/optional_silence.txt
```      
Once everything is created, it is important to add `<UNK> SPN` inside `data/local/dict/lexicon.txt` (by convention we insert it at the beginning of the file):
```sh 
$ head -3 data/local/dict/lexicon.txt
<UNK> SPN
test t ˈɛ s t
hi h ˈaɪ
```     
 Now you can run:
```sh 
utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang
```     
Here too you can check if everything is correct with the commands:
```sh 
utils/validate_lang.pl data/lang
utils/validate_dict_dir.pl data/local/dict
```     

# Language Model Creation
To create the language model you need to run the `lm_creation.sh` script. But first you need to create another file: `data/local/corpus.txt`. This file must contain all the sentences you want to use in your dataset, one for each line. To create it, you can simply start from the `data/train/text` file and with a script delete the utterance-id.
 
Also, to run `lm_creation.sh`, you have to install the SRILM library. To install it, download the .tar.gz file from this [site](http://www.speech.sri.com/projects/srilm/download.html). Once downloaded, rename the file so that there is no version number, so you have to end up with the file named like this: `srilm.tar.gz`. Now take the file and put it under the `kaldi/tools` folder and run:
```sh 
./install_srilm.sh && ./env.sh
```     
##### note: srilm mybe not accessible from iran todo:
```sh
sudo apt-get install gawk
cp SRILM/install_srilm.sh <kali_path>/tools/.
cp srilm.tar.gz <kaldi_path>/tools/. # download (srilm-1.7.2.tar.gz) by this link http://www.speech.sri.com/projects/srilm/download.html
./install_srilm.sh && ./env.sh
```
If `env.sh` does not run, you must make it executable with the `chmod` command.
 
Now you can create your language model with the following command:
```sh 
./lm_creation.sh
```     
 
# Alignaments
Before you can start the actual training, you have to complete other steps such as alignment and monophonic training and so on. To do all this, just run this command:
```sh 
./align_train.sh
```     

# Training
As last things, you have to edit some lines inside the training script `local/chain/tuning/run_tdnn_1j.sh` with any text editor:
```sh 
train_set=train_clean_5
test_sets=dev_clean_2
```      
replace it with:
```sh 
train_set=train
test_sets=test
```     
Still within `local/chain/tuning/run_tdnn_1j.sh`, edit:
```sh 
--use-gpu=true
```      
with:
```sh 
--use-gpu=wait (if you do NOT have to use the GPU replace "wait" with "false")
```      
and then also run:
```sh 
sudo nvidia-smi -c 3
```     
> ℹ️ The reason for this command and the last change are cited [here](https://kaldi-asr.org/doc/cudamatrix.html). Make sure you need to use the GPU in "wait" mode. In case you tried to start the training with "yes" and then got an error like `error: core dump`, try using "wait".
 
Then, inside `local/nnet3/run_ivector_common.sh` edit the lines:
```sh 
train_set=train_clean_5
test_sets=”dev_clean_2”
```      
with:
```sh 
train_set=train
test_sets=”test”
```     
Now run the training:
```sh 
local/chain/tuning/run_tdnn_1j.sh
```     
 
# Get model
If the training didn't give you any error, to have your model compatible with Vosk you can start by taking all the necessary files and put them in a folder. This is done by running:
```sh 
./copy_final_result.sh
```      
As a last thing you need to organize those files so that Vosk doesn't have any problems. Seeing from this [site](https://alphacephei.com/vosk/models#model-structure), in the "Model structure" section, you can move the files you have into your folder and place them that way.

## Model structure
Once you trained the model arrange the files according to the following layout (see en-us-aspire for details):

-   `am/final.mdl` - acoustic model
-   `am/global_cmvn.stats` - required for online-cmvn models, if present enables online cmvn on features.
-   `conf/mfcc.conf` - mfcc config file. Make sure you take mfcc\_hires.conf version if you are using hires model (most external ones)
-   `conf/model.conf` - provide default decoding beams and silence phones. you have to create this file yourself, it is not present in kaldi model
-   `conf/pitch.conf` - optional file to create feature pipeline with pitch features. Might be missing if model doesn’t use pitch
-   `ivector/final.dubm` - take ivector files from ivector extractor (optional folder if the model is trained with ivectors)
-   `ivector/final.ie`
-   `ivector/final.mat`
-   `ivector/splice.conf`
-   `ivector/global_cmvn.stats`
-   `ivector/online_cmvn.conf`
-   `graph/phones/word_boundary.int` - from the graph
-   `graph/HCLG.fst` - this is the decoding graph, if you are not using lookahead
-   `graph/HCLr.fst` - use Gr.fst and HCLr.fst instead of one big HCLG.fst if you want to run rescoring
-   `graph/Gr.fst`
-   `graph/phones.txt` - from the graph
-   `graph/words.txt` - from the graph
-   `rescore/G.carpa` - carpa rescoring is optional but helpful in big models. Usually located inside data/lang\_test\_rescore
-   `rescore/G.fst` - also optional if you want to use rescoring, also used for interpolation with RNNLM
-   `rnnlm/feat_embedding.final.mat` - RNNLM embedding for rescoring. Optional if you have it.
-   `rnnlm/special_symbol_opts.conf` - RNNLM model options
-   `rnnlm/final.raw` - RNNLM model
-   `rnnlm/word_feats.txt` - RNNLM model word feats
 
You may have noticed that Vosk says that the `conf/model.conf` file must be created by you because it is not present after training. In all my models I have always created that file with the following lines:
```sh 
--min-active=200
--max-active=3000
--beam=10.0
--lattice-beam=2.0
--acoustic-scale=1.0
--frame-subsampling-factor=3
--endpoint.silence-phones=1:2:3:4:5:6:7:8:9:10
--endpoint.rule2.min-trailing-silence=0.5
--endpoint.rule3.min-trailing-silence=1.0
--endpoint.rule4.min-trailing-silence=2.0
```      
 Now you have your model perfectly compatible with Vosk.
 
 # Clear folders
 you can use **./clean.sh** to clear unused files in project. also with argument **cleandata** to clear data folder also
 ```sh
 ./clean.sh
 
 # or
 # ./clean.ch cleandata # wipe data folder
 ```
 
# Troubleshooting
-   If you get an error while doing the `make` under the `src` folder saying for example `this version of cuda supports gcc versions <= 7.0`, after installing the correct version of cuda, you will have to re-run the `make` under the `tools` folder first and then under `src`.
-   When running `./configure` you may get an error asking you to download the MKL library. If you are on a debian based distribution, to download it you simply run `sudo apt install intel-mkl` . In the installation it will ask you to replace another library for 'BLAS and LAPACK'; I never did that. If even being on debian you don't find the package on your repositories, follow this [guide](https://www.r-bloggers.com/2018/04/18-adding-intel-mkl-easily-via-a-simple-script/).
-   If you got this error `skipped: word WORD not in symbol state`, it means that within `data/lang/words.txt` there is not that particular word. To solve it you have to correct the file `data/local/dict/lexicon.txt`, because most likely it's not there either, and run again `cut -d ' ' -f 2- lexicon.txt | sed 's/ /\n/g' | sort -u > nonsilence_phones.txt` and `utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang`
-   It may happen that the training crashes during iterations without a specific error and if you try to run `nvidia-smi` it will also return an error. To fix this, run `sudo nvidia-smi -pm 1` before training.
