var joinoutServerHost = "http://54.245.236.20/api";
//var joinoutServerHost = "http://54.245.236.20:8080";
var stunTurnServerHost = "54.245.236.20";
var peerJsServerHost = "54.245.236.20";
var peerJsServerPort = 80;
//var peerJsServerPort = 9000;
//var peerJsServerPath = 'peerjs';
var peerJsServerPath = '';

var joinoutApp = angular.module('joinoutApp',['ui.bootstrap']);

// przydatne zmienne
// $scope.registered_user_id 
// $scope.peerServer


joinoutApp.factory("stacktraceService",function() {
	return({  print: printStackTrace  });   }
);
        
joinoutApp.provider(
            "$exceptionHandler",
            {
                $get: function( errorLogService ) {
 
                    return( errorLogService );
 
                }
            }
        );
        
        
         joinoutApp.factory(
            "errorLogService",
            function( $log, $window, stacktraceService ) {
 
                // I log the given error to the remote server.
                function log( exception, cause ) {
 
                    // Pass off the error to the default error handler
                    // on the AngualrJS logger. This will output the
                    // error to the console (and let the application
                    // keep running normally for the user).
                    $log.error.apply( $log, arguments );
 
                    // Now, we need to try and log the error the server.
                    // --
                    // NOTE: In production, I have some debouncing
                    // logic here to prevent the same client from
                    // logging the same error over and over again! All
                    // that would do is add noise to the log.
                    try {
 
                        var errorMessage = exception.toString();
                        if (exception instanceof Error) {
                          var stackTrace = stacktraceService.print({ e: exception });
                        }
                        console.log('Sending error: ' + errorMessage + ((angular.isDefined(stackTrace))?(' with stack trace: ' + stackTrace):('')));
 
                        // Log the JavaScript error to the server.
                        // --
                        // NOTE: In this demo, the POST URL doesn't
                        // exists and will simply return a 404.
           //             $.ajax({
           //                 type: "POST",
           //                 url: "./javascript-errors",
           //                 contentType: "application/json",
           //                 data: angular.toJson({
           //                     errorUrl: $window.location.href,
           //                     errorMessage: errorMessage,
           //                     stackTrace: stackTrace,
           //                     cause: ( cause || "" )
           //                 })
           //             });
 
                    } catch ( loggingError ) {
 
                        // For Developers - log the log-failure.
                        $log.warn( "Error logging failed" );
                        $log.log( loggingError );
 
                    }
 
                }
 
 
                // Return the logging function.
                return( log );
 
            }
        );
        
        
        //////////////////////////
        

