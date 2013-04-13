BIN       = `npm bin`
COFFEEC   = $(BIN)/coffee
STYLUSC   = $(BIN)/stylus
JADEC     = $(BIN)/jade
COMPONENT = $(BIN)/component

JADE_FLAGS = --pretty

COFFEE_FILES := $(wildcard lib/*.coffee)
JS_FILES := $(patsubst lib/%.coffee, build/%.js, $(COFFEE_FILES))

STYLUS_FILES := $(wildcard styles/*.styl)
CSS_FILES := $(patsubst styles/%.styl, build/%.css, $(STYLUS_FILES))

all: build talkshow.html

build/main.js: main.coffee
	$(COFFEEC) -c --output build $< 

build/%.js: lib/%.coffee
	$(COFFEEC) -c --output build $<

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
