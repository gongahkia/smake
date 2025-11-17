all: run

run: build
	@echo "Starting DOSBox. Type the following commands in DOSBox:"
	@echo "  mount c ."
	@echo "  c:"
	@echo "  smake.com"
	@if [ -f /Applications/dosbox.app/Contents/MacOS/dosbox ]; then \
		/Applications/dosbox.app/Contents/MacOS/dosbox; \
	elif command -v dosbox >/dev/null 2>&1; then \
		dosbox; \
	else \
		open -a dosbox; \
	fi

build:
	nasm -f bin smake.asm -o smake.com

config-linux:
	sudo apt update && sudo apt upgrade && sudo apt autoremove
	sudo apt install dosbox nasm

config-macos:
	brew install nasm dosbox

clean:
	rm -f smake.com
