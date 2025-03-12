
build-network:
	zap src/network.zap

build-script:
	./build.sh

build-place: build-network build-script	

fmt:
	stylua src/

lint:
	stylua src/ --check
	selene src/
	luau-lsp analyze --defs ./robloxTypes.d.luau --sourcemap ./sourcemap.json src/

lsp-types:
	curl https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/refs/heads/main/scripts/globalTypes.d.luau -o robloxTypes.d.luau