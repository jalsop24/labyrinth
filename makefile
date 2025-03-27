PLACE_NAMES = start_place destination_place

LSP_TYPES_URL = https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/refs/heads/main/scripts/globalTypes.d.luau
LSP_IGNORE = Packages/_Index/elttob_fusion@0.3.0/fusion/src/Memory/deriveScope.luau
TYPE_CHECK = luau-lsp analyze --defs ./robloxTypes.d.luau --ignore "${LSP_IGNORE}"


build-network:
	zap src/network.zap

build-version:
	git rev-parse --short HEAD > build/version.txt

install-packages:
	wally install

build-rojo:
	@for place in $(PLACE_NAMES); do \
		rojo build $$place.project.json -o build/$$place.rbxl; \
	done

build-place: build-version build-network install-packages build-rojo

fmt:
	stylua src/

lint:
	stylua src/ --check
	selene src/
	@for place in $(PLACE_NAMES); do \
		echo "Type check $$place"; \
		$(TYPE_CHECK) --sourcemap $$place\_sourcemap.json src/common src/$$place; \
	done

sourcemap:
	@for place in $(PLACE_NAMES); do \
		rojo sourcemap $$place.project.json > $$place\_sourcemap.json; \
	done

lsp-types-version:
	curl -s -o /dev/null -w "%header{etag}" --head "${LSP_TYPES_URL}"

lsp-types:
	curl "${LSP_TYPES_URL}" -o robloxTypes.d.luau

lint-setup: build-version build-network install-packages sourcemap