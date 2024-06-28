all:
	run

run:
	dosbox
	mount c smake
	cd smake
	snakey.com

build:
	nasm -f bin smake.asm -o smakey.com

config:
	sudo apt update; sudo apt upgrade; sudo apt autoremove
	sudo apt install dosbox
	sudo apt install nasm

clean:
	rm -rf .git .gitignore README.md
