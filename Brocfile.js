var compileCJSX = require('broccoli-cjsx');
var compileCoffee = require('broccoli-coffee');
var pickFiles = require('broccoli-funnel');
var mergeTrees = require('broccoli-merge-trees');
var browserify = require('broccoli-browserify');
var compileSass = require('broccoli-sass');
var autoprefixer = require('broccoli-autoprefixer');

var  js = pickFiles("src", {
	srcDir:"/",
	destDir: "/lib"
});

js = mergeTrees([js, 'example/src']);
js = compileCJSX(js);
js = compileCoffee(js);
js = browserify(js, {
  entries: ['./index.js'],
  outputFile: './bundle.js'
});

js = pickFiles(js, {
  srcDir: '/',
  destDir: 'js'
});

var css = compileSass(['example/sass'], '/index.sass', '/css/index.css');
css = autoprefixer(css, {cascade:true});

var index = pickFiles('example/public', {
  srcDir: '/',
  destDir: '/'
});

module.exports = mergeTrees([js, index, css]);
