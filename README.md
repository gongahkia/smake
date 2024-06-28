# `SMAke`

16-bit snake game in x86 assembly that can theoretically run without any Operating System.

## Install

Smake requires a Debian-based distro, and depends on [NASM](https://www.nasm.us/) and [DOSBox](https://www.dosbox.com/).

```console
$ sudo apt install Make
$ git clone https://github.com/gongahkia/smake
$ cd smake
$ make config
$ make build
```

## Usage

```console
$ make 
```

## Notes

* I exclude any and all liability for hardware damage from running assembly and fiddling with BIOS. Know [the risks](https://www.reddit.com/r/learnprogramming/comments/xkv928/how_assembly_programming_can_be_dangerous/) before running this.
* Smake is written for x86 assembly, and not any other assembly flavours. I do not know how to write them because I am an idiot.
* This repo is finished. It will not be updated.
* Also [see](https://github.com/cepa/snake).