joinoutApp.controller('MainCtrl', function($rootScope, $scope, $filter, $http, $interval, $modal, player, errorLogService) {
  console.log(errorLogService);
  
  $scope.causeError = function() {
                    var x = y;
                };
  
  
  
  var peerServer;
  $scope.info_message = "To make a call you have to register first !!!";
  
  $scope.muteUnmuteAudioLabel = "Audio off";
  $scope.muteUnmuteVideoLabel = "Video off";

  $scope.registerNewUser = function() {
	$rootScope.$broadcast('loader_show');
		
		var generated_double_id = Math.random();
		var generated_string_id = generated_double_id.toString().replace(".", "");
		
		var positionInJson = angular.toJson({
			user_name: $scope.userName,
			user_id: generated_string_id
		});

    $http({
      method: 'POST',
      url: joinoutServerHost + '/users',
      data: JSON.stringify(positionInJson)
    }).success(function(data, status, headers, config) {
      $scope.registered_user_name = data.user_name;
      $scope.registered_user_id = data.user_id;
      $scope.readRegisteredUsers();
      $scope.createPeerServerConnection();
      $scope.enableUserMedia();
      $rootScope.$broadcast('loader_hide');
      $scope.info_message = "To make a call click on link";
    }).error(function(data, status, headers, config) {
      $rootScope.$broadcast('loader_hide');
      handleError("error code 01");
    });
  };
  
  $scope.pendingReadRegisteredUsers = 0;
		
	$scope.readRegisteredUsers = function() {
    if ($scope.pendingReadRegisteredUsers === 0) {
      $scope.pendingReadRegisteredUsers++;
      $http({
        method: 'GET',
        url: joinoutServerHost + '/users',
        timeout: 1000
      }).success(function (data, status, headers, config) {
        $scope.users = data;
      }).error(function (data, status, headers, config) {
        $interval.cancel($scope.readingRegisteredUsersInterval)
        
        console.log(config);
        console.log(status);
        errorLogService(config);
        errorLogService(status);
        
        
        handleError("error code ERR_CONNECTION_TIMED_OUT");
      }).finally(function() {
        $scope.pendingReadRegisteredUsers--;
      });
    }
	};	
	
	$scope.updateLastActivityDate = function() {
		
		$http({method: 'PUT', url: joinoutServerHost+'/users/'+$scope.registered_user_id}).
            success(function(data, status, headers, config) {
              console.log('updateLastActivityDate success');
            }).
            error(function(data, status, headers, config) {
              handleError("error code ERR_CONNECTION_TIMED_OUT");
            });
	};
		
	$scope.createPeerServerConnection = function() {
				
		// PeerJS object
		$scope.peerServer = new Peer($scope.registered_user_id , {host: peerJsServerHost, port: peerJsServerPort, path: peerJsServerPath, debug:3, 
			config: {'iceServers': [
			 {	url: 'turn:'+stunTurnServerHost+':3478',		credential: 'youhavetoberealistic',		username: 'ninefingers'		},
			 {	url: 'stun:'+stunTurnServerHost+':3478',		credential: 'youhavetoberealistic',		username: 'ninefingers'		}
			]}
		});
		
		$scope.peerServer.on('open', function(){
		  $('#my-id').text($scope.peerServer.id);
		});
		
    // Receiving a call
		$scope.peerServer.on('call', function(call) {
      
      player.setSound(player.sounds.PHONE_RINGING);
      player.play();
      var incomingCallDialogInstance = $modal.open({
        templateUrl: 'incomingCallDialog.html',
        controller: 'IncomingCallDialogCtrl',
        resolve: {
          caller: function () {
            return 'UNKNOWN';
          }
        }
      });
      incomingCallDialogInstance.result.then(function (result) {
		  
		  // Update last_activity_date
		$scope.updateLastActivityDate();
		  
        if (result.accepted) {
          call.answer(window.localStream);
          $scope.handleCall(call);	
        } else {
          console.log('You have rejected the call!');
        }
        player.stop();
      });
    });
    
		$scope.peerServer.on('error', function(err){
			
			handleError(err.message);
			$scope.hideInCallDiv();
      player.stop();
		});		
		
	};
		
	$scope.makeACall = function(user) {
    player.setSound(player.sounds.PHONE_CALLING);
    player.play();
		
		// Update last_activity_date
		$scope.updateLastActivityDate();
		
		// Initiate a call!
        var call = $scope.peerServer.call(user.user_id, window.localStream);
        $scope.handleCall(call);	
	};
		
	$scope.finishACall = function() {
		window.existingCall.close();
                player.stop();
		$scope.info_message="To make a call click on link";
		$scope.hideInCallDiv();	
	};		

	$scope.muteUnmuteAudio = function() {
		if(window.existingCall.localStream.getAudioTracks()[0].enabled){
			window.existingCall.localStream.getAudioTracks()[0].enabled = false;
			$scope.muteUnmuteAudioLabel = "Audio on";
		} else {
			window.existingCall.localStream.getAudioTracks()[0].enabled = true;
			$scope.muteUnmuteAudioLabel = "Audio off";
		}
	};
	
	$scope.muteUnmuteVideo = function() {
		if(window.existingCall.localStream.getVideoTracks()[0].enabled){
			window.existingCall.localStream.getVideoTracks()[0].enabled = false;
			$scope.muteUnmuteVideoLabel = "Video on";
		} else {
			window.existingCall.localStream.getVideoTracks()[0].enabled = true;
			$scope.muteUnmuteVideoLabel = "Video off";
		}
		
	};
		
	$scope.enableUserMedia = function() {

		// Get audio/video stream
		navigator.getUserMedia({audio: true, video: true}, function(stream){
        
			// Set your video displays
			$('#my-video').prop('src', URL.createObjectURL(stream));
			window.localStream = stream;
			$('#smileAndHairDiv').show();
				
		}, function(){ handleError("error code 08"); });
   
	};
		
	$scope.handleCall = function(call) {
	
		// Hang up on an existing call if present
		if (window.existingCall) {
			window.existingCall.close();
		}

		// Wait for stream on the call, then set peer video display
		call.on('stream', function(stream) {
			$('#their-video').prop('src', URL.createObjectURL(stream));
			player.stop();
		});


		// Wait for stream on the call, then set peer video display
		call.on('disconnect', function(id) {
			alert("disconnected");
		});
		

		// UI stuff
		$scope.showInCallDiv();
		window.existingCall = call;
		
		 $scope.info_message = "Currently in call with: "+call.peer;
      
		call.on('close', function(){
			
			// hide some div
			$scope.info_message="To make a call click on link 2";
			$('#inCallDiv').hide();
			
			// clean video
			$('#their-video').prop('src', '');
		});
		
		
		
//    call.on('close', function () {
//      if ($('#their-video').prop('src') == URL.createObjectURL(stream)) {
//        player.stop();
//        handleMessage('Your call has been rejected!', 'Rejected call');
//      }
//      $scope.hideInCallDiv();
//    });
	};
		
	$scope.withoutMeFilter = function(user) {
		return !($scope.registered_user_id == user.user_id);
	};
	
	$scope.hideInCallDiv = function() {		
		$('#inCallDiv').hide();
		
	};
		
	$scope.showInCallDiv = function() {		
		$('#inCallDiv').show();
		$('#inCallDiv2').show();
	};	
		
	// poll server every 10 sec  (expressed in miliseconds)
	$scope.readRegisteredUsers();
  $scope.readingRegisteredUsersInterval = $interval($scope.readRegisteredUsers, 10000);
  $scope.$on('$destroy', function() {
    $interval.cancel($scope.readingRegisteredUsersInterval);
  });
  
	// by default ukrywany niektore elementy
	$scope.hideInCallDiv();
  
  function handleError(message) {
	$scope.info_message="To make a call click on link";
    handleMessage(message, 'Sorry, error occurred!');
  }
  
  function handleMessage(message, title) {
    var errorModalInstance = $modal.open({
      templateUrl: 'messageDialog.html',
      controller: 'MessageDialogCtrl',
      resolve: {
        title: function () {
          return title;
        },
        message: function () {
          return message;
        }
      }
    });
  }
});


