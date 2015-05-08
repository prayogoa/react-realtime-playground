var compileCJSX = require('broccoli-cjsx');
var compileCoffee = require('broccoli-coffee');
var pickFiles = require('broccoli-funnel');
var mergeTrees = require('broccoli-merge-trees');
var browserify = require('broccoli-browserify');
var compileSass = require('broccoli-sass');
var instrument = require('broccoli-debug').instrument;

var js = compileCJSX('src/coffee');
js = compileCoffee(js);
js = mergeTrees([js, 'src/js']);
js = browserify(js, {
  entries: ['./index.js'],
  outputFile: './bundle.js'
});

js = pickFiles(js, {
  srcDir: '/',
  destDir: 'js'
});

var css = compileSass(['src/sass'], '/index.sass', '/css/index.css');

var index = pickFiles('public', {
  srcDir: '/',
  destDir: '/'
});

module.exports = mergeTrees([js, index, css]);
