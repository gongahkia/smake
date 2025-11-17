all: run

run: build
	@echo "Starting DOSBox. Type the following commands in DOSBox:"
	@echo "  mount c ."
	@echo "  c:"
	@echo "  smake.com"
	dosbox

build:
	nasm -f bin smake.asm -o smake.com

config:
	sudo apt update && sudo apt upgrade && sudo apt autoremove
	sudo apt install dosbox
	sudo apt install nasm

clean:
	rm -f smake.com
