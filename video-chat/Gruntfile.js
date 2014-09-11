module.exports = function(grunt) {

  grunt.initConfig({

    pkg : grunt.file.readJSON('package.json'),

    bower_concat: {
	all: {
	dest: 'dist/video-chat-bower.js'
	}
    },
    concat: {
      options: {
        banner: ''
      },
      target : {
        src : ['dist/video-chat-bower.js', 'src/lib/peer.min.js', 'src/peer-video-chat.js'],
        dest : 'dist/video-chat.js'
      }
    },
    uglify: {
          my_target: {
              files: {
                  'dist/video-chat.min.js': 'dist/video-chat.js'
              }
          }
    }
  });

  grunt.loadNpmTasks('grunt-bower-concat');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask('default', ['bower_concat', 'concat', 'uglify']);

};