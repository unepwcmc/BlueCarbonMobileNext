gulp = require('gulp');

var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var declare = require('gulp-declare');
var plumber = require('gulp-plumber');
var sass = require('gulp-sass');

var paths = {
  application: 'www/src/**/*.coffee',
  sass: 'www/src/sass/**/*.scss',
  vendor: 'www/src/vendor/**/*',
  images: 'www/src/images/**/*',
  tests: 'www/tests/src/**/*'
};

gulp.task('application', function() {
  return gulp.src(paths.application)
    .pipe(plumber())
    .pipe(coffee())
    .pipe(gulp.dest('www/dist/'));
});

gulp.task('vendor', function() {
  return gulp.src(paths.vendor)
    .pipe(gulp.dest('www/dist/vendor/'));
})

gulp.task('sass', function () {
  gulp.src(paths.sass)
    .pipe(plumber())
    .pipe(sass())
    .pipe(gulp.dest('www/dist/css/'));
});

gulp.task('images', function() {
  return gulp.src(paths.images)
    .pipe(gulp.dest('www/dist/images/'));
})

gulp.task('tests', function() {
  return gulp.src(paths.tests)
    .pipe(plumber())
    .pipe(coffee())
    .pipe(gulp.dest('www/tests/dist/'));
})

// Rerun the task when a file changes
gulp.task('watch', function() {
  gulp.watch(paths.application, ['application']);
  gulp.watch(paths.vendor, ['vendor']);
  gulp.watch(paths.sass, ['sass']);
  gulp.watch(paths.images, ['images']);
  gulp.watch(paths.tests, ['tests']);
});

gulp.task('default', ['application', 'vendor', 'sass', 'images', 'tests', 'watch']);
