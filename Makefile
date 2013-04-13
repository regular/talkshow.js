BIN       = `npm bin`
COFFEEC   = $(BIN)/coffee
STYLUSC   = $(BIN)/stylus
JADEC     = $(BIN)/jade
COMPONENT = $(BIN)/component

JADE_FLAGS = --pretty

LIB_FILES := $(wildcard lib/*.coffee)
TEST_FILES := $(wildcard test/*.coffee)
LIB_JS_FILES := $(patsubst lib/%.coffee, build/lib/%.js, $(LIB_FILES))
TEST_JS_FILES := $(patsubst test/%.coffee, build/test/%.js, $(TEST_FILES))
JS_FILES := $(LIB_JS_FILES) $(TEST_JS_FILES)

STYLUS_FILES := $(wildcard styles/*.styl)
CSS_FILES := $(patsubst styles/%.styl, build/%.css, $(STYLUS_FILES))

all: build talkshow.html

build/main.js: main.coffee
	$(COFFEEC) -c --output build $< 

build/lib/%.js: lib/%.coffee
	$(COFFEEC) -c --output build/lib $<

build/test/%.js: test/%.coffee
	$(COFFEEC) -c --output build/test $<

build/%.css: styles/%.styl
	$(STYLUSC) --out build $<

build: components build/main.js $(JS_FILES) $(CSS_FILES)
	$(COMPONENT) build --dev --standalone main

template.js: template.html
	@$(COMPONENT) convert $<

components: component.json
	$(COMPONENT) install --dev

talkshow.html: views/talkshow.jade
	$(JADEC) $(JADE_FLAGS) --out . $<

clean:
	rm -fr build components talkshow.html

.PHONY: clean
