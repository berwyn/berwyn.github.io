module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    sass:
      dist:
        options:
          outputStyle: 'compressed'
          imagePath: '/images'
        files:
          'static/css/dashie.css': 'static/css/dashie.scss'
      dev:
        options:
          imagePath: '/images'
          sourceComments: 'map'
        files:
          'static/css/dashie.css': 'dashie/css/dashie.scss'
    watch:
      dev:
        files: ['static/css/**.scss']
        tasks: ['sass:dev']
        options:
          interrupt: true

  grunt.registerTask 'dev', ['sass:dev']
  grunt.registerTask 'prod', ['sass:dist']