joinoutApp.controller('MessageDialogCtrl', function($scope, $modalInstance, title, message) {
  $scope.title = title;
  $scope.message = message;
  $scope.ok = function () {
    $modalInstance.close();
  }
});

joinoutApp.controller('IncomingCallDialogCtrl', function($scope, $modalInstance, caller) {
  $scope.caller = caller;
  $scope.accept = function () {
    $modalInstance.close({accepted: true});
  };
  $scope.reject = function () {
    $modalInstance.close({accepted: false});
  };
});

joinoutApp.factory('player', function(audio, $rootScope) {
  var player;
  var paused = false;
  audio.loop = true;
  player = {
    sounds: {
      PHONE_CALLING: {
        url: 'audio/phone-calling.mp3'
      }, PHONE_RINGING: {
        url: 'audio/phone-ringing.mp3'
      }
    },
    media: {
      url: null
    },
    playing: false,
    play: function(track, album) {
      if (!paused && this.media.url) audio.src = this.media.url;
      audio.play();
      player.playing = true;
      paused = false;
    },
    pause: function() {
      if (player.playing) {
        audio.pause();
        player.playing = false;
        paused = true;
      }
    },
    stop: function() {
      if (player.playing) {
        audio.pause();
        audio.load();
        player.playing = false;
        paused = false;
      }
    },
    setSound: function(sound) {
      this.media.url = sound.url;
    }
  };
  
  audio.addEventListener('ended', function() {
    $rootScope.$apply(player.next);
  }, false);

  return player;
});

joinoutApp.factory('audio', function($document) {
  var audio = $document[0].createElement('audio');
  return audio;
});
