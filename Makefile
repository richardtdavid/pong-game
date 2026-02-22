PROJECT := pong
SRC_DIR := .
RELEASE_DIR := release

ODIN := odin
ODIN_WIN := powershell.exe -Command "Set-Location 'D:\freestyle\pong game'; C:\odin\odin.exe

VERSION ?= v0.1.0

.PHONY: build debug release release-linux release-windows release-macos github-release run run-debug clean

# --- Build (unoptimized, for iteration) ---

build:
	$(ODIN) build $(SRC_DIR) -out:$(PROJECT)

# --- Debug (with debug symbols) ---

debug:
	$(ODIN) build $(SRC_DIR) -out:$(PROJECT)-debug -debug

# --- Release (optimized) ---

release: release-linux release-windows release-macos

release-linux:
	@mkdir -p $(RELEASE_DIR)
	$(ODIN) build $(SRC_DIR) -out:$(RELEASE_DIR)/$(PROJECT)-linux-amd64 -target:linux_amd64 -o:speed

release-windows:
	@mkdir -p $(RELEASE_DIR)
	$(ODIN_WIN) build . -out:release\$(PROJECT)-windows-amd64.exe -target:windows_amd64 -o:speed"

release-macos:
	@mkdir -p $(RELEASE_DIR)
	$(ODIN) build $(SRC_DIR) -out:$(RELEASE_DIR)/$(PROJECT)-macos-arm64 -target:darwin_arm64 -o:speed
	$(ODIN) build $(SRC_DIR) -out:$(RELEASE_DIR)/$(PROJECT)-macos-amd64 -target:darwin_amd64 -o:speed

# --- GitHub Release ---

github-release: release
	git tag $(VERSION)
	git push origin $(VERSION)
	gh release create $(VERSION) $(RELEASE_DIR)/* --title "Pong $(VERSION)"

# --- Utilities ---

run: build
	./$(PROJECT)

run-debug: debug
	./$(PROJECT)-debug

clean:
	rm -f $(PROJECT) $(PROJECT)-debug
	rm -rf $(RELEASE_DIR)
