var joinoutServerHost = "http://54.245.236.20/api";
var stunTurnServerHost = "54.245.236.20";
var peerJsServerHost = "54.245.236.20";
var peerJsServerPort = 80;
var peerJsServerPath = '';

var joinoutApp = angular.module('joinoutApp',['ui.bootstrap']);

joinoutApp.factory("stacktraceService",function() {
	return({  print: printStackTrace  });   }
);
        

joinoutApp.provider("$exceptionHandler", {
	$get: function( errorLogService ) {
		return( errorLogService );
	} } );
        
        
joinoutApp.factory("errorLogService", function( $log, $window, stacktraceService ) {
 
	function log( exception, cause ) {
		$log.error.apply( $log, arguments );
	
		console.log(exception);
	
			try {
				var errorMessage = exception.toString();
					if (exception instanceof Error) {
						var stackTrace = stacktraceService.print({ e: exception });
					}
					
              //      console.log('Sending error: ' + errorMessage + ((angular.isDefined(stackTrace))?(' with stack trace: ' + stackTrace):('')));
 
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
				$log.warn( "Error logging failed" );
				$log.log( loggingError );
			}
	}
	return( log );
} );
        

joinoutApp.controller('MainCtrl', function($rootScope, $scope, $filter, $http, $interval, $modal, player, errorLogService) {
  
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
      handleError("Registration error. Please try later.");
      $scope.reportError(data, status, headers, config);
    });
  };
  
  $scope.pendingReadRegisteredUsers = 0;
		
	$scope.readRegisteredUsers = function() {
    if ($scope.pendingReadRegisteredUsers === 0) {
      $scope.pendingReadRegisteredUsers++;
      $http({
        method: 'GET',
        //timeout: 1000,
        url: joinoutServerHost + '/users'
      }).success(function (data, status, headers, config) {
        $scope.users = data;
      }).error(function (data, status, headers, config) {
        $interval.cancel($scope.readingRegisteredUsersInterval)
        $scope.reportError(data, status, headers, config);
        handleError("Get contact list error. Please try later.");
      }).finally(function() {
        $scope.pendingReadRegisteredUsers--;
      });
    }
	};	
	
	$scope.updateLastActivityDate = function() {
		
		$http({method: 'PUT', url: joinoutServerHost+'/users/'+$scope.registered_user_id}).
            success(function(data, status, headers, config) {
            }).
            error(function(data, status, headers, config) {
				$scope.reportError(data, status, headers, config);
              handleError("Activity update error.");
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
			console.log("<< peerServer on open occured");
			$('#my-id').text($scope.peerServer.id);
		});
		
    
    
		// Receiving a call
		$scope.peerServer.on('call', function(call) {
			console.log("<< peerServer on call occured");
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
			console.log("<< peerServer on error occured -> error_type: " + err.type);
			handleError(err.message);
			$scope.hideInCallDiv();
			player.stop();
		});	
		
		
		$scope.peerServer.on('connection', function(){
			console.log("<< peerServer on connection occured");
		});	
		
		
		$scope.peerServer.on('close', function(){
			console.log("<< peerServer on close occured");
		});	
		
		$scope.peerServer.on('disconnect', function(){
			console.log("<< peerServer on disconnect occured");
		});	
	};
		
	$scope.makeACall = function(user) {
    player.setSound(player.sounds.PHONE_CALLING);
    player.play();
		
		// Update last_activity_date
		$scope.updateLastActivityDate();
		
		// Initiate a call!
        var call = $scope.peerServer.call(user.user_id, window.localStream);
        console.log("<< peerServer call occured");
        $scope.handleCall(call);	
	};
		
	$scope.finishACall = function() {
		window.existingCall.close();
        player.stop();
		$scope.info_message="To make a call click on link";
		$scope.hideInCallDiv();	
	};		

	$scope.muteUnmuteAudio = function() {
		if (window.existingCall.localStream.getAudioTracks()[0] !== undefined) {
			if(window.existingCall.localStream.getAudioTracks()[0].enabled){
				window.existingCall.localStream.getAudioTracks()[0].enabled = false;
				$scope.muteUnmuteAudioLabel = "Audio on";
			} else {
				window.existingCall.localStream.getAudioTracks()[0].enabled = true;
				$scope.muteUnmuteAudioLabel = "Audio off";
			}
		}
	};
	
	$scope.muteUnmuteVideo = function() {
		if (window.existingCall.localStream.getVideoTracks()[0] !== undefined) {
			if(window.existingCall.localStream.getVideoTracks()[0].enabled){
				window.existingCall.localStream.getVideoTracks()[0].enabled = false;
				$scope.muteUnmuteVideoLabel = "Video on";
			} else {
				window.existingCall.localStream.getVideoTracks()[0].enabled = true;
				$scope.muteUnmuteVideoLabel = "Video off";
			}
		}
	};
		
	$scope.enableUserMedia = function() {

		// Get audio/video stream
		navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
		navigator.getUserMedia({audio: true, video: true}, function(stream){
        
			// Set your video displays
			$('#my-video').prop('src', URL.createObjectURL(stream));
			window.localStream = stream;
			$('#smileAndHairDiv').show();
				
		}, function(e){ 
			//console.log(e);
			errorLogService(e);
			handleError("EnableUserMedia error."); 
		});
   
	};
		
	$scope.handleCall = function(call) {
	
		// Hang up on an existing call if present
		if (window.existingCall) {
			window.existingCall.close();
		}

		// Wait for stream on the call, then set peer video display
		call.on('stream', function(stream) {
			console.log("<< call on stream occured");
			$('#their-video').prop('src', URL.createObjectURL(stream));
			player.stop();
		});

		call.on('close', function(){
			console.log("<< call on close occured");
			// hide some div
			$scope.info_message="To make a call click on link";
			$('#inCallDiv').hide();
			
			// clean video
			$('#their-video').prop('src', '');
		});
		
		
		call.on('error', function(err) {
			console.log("<< call on error occured -> error_type: " + err.type);
		});
		
		// UI stuff
		$scope.showInCallDiv();
		window.existingCall = call;
		$scope.info_message = "Currently in call with: "+call.peer;
		
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
	
	
	$scope.reportError = function(data, status, headers, config){
		var e = {
			method: config.method,
			url: config.url,
            message: data,
            status: status
        };
		errorLogService(JSON.stringify(e));
	}
		
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
