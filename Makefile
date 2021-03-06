MAKEFLAGS += --jobs=6
TMP_DIR = ./tmp
OUTPUT_DIR = ./dist

# Federalist builds overwrite the output directory.
ifdef SITE_PREFIX
	OUTPUT_DIR = ./_site
endif

install-jekyll: install-bundler
	bundle check || bundle install

install-bundler:
	gem list -i bundler || gem install bundler

start: start-docs start-assets

start-docs:
	bundle exec jekyll serve --watch

start-assets: build-fonts build-images
	NODE_ENV=development ./node_modules/.bin/gulp watch

lint:
	./node_modules/.bin/gulp lint

build: build-docs build-assets

build-docs:
	JEKYLL_ENV=production bundle exec jekyll build

build-assets: build-sass-and-js build-fonts build-images copy-scss

build-sass-and-js:
	NODE_ENV=production \
	DISABLE_NOTIFIER=true \
	OUTPUT_DIR=$(OUTPUT_DIR) \
	./node_modules/.bin/gulp build

build-fonts:
	mkdir -p $(OUTPUT_DIR)/assets/fonts
	cp -r node_modules/uswds/src/fonts $(OUTPUT_DIR)/assets

build-images:
	mkdir -p $(OUTPUT_DIR)/assets/img
	cp -r node_modules/uswds/src/img $(OUTPUT_DIR)/assets
	cp -r src/img $(OUTPUT_DIR)/assets

copy-scss:
	./node_modules/.bin/gulp copy-scss

test: build
	make test-runners

test-runners: test-runner-pa11y test-runner-jest

test-runner-pa11y:
	./scripts/pa11y.sh

test-runner-jest:
	./scripts/jest.sh

clean:
	rm -rf $(OUTPUT_DIR)
	rm -rf $(TMP_DIR)
