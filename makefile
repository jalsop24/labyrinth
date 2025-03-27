
LSP_TYPES_URL = https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/refs/heads/main/scripts/globalTypes.d.luau

build-network:
	zap src/network.zap

build-version:
	git rev-parse --short HEAD > build/version.txt

install-packages:
	wally install

build-rojo:
	rojo build start_place.project.json -o build/start_place.rbxl
	rojo build destination_place.project.json -o build/destination_place.rbxl

build-place: build-version build-network install-packages build-rojo

fmt:
	stylua src/

lint:
	stylua src/ --check
	selene src/
	luau-lsp analyze --defs ./robloxTypes.d.luau --sourcemap ./sourcemap.json --ignore Packages/_Index/elttob_fusion@0.3.0/fusion/src/Memory/deriveScope.luau src/

sourcemap:
	rojo sourcemap > sourcemap.json

lsp-types-version:
	curl -s -o /dev/null -w "%header{etag}" --head "${LSP_TYPES_URL}"

lsp-types:
	curl "${LSP_TYPES_URL}" -o robloxTypes.d.luau

lint-setup: build-version build-network install-packages sourcemap