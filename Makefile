###
### Codegen targets
###

.PHONY: generate-style-code
generate-style-code:
	cd codegen && npm install && node style-generator/generate-style-code.js

.PHONY: generate-annotation-code
generate-annotation-code:
	cd codegen && npm install && node annotation-generator/generate-annotations.js

