/**
 * Stripped from Google Web Starter Kit
 */

'use strict';

// Include Gulp & tools we'll use
var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var del = require('del');
var runSequence = require('run-sequence');
var browserSync = require('browser-sync');
var pagespeed = require('psi');
var reload = browserSync.reload;

var MyEndpoint = require('./lib/MyEndpoint.js');

// Lint JavaScript
gulp.task('jshint', function () {
  return gulp.src('app/scripts/**/*.js')
    .pipe(reload({stream: true, once: true}))
    .pipe($.jshint())
    .pipe($.jshint.reporter('jshint-stylish'))
    .pipe($.if(!browserSync.active, $.jshint.reporter('fail')));
});

// Optimize images
gulp.task('images', function () {
  return gulp.src('app/images/**/*')
    .pipe($.cache($.imagemin({
      progressive: true,
      interlaced: true
    })))
    .pipe(gulp.dest('dist/images'))
    .pipe($.size({title: 'images'}));
});

// Copy all non html files at the root level (app)
gulp.task('copy', function () {
  return gulp.src([
    'app/*.*',
    '!app/*.html'
  ], {
    dot: true
  }).pipe(gulp.dest('dist'))
    .pipe($.size({title: 'copy'}));
});

var minify = function(path, env) {
  gulp.src([path])
  .pipe($.replace(/scripts\/config.js/g, 
      env ? 'scripts/config-'.concat(env).concat('.js') : 'scripts/config.js'))
  .pipe($.usemin({
    html: [$.minifyHtml({empty: true})],
    css: [$.minifyCss(), 
          $.size({title: 'css ' + path}), 
          'concat'],
    vendor: [$.uglify(), 
             $.size({title: 'vendor ' + path}), 
             'concat'],
    js: [$.ngAnnotate(), 
         $.uglify(), 
         $.size({title: 'js ' + path}), 
         'concat']
  }))
  .pipe(gulp.dest('dist'));
};

//Minify css and js marked in html for build
gulp.task('minify', function() {
minify('app/app.html');
});

//Minify css and js marked in html for build, for prod env
gulp.task('minify-prod', function() {
minify('app/app.html', 'prod');
});

// Minify partials html
gulp.task('partials', function() {
  gulp.src('app/partials/*.html')
       .pipe($.minifyHtml({empty: true}))
       .pipe(gulp.dest('dist/partials/'));
});

// Copy icon fonts
gulp.task('icons', function() {
  gulp.src(['app/bower_components/font-awesome/fonts/**.*'])
  .pipe(gulp.dest('dist/fonts'));
});

// Clean output directory
gulp.task('clean', del.bind(null, ['dist/*', '!dist/.git'], {dot: true}));

// Watch files for changes & reload web app
gulp.task('serve', [], function () {
  browserSync({
    notify: false,
    logPrefix: 'gulp serve',
    server: {baseDir: 'app', index: 'app.html'},
    port: 8104
  });

// listen protobuf socket
  MyEndpoint.trackBlockChanges('localhost:7053');


  //gulp.watch(['app/**.html'], reload);*/
  gulp.watch(['app/app.html'], reload);
  gulp.watch(['app/partials/*.html'], reload);
  gulp.watch(['app/styles/*.css'], reload);
  gulp.watch(['app/scripts/**/*.js'], ['jshint']);
  gulp.watch(['app/images/**/*'], reload);
});

// Watch files for changes & reload mobile app
gulp.task('serve:ionic', [], function () {
browserSync({
 notify: false,
 logPrefix: 'gulp serve:ionic',
 server: {baseDir: 'ionic/www', index: 'index.html',
   routes: {
     '/scripts': 'app/scripts',
     '/bower_components': 'app/bower_components',
     '/vendor_mods': 'app/vendor_mods'
   }},
 port: 8100
});

gulp.watch(['ionic/www/**/*.html'], reload);
gulp.watch(['ionic/www/css/*.css'], reload);
gulp.watch(['ionic/www/js/**/*.js'], ['jshint']);

gulp.watch(['app/scripts/**/*.js'], ['jshint']);
});

// Build and serve the output from the dist build
gulp.task('serve:dist', [], function () {
  browserSync({
    notify: false,
    logPrefix: 'gulp serve:dist',
    server: {baseDir: 'dist', index: 'app.html'},
    port: 8104
  });
});

var dist = function(env) {
  var seq = ['jshint', 'partials', 'icons', 'images', 'copy'];
  if(env) {
    seq.push('minify-'.concat(env));
  }
  else {
    seq.push('minify');
  }
  runSequence('clean', seq);
}

//Build minified files, the default task
gulp.task('default', function(cb) {
  dist();
});

//Build minified files for prod
gulp.task('prod', function(cb) {
  dist('prod');
});

//Build minified files for dev
gulp.task('dev', function(cb) {
  dist('dev');
});

// Run PageSpeed Insights
gulp.task('pagespeed', function (cb) {
  // Update the below URL to the public URL of your site
  pagespeed.output('example.com', {
    strategy: 'mobile',
    // By default we use the PageSpeed Insights free (no API key) tier.
    // Use a Google Developer API key if you have one: http://goo.gl/RkN0vE
    // key: 'YOUR_API_KEY'
  }, cb);
});