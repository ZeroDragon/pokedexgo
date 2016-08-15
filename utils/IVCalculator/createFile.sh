#!/usr/bin/env bash

coffee --no-header -bc ivCalculator.coffee
browserify ivCalculator.js -o output.js
uglifyjs output.js -mco ivCalculator.js
rm output.js
mv ivCalculator.js ../../app/assets/scripts/