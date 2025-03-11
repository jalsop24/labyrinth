
build-place:
	./build.sh

fmt:
	stylua src/

lint:
	stylua src/ --check && selene src/ && luau-lsp analyze --defs ./robloxTypes.d.luau --sourcemap ./sourcemap.json src/

lsp-types:
	curl https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/refs/heads/main/scripts/globalTypes.d.luau -o robloxTypes.d.luau