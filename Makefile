###
### Codegen targets
###

.PHONY: generate-style-code
generate-style-code:
	cd codegen && npm install && node style-generator/generate-style-code.js

.PHONY: generate-annotation-code
generate-annotation-code:
	cd codegen && npm install && node annotation-generator/generate-annotations.js

.PHONY: generate-style-code-private
generate-style-code-private:
	cd codegen && npm install && node style-generator/generate-style-code --private-api

.PHONY: generate-annotation-code-private
generate-annotation-code-private:
	cd codegen && npm install && node annotation-generator/generate-annotations.js --private-api

.PHONY: generate-private-code
generate-private-code:
	make generate-style-code-private && make generate-annotation-code-private

.PHONY: generate-public-code
generate-public-code:
	make generate-style-code && make generate-annotation-code
