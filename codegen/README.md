# Codegen

This directory contains the Mapbox maps code generators for iOS. We support generating code for our higher level Style and annotations.
Code generation occurs by reading a specification file (eg. Style specification) and using a [EJS](https://ejs.co/) template files to output code directly into the project. Next to the public API code, we also generate unit and integration tests.

## Running the generators

We expose easy to use make targets to run the code generators from the root folder of this repository

```
// generate Style APIs and tests:
make generate-style-code

// generate Annotation APIs and tests:
make generate-annotation-code
```

## FAQ

#### Style-specification has entries that are only supported by gl-js, how do we handle this?

Within style-parser.js, we allow deleting entries from the specification before its provided as input to the generator:
> `delete spec["expression_name"]["values"]["interpolate-hcl"]`

