setupCss();
// Compatibility shim
navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
// PeerJS object
var stunTurnServerHost = '54.245.236.20';
var peerJsServerHost = '193.187.64.237';
var peerJsServerPort = 9000;
var peerJsServerPath = '';
var peer = new Peer({ host: peerJsServerHost, port: peerJsServerPort, path: peerJsServerPath, debug: 3,
    config: {'iceServers': [
        {url: 'turn:' + stunTurnServerHost + ':3478', credential: 'youhavetoberealistic', username: 'ninefingers'},
        {url: 'stun:' + stunTurnServerHost + ':3478', credential: 'youhavetoberealistic', username: 'ninefingers'}
    ]}
});

var callerId = '';


function setupCss() {
    $('#my-video, #their-video, #step1-error, #step1, #step2, #step3').hide();

    $('#my-video').css({
        'margin-top': '5%',
        'margin-left': '2%',
        'width': '25%',
        'height': 'auto',
        'position': 'absolute',
        'z-index': '1'
    });

    $('#their-video').css({
        'width': '100%',
        'height': 'auto',
        'position': 'relative'
    });

    $('#video-container, #steps, #container').css('position', 'relative');
}


peer.on('open', function () {
    $('#my-id').text(peer.id);
});

// Receiving a call
peer.on('call', function (call) {
    // Answer the call automatically (instead of prompting user) for demo purposes
    call.answer(window.localStream);
    step3(call);
});
peer.on('error', function (err) {
    alert(err.message);
    // Return to step 2 if error occurs
    step2();
});

// Click handlers setup
$(function () {
    $('#make-call').click(function () {
        // Initiate a call!
        var call = peer.call($('#callto-id').val(), window.localStream);
        step3(call);
    });

    $('#end-call').click(function () {
        window.existingCall.close();
        step2();
    });

    // Retry if getUserMedia fails
    $('#step1-retry').click(function () {
        $('#step1-error').hide();
        step1();
    });

    $('#step0-try').click(function () {
        step1();
    });

    getCallerId();

});

function getCallerId() {
    var caller = getUrlVars()["caller-id"];
    if (caller != undefined && caller != null && caller.length > 0) {
        callerId = caller;
        step1();
    }
}

function step1() {
    $('#step0').hide();
    $('#step1').show();
    // Get audio/video stream
    navigator.getUserMedia({audio: true, video: true}, function (stream) {
        // Set your video displays
        $('#my-video').prop('src', URL.createObjectURL(stream));
        window.localStream = stream;
        $('#my-video, #their-video').show();
        if (callerId) {
            step3(peer.call(callerId, window.localStream));
        } else {
            step2();
        }

    }, function () {
        $('#step1-error').show();
    });
}

function step2() {
    $('#step1, #step3').hide();
    $('#step2').show();
}

function step3(call) {
    // Hang up on an existing call if present
    if (window.existingCall) {
        window.existingCall.close();
    }

    // Wait for stream on the call, then set peer video display
    call.on('stream', function (stream) {
        $('#their-video').prop('src', URL.createObjectURL(stream));
    });

    // UI stuff
    window.existingCall = call;
    $('#their-id').text(call.peer);
    call.on('close', step2);
    $('#step1, #step2').hide();
    $('#step3').show();
}

function getUrlVars() {
    var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function (m, key, value) {
        vars[key] = value;
    });
    return vars;
}
