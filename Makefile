NAME := Feather
SCHEME := Feather
PLATFORMS := iphoneos maccatalyst

TMP := $(TMPDIR)/$(NAME)
CERT_JSON_URL := https://backloop.dev/pack.json
LIQUID_GLASS_ASSETS ?= liquid-glass/prebuilt/Assets.car

.PHONY: all clean deps liquid-glass-assets $(PLATFORMS)

all: $(PLATFORMS)

clean:
	rm -rf $(TMP)
	rm -rf packages
	rm -rf Payload

deps:
	rm -rf deps || true
	mkdir -p deps

	curl -fsSL "$(CERT_JSON_URL)" -o cert.json
	jq -r '.cert' cert.json > deps/server.crt
	jq -r '.key1, .key2' cert.json > deps/server.pem
	jq -r '.info.domains.commonName' cert.json > deps/commonName.txt

liquid-glass-assets:
	python3 liquid-glass/scripts/rebuild_assets.py


$(PLATFORMS): deps
	rm -rf _build

	@if [ "$@" = "iphoneos" ]; then \
		DEST="generic/platform=iOS"; \
	else \
		DEST="generic/platform=macOS,variant=Mac Catalyst"; \
	fi; \
	xcodebuild \
		-project Feather.xcodeproj \
		-scheme $(SCHEME) \
		-configuration Release \
		-destination "$$DEST" \
		-derivedDataPath $(TMP)/$@ \
		-skipPackagePluginValidation \
		CODE_SIGNING_ALLOWED=NO \
		ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO

	mkdir -p _build/Payload
	cp -R _build/Applications/*.app _build/Payload/Feather.app
	chmod -R 0755 _build/Payload/Feather.app
	cp deps/* _build/Payload/Feather.app/ || true
	@if [ "$@" = "iphoneos" ]; then \
		python3 liquid-glass/scripts/rebuild_assets.py --verify --catalog "$(LIQUID_GLASS_ASSETS)"; \
		test -r "$(LIQUID_GLASS_ASSETS)" || { echo "Missing optimized asset catalog: $(LIQUID_GLASS_ASSETS)" >&2; exit 1; }; \
		cp "$(LIQUID_GLASS_ASSETS)" _build/Payload/Feather.app/Assets.car; \
	fi
	codesign --force --sign - --timestamp=none _build/Payload/Feather.app

	mkdir -p packages

	@if [ "$@" = "iphoneos" ]; then \
		ditto -c -k --sequesterRsrc --keepParent _build/Payload "packages/Feather.ipa"; \
	else \
		ditto -c -k --sequesterRsrc --keepParent _build/Payload/Feather.app "packages/Feather_Catalyst.zip"; \
	fi
