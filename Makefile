DEBUG_DIR=out/debug
RELEASE_DIR=out/release
RELOAD_DIR=out/reload
WEB_DIR=out/web

ODIN_ROOT=/opt/homebrew/Cellar/odin/2024-12/libexec

FILES=src/web/main_web.c $(WEB_DIR)/game.wasm.o ${ODIN_ROOT}/vendor/raylib/wasm/libraylib.a
FLAGS=-sUSE_GLFW=3 -sASYNCIFY -sASSERTIONS -DPLATFORM_WEB --shell-file src/web/index_template.html --preload-file assets

debug:
	odin build src/release -out:$(DEBUG_DIR)/debug.bin -strict-style -vet -debug
	cp -R assets $(DEBUG_DIR)
	
release:
	odin build src/release -out:$(RELEASE_DIR)/release.bin -strict-style -vet -no-bounds-check -o:speed
	cp -R assets $(RELEASE_DIR)

reload:
	./reload.sh

web:
	odin build src/web -target:freestanding_wasm32 -build-mode:obj -define:RAYLIB_WASM_LIB=env.o -vet -strict-style -o:speed -out:$(WEB_DIR)/game
	emcc -o $(WEB_DIR)/index.html $(FILES) $(FLAGS) && rm $(WEB_DIR)/game.wasm.o
	
clean:
	-rm -r $(DEBUG_DIR)/* $(RELEASE_DIR)/* $(RELOAD_DIR)/* $(WEB_DIR)/*
	ln -s ../../assets out/reload
