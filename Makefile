test:
	NODE_ENV=test node_modules/mocha/bin/mocha --compilers coffee:coffee-script test/spec.coffee  --ignore-leaks
build:
	node_modules/coffee-script/bin/coffee -c -o dist/ src/
	node_modules/uglify-js/bin/uglifyjs dist/waiter.js -c -o dist/waiter.js -m