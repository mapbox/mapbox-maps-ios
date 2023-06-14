###
### Codegen targets
###
regenerate-code: delete-code generate-code

npm-install:
	cd codegen && npm install

generate-style-code: npm-install
	cd codegen && node style-generator/generate-style-code.js

generate-annotation-code: npm-install
	cd codegen && node annotation-generator/generate-annotations.js

generate-annotation-code-private: npm-install
	cd codegen && node annotation-generator/generate-annotations.js --private-api

generate-public-code: generate-style-code generate-annotation-code

generate-code: generate-style-code generate-annotation-code

delete-code:
	@echo "Deleting generated code"
	@find {mapbox-maps-ios,private}/{Sources,Tests}/MapboxMaps{,Tests}/{Annotations,Style}/Generated \
		-not -name ".swiftlint.yml" -delete 2>/dev/null || true

.PHONY: generate-style-code generate-annotation-code generate-annotation-code-private generate-private-code generate-public-code generate-code
.PHONY: delete-code regenerate-code
