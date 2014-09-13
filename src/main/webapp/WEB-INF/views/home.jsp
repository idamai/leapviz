<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<!DOCTYPE HTML>
<html>
<head>
  <title>LeapViz</title>
  <style>
    body {
      background-color: #000000
    }
  </style>
  <script src="<c:url value="/resources/js/three.min.js"/>"></script>
  <script src="<c:url value="/resources/js/leap-0.6.2.js"/>"></script>
  <script src="<c:url value="/resources/js/jquery-2.1.1.min.js"/>"></script>
  <script>
    function reset() {
      console.log("resetting map");
      mapLocation = {lat: 40.022482, lon: -75.108077, zoom: 11} // resets to philadelphia
      lookAtPoint = {x: 0, y: 0, z: 0};
      cameraDelta = {d: NORMAL_DIST, elevation: 45 * (Math.PI / 180), heading: 180 * (Math.PI / 180)};
      updateCache();
      updateCamera();
    }
  </script>
</head>
<body>
  <button type="button" onClick="reset()">Reset map</button>
  <div id="coordinates"></div>
  <script>
    var scene = new THREE.Scene();
    var camera = new THREE.PerspectiveCamera(75, window.innerWidth/window.innerHeight, 0.1, 10000);
    var renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);

	Array.matrix = function(numrows, numcols, initial){
		var arr = [];
		for (var i = 0; i < numrows; ++i){
			var columns = [];
			for (var j = 0; j < numcols; ++j){
				columns[j] = initial;
			}
			arr[i] = columns;
		}
		return arr;
	}
 
    var NUM_ROWS = 100.0;
    var TILE_H = 640;
    var TILE_W = 640;
    var MAX_X = TILE_W*0.75;
    var MIN_X = - TILE_W*0.75;
    var MAX_Y = TILE_H*0.75;
    var MIN_Y = - TILE_H*0.75;
    var NORMAL_DIST = 300;
    var MIN_DIST = 200;
	var MAX_DIST = 400;   
	var server = "/leapvisualization";
	var mapLocation = {lat: 40.022482, lon: -75.108077, zoom: 15};
    var API_KEY = "AIzaSyB6PUUj1nfpIUw3gmF2e0s5AaoZe-CFyRA";
    var lookAtPoint = {x: 0, y: 0, z: 0};
    var cameraDelta = {d: NORMAL_DIST, elevation: 45 * (Math.PI / 180), heading: 180 * (Math.PI / 180)};
 
    THREE.ImageUtils.crossOrigin = "anonymous";
    var randomTexture = THREE.ImageUtils.loadTexture('http://maps.googleapis.com/maps/api/staticmap?center=0,0&zoom=12&size=640x640');
    //var img = new THREE.MeshBasicMaterial({map: THREE.ImageUtils.loadTexture});
    //img.map.needsUpdate = true;
    var imgs = [[],[],[],[],[]];
    var planes = [[],[],[]];
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 5; j++) {
        imgs[i][j] = new THREE.MeshBasicMaterial({map: randomTexture});
        imgs[i][j].map.needsUpdate = true;
      }
    }

	// retrieves data points
	function getDataPoints() {
		var curr_bounds = getBounds (mapLocation, TILE_H, TILE_W);
		console.log("x1=" + curr_bounds.rightLon + "&y1=" + curr_bounds.upLat + "&x2=" +
				curr_bounds.leftLon + "&y2=" + curr_bounds.downLat);
		
		var x1 = curr_bounds.rightLon;
		var y1 = curr_bounds.upLat;
		var x2 = curr_bounds.leftLon;
		var y2 = curr_bounds.downLat;
		$.ajax({
			url: server + "/area-count?x1=" + x1 + "&y1=" + y1 + "&x2=" + x2 + "&y2=" + y2 + "&width=" +
			NUM_ROWS + "&height=" + NUM_ROWS,
			beforeSend: function() {
			    console.log("Querying database with x1=" + x1 + "&y1=" + y1 + "&x2=" + x2 + "&y2=" + y2 + "&width=" +
					NUM_ROWS + "&height=" + NUM_ROWS);
			  }
		})
			.done(function(data) {
				console.log("function called");
				console.log(data);
				updateHeatMap(data);
			});
	}
		
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        planes[i][j] = new THREE.Mesh(new THREE.PlaneGeometry(TILE_W, TILE_H), imgs[i+1][j+1]);
        planes[i][j].overdraw = true;
        scene.add(planes[i][j]);
        planes[i][j].position.x = (i-1) * TILE_W;
        planes[i][j].position.y = (j-1) * TILE_H;
      }
    }

    
    var sphereGeom = new THREE.SphereGeometry(3, 3, 2);
    var heatColors = [0xffffb2, 0xfecc5c, 0xfd8d3c, 0xf03b20, 0xbd0026];
    var sphereMat = [];
    var spheres = Array.matrix(NUM_ROWS, NUM_ROWS, null);
    for (var i = 0; i < 5; i++) sphereMat[i] = new THREE.MeshBasicMaterial({color: heatColors[i]});
    for (var i = 0; i < 100; i++) {
      for (var j = 0; j < 100; j++) {
		//TODO: update color
        spheres[i][j] = new THREE.Mesh(sphereGeom, sphereMat[0]);
        spheres[i][j].position.x = (i - 50) * (TILE_H / (NUM_ROWS));
        spheres[i][j].position.y = (j - 50) * (TILE_W / (NUM_ROWS));
        spheres[i][j].position.z = 0;
        scene.add(spheres[i][j]);
      }
    }
    
    function updateHeatMap(dataPoints) {
    	for (var i = 0; i < 100; i++) {
    		for (var j = 0; j < 100; j++) {
    			spheres[i][j].position.z = dataPoints[i][j] * 2;
    			if (dataPoints[i][j] != 0) spheres[i][j].material = sphereMat[4];
    			else {
    				spheres[i][j].position.z = 0;
    				spheres[i][j].material = sphereMat[0];
    			}
    		}
    	}
    }
    
    getDataPoints(); // initial plotting

    function updateCache(dx,dy) {
      if (dx === undefined) dx = 1000;
      if (dy === undefined) dy = 1000;
      var newimgs = [[],[],[],[],[]];
      for (var i = 0; i < 5; i++) {
        for (var j = 0; j < 5; j++) {
          // console.log(i+dx,j+dy);
          if (i+dx < 0 || i+dx >= 5 || j+dy < 0 || j+dy >= 5) {
            if (i == 2 && j == 2) {
              newimgs[i][j] = getMap(mapLocation);
            } else {
              var loc = {lat: 0, lon: 0, zoom: mapLocation.zoom};
              var tx = Math.abs(i-2)*2;
              var ty = Math.abs(j-2)*2;
              var bounds = getBounds(mapLocation, TILE_H*ty, TILE_W*tx);
              loc.lat = (j > 2)?bounds.upLat:bounds.downLat;
              if (j == 2) loc.lat = mapLocation.lat;
              loc.lon = (i > 2)?bounds.rightLon:bounds.leftLon;
              if (i == 2) loc.lon = mapLocation.lon;
              newimgs[i][j] = getMap(loc);
              // console.log(i,j,loc);
            }
          } else {
            newimgs[i][j] = imgs[i+dx][j+dy].map;
          }
        }
      }
      for (var i = 0; i < 5; i++) {
        for (var j = 0; j < 5; j++) {
          imgs[i][j].map = newimgs[i][j];
          imgs[i][j].map.needsUpdate = true;
        }
      }
    }

    function updateMap() {
      var updateData = false;
      if (lookAtPoint.x > MAX_X) {
        lookAtPoint.x -= TILE_W;
        mapLocation.lon = getBounds(mapLocation, TILE_H*2, TILE_W*2).rightLon;
        updateCache(1,0);
        updateData = true;
      }
      if (lookAtPoint.x < MIN_X) {
        lookAtPoint.x += TILE_W;
        mapLocation.lon = getBounds(mapLocation, TILE_H*2, TILE_W*2).leftLon;
        updateCache(-1,0);
        updateData = true;
      }
      if (lookAtPoint.y > MAX_Y) {
        lookAtPoint.y -= TILE_H;
        mapLocation.lat = getBounds(mapLocation, TILE_H*2, TILE_W*2).upLat;
        updateCache(0,1);
        updateData = true;
      }
      if (lookAtPoint.y < MIN_Y) {
        lookAtPoint.y += TILE_H;
        mapLocation.lat = getBounds(mapLocation, TILE_H*2, TILE_W*2).downLat;
        updateCache(0,-1);
        updateData = true;
      }
      if (cameraDelta.d < MIN_DIST) {
        mapLocation.zoom++;
        lookAtPoint.x *= 2;
        lookAtPoint.y *= 2;
        cameraDelta.d *= 2;
        updateCache();
        updateData = true;
      }
      if (cameraDelta.d > MAX_DIST) {
        mapLocation.zoom--;
        lookAtPoint.x /= 2;
        lookAtPoint.y /= 2;
        cameraDelta.d /= 2;
        updateCache();
        updateData = true;
      }
      if (updateData) {
    	  getDataPoints();
      }
    }

    function updateCamera() {
      camera.position.z = lookAtPoint.z + cameraDelta.d * Math.sin(cameraDelta.elevation);;
      camera.position.y = lookAtPoint.y + Math.cos(cameraDelta.heading)*Math.cos(cameraDelta.elevation)*cameraDelta.d;
      camera.position.x = lookAtPoint.x + Math.sin(cameraDelta.heading)*Math.cos(cameraDelta.elevation)*cameraDelta.d;
      camera.up = new THREE.Vector3(0,0,1);
      camera.lookAt(new THREE.Vector3(lookAtPoint.x, lookAtPoint.y, lookAtPoint.z));
    }

    function getBounds(mapLoc, h, w) {
      var lon = mapLoc.lon, lat = mapLoc.lat, zoom = mapLoc.zoom;
      var latRad = lat * Math.PI / 180;
      var mercN = Math.log(Math.tan((Math.PI/4) + (latRad/2)));
      return {
        leftLon: lon - (360 * w) / Math.pow(2, 9+zoom),
        rightLon: lon + (360 * w) / Math.pow(2, 9+zoom),
        downLat: 180 * Math.atan(Math.tan(lat * Math.PI / 180) - h / Math.pow(2, 6+zoom))/Math.PI,
        upLat: 180 * Math.atan(Math.tan(lat * Math.PI / 180) + h / Math.pow(2, 6+zoom))/Math.PI,
      };
    }

    function getMap(mapLoc) {
      var query = 'http://maps.googleapis.com/maps/api/staticmap?center=' + mapLoc.lat + ',' + mapLoc.lon + '&zoom=' + mapLoc.zoom + '&size=640x640&key='+API_KEY;
      // console.log(query);
      return THREE.ImageUtils.loadTexture(query);
    }

    

   //loadMap(mapLocation);
    updateCache();
    updateCamera();

    var ambientLight = new THREE.AmbientLight(0x555555);
    scene.add(ambientLight);

    // speed of frame changing
    var MOVESPEED = 20;
    var SCROLLSPEED = 20;
    var ROTATESPEED = 0.1;
    var ZOOMSPEED = 10;
    var ROTATEFRONTBACKSPEED = 0.005;

    function clamp(mn, val, mx) {
      return Math.min(mx, Math.max(val, mn));
    }
    function panLeft(speed) {
      lookAtPoint.x += speed * Math.cos(cameraDelta.heading);
      lookAtPoint.y -= speed * Math.sin(cameraDelta.heading);
    }
    function panRight(speed) {
      lookAtPoint.x -= speed * Math.cos(cameraDelta.heading);
      lookAtPoint.y += speed * Math.sin(cameraDelta.heading);
    }
    function panForward(speed) {
      lookAtPoint.x -= speed * Math.sin(cameraDelta.heading);
      lookAtPoint.y -= speed * Math.cos(cameraDelta.heading);
    }
    function panBackward(speed) {
      lookAtPoint.x += speed * Math.sin(cameraDelta.heading);
      lookAtPoint.y += speed * Math.cos(cameraDelta.heading);
    }
    function rotateUp(angle) {
      cameraDelta.elevation = clamp(10 * (Math.PI/180), cameraDelta.elevation + angle, 80 * (Math.PI/180));
    }
    function rotateDown(angle) {
      cameraDelta.elevation = clamp(10 * (Math.PI/180), cameraDelta.elevation - angle, 80 * (Math.PI/180));
    }
    function rotateLeft(angle) {
      cameraDelta.heading += 0.1;
    }
    function rotateRight(angle) {
      cameraDelta.heading -= 0.1;
    }
    function zoomIn(speed) {
      cameraDelta.d = clamp(30, cameraDelta.d-speed, 1500);
    }
    function zoomOut(speed) {
      cameraDelta.d = clamp(30, cameraDelta.d+speed, 1500);
    }

    // variables to use in the leap loop
    var previousFrame = null;
    var performedAction = false;
    var info, palm, phalanges = [];

    function initPalm() {
      // console.log("initializing palm");
      // palm
      geometry = new THREE.BoxGeometry( 80, 20, 80 );
      geometry.applyMatrix( new THREE.Matrix4().makeTranslation( 0, 0, -30 ) );  // to to +30 if using pitch roll & yaw
      material = new THREE.MeshNormalMaterial();
      palm = new THREE.Mesh( geometry, material );
      palm.castShadow = true;
      palm.receiveShadow = true;
      scene.add( palm );
    }
    function initPhalanges() {
      // phalanges
      geometry = new THREE.BoxGeometry( 16, 12, 1 );
      for ( var i = 0; i < 15; i++) {
        mesh = new THREE.Mesh( geometry, material );
        mesh.castShadow = true;
        mesh.receiveShadow = true;
        scene.add( mesh );
        phalanges.push( mesh );
      }
    }
    initPalm();
    initPhalanges();

    // TODO: LLH
    function performAction(x, y) {
      alert("selected point at " + x + ", " + y);
    }

    Leap.loop({enableGestures: true}, function(frame) {
      // console.log("inside loop");
      // DRAWING OF HAND TO ACT AS CURSOR
      var hand, phalanx, point, length;
      if ( frame.hands.length ) {
        hand = frame.hands[0];
        palm.position.set( hand.palmPosition[0], hand.palmPosition[1], hand.palmPosition[2] );
        direction = new THREE.Vector3( hand.direction[0], hand.direction[1], hand.direction[2] );  // best so far
        palm.lookAt( direction.add( palm.position ) );
        palm.rotation.z = -hand.roll();
      }
      iLen = ( frame.pointables.length < 5 ) ? frame.pointables.length : 5;
      for (var i = 0; i < iLen; i++) {
        for ( var j = 0; j < 3; j++) {
          phalanx = phalanges[ 3 * i + j];
          if (frame.pointables[i].positions) {
            point = frame.pointables[i].positions[j];
            phalanx.position.set( point[0], point[1], point[2] );
            point = frame.pointables[i].positions[ j + 1 ];
            point = new THREE.Vector3( point[0], point[1], point[2] );
            phalanx.lookAt( point );
            length = phalanx.position.distanceTo( point );
            phalanx.translateZ( 0.5 * length );
            phalanx.scale.set( 1, 1, length );
          }
        }
      }

      // MAIN GESTURE RECOGNITION
      if (previousFrame && previousFrame.valid) {
        var translation = frame.translation(previousFrame);
        var rotationAxis = frame.rotationAxis(previousFrame);
        var rotationAngle = frame.rotationAngle(previousFrame);

        if (frame.hands.length == 1) { // detect one hand
          // actions allowed: rotation, tilt and selection
          var hand = frame.hands[0];
          if (hand) {
            var pitch = hand.pitch();
            var yaw = hand.yaw();
            var roll = hand.roll();  

            // output hand position
            var handPosition = hand.palmPosition;
            var posString = "(" + handPosition[0] + ", " + handPosition[1] + ", " + handPosition[2] + ")" 
            var handOutput = document.getElementById("coordinates");
            handOutput.innerHTML = posString;
          }
          if (frame.pointables.length > 0) { // check for how many fingers are extended
            var countFingersExtended = 0;
            for (var i = 0; i < frame.pointables.length; i++) {
              var pointable = frame.pointables[i];
              if (pointable.extended && !pointable.tool) {
                countFingersExtended++;
              }
            }
            // console.log("number of fingers extended: " + countFingersExtended);
          }
          // perform rotate up and down if it detects circles
          if (frame.gestures.length > 0) {
            var gestureString = "";
            for (var i = 0; i < frame.gestures.length; i++) {
              var gesture = frame.gestures[i];
              if (gesture.type == "circle") {
                var clockwise = false;
                var pointableID = gesture.pointableIds[0];
                var direction = frame.pointable(pointableID).direction;
                var dotProduct = Leap.vec3.dot(direction, gesture.normal);
                if (dotProduct  >  0) clockwise = true;
                if (clockwise) {
                  rotateUp(ROTATEFRONTBACKSPEED);
                } else {
                  rotateDown(ROTATEFRONTBACKSPEED);
                }
              } else if (gesture.type == "screenTap") { // check for screen tap
                // var duration = gesture.duration; 
                // console.log("performing selection");
                // get coordinates of location selected
                var currMapBounds = getBounds(mapLocation, TILE_H, TILE_W);
                var distLon = currMapBounds.rightLon - currMapBounds.leftLon;
                var distLat = (currMapBounds.upLat - currMapBounds.downLat) / 2.0;
                if (hand) {
                  var handPosition = hand.palmPosition;
                  // TODO JEVON: change the hand bounds to not be half of the map only
                  var DIFF = 400.0;
                  var LOWER_X_BOUND = -200;
                  var LOWER_Y_BOUND = 0; 
                  var selectedLon = (((handPosition[0] - LOWER_Y_BOUND) / DIFF) * distLon) + currMapBounds.leftLon;
                  var selectedLat = (((handPosition[1] - LOWER_X_BOUND) / DIFF) * distLat) + currMapBounds.downLat;
                  performAction(selectedLat, selectedLon);
                }
              } else {
                // console.log("unknown gesture type");
              }
            }
          } else if (countFingersExtended > 1) {
            if (roll > 0.5) { // tilt left
              panLeft(SCROLLSPEED);
              // console.log("shifting left");
            } else if (roll < -0.5) { // tilt right
              panRight(SCROLLSPEED);
              //console.log("shifting right");
            } else if (pitch > 0.5) { // tilt back
              panBackward(SCROLLSPEED);
              //console.log("tilting backward");
            } else if (pitch < -0.5) { // tilt forward
              panForward(SCROLLSPEED);
              //console.log("tilting forward");
            } else if (yaw < -0.5) { // rotating counterclockwise
              rotateLeft(ROTATESPEED);
            } else if (yaw > 0.5) { // rotating clockwise
              rotateRight(ROTATESPEED);
            }
          }
        } else if (frame.hands.length == 2) {
          // perform zooming in and out if two hands detected
          for (var i = 0; i < frame.hands.length; i++) {
            var hand = frame.hands[i];
            if (previousFrame && previousFrame.valid) {
              var translation = hand.translation(previousFrame);
              if ((hand.type == "right" && translation[0] > 0.5) || (hand.type == "left" && translation[0] < -0.5)) {
                // zooming out
                zoomOut(ZOOMSPEED);
                //console.log("zooming out");
              } else if ((hand.type == "right" && translation[0] < -0.5) || (hand.type == "left" && translation[0] > 0.5)) {
                // zoom in
                zoomIn(ZOOMSPEED);
                //console.log("zooming in");
              }
            }  
          }
        }
      }
      
      // Store frame for motion functions
      previousFrame = frame;
      updateMap();
      updateCamera();
    });

    $(document).keydown(function(e) {
      if (e.keyCode == 37) { // left
        panLeft(MOVESPEED);
      } else if (e.keyCode == 38) { // up
        panForward(MOVESPEED);
      } else if (e.keyCode == 39) { // right
        panRight(MOVESPEED);
      } else if (e.keyCode == 40) { // down
        panBackward(MOVESPEED);
      } else if (e.keyCode == 87) { // W
        rotateUp(0.1);
      } else if (e.keyCode == 83) { // S
        rotateDown(0.1);
      } else if (e.keyCode == 65) { // A
        rotateLeft(0.1);
        //cameraDelta.angle += 0.1;
      } else if (e.keyCode == 68) { // D
        rotateRight(0.1);
        //cameraDelta.angle -= 0.1;
      } else if (e.keyCode == 81) { // Q
        zoomIn(MOVESPEED);
      } else if (e.keyCode == 69) { // E
        zoomOut(MOVESPEED);
      } else if (e.keyCode == 70) { // F
        var bounds = getBounds(mapLocation,TILE_H,TILE_W);
        mapLocation.lon = bounds.rightLon;
        loadMap(mapLocation);
      } else if (e.keyCode == 76) { // L
        performAction(40.022482, -75.108077); // hardcoded coords for testing
      } else {
        return;
      }
      updateMap();
      updateCamera();
      e.preventDefault();
    });

    var render = function() {
      requestAnimationFrame(render);
       
      //plane.rotation.z += 0.01;

      renderer.render(scene, camera);
    };
    render();
  </script>
</body>
</html>
