
build-place:
	./build.sh

fmt:
	stylua src/

lint:
	stylua src/ --check && selene src/