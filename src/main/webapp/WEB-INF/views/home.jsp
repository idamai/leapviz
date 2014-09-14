<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page session="false"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>LeapVis - PennApps Fall 2014</title>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Data visualization for Leap Motion">
<meta name="author" content="JY, ID, ZX, LH">

<script src="<c:url value="/resources/js/three.min.js"/>"></script>
<script src="<c:url value="/resources/js/leap-0.6.2.js"/>"></script>
<script
	src="http://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
<link
	href="http://getbootstrap.com/examples/justified-nav/justified-nav.css"
	rel="stylesheet">
<link href='http://fonts.googleapis.com/css?family=Source+Sans+Pro:300'
	rel='stylesheet' type='text/css'>
<link rel="icon"
	href="<c:url value="/resources/img/leapvis-favicon.png"/>">

<style>
body {
	font-family: 'Source Sans Pro', sans-serif;
	background-image: url("<c:url value="/ resources/ img/ use_your_illusion.png "/>");
}
</style>
<script>
    function reset() {
      console.log("resetting map");
      mapLocation = {lat: 39.9516054, lon: -75.193764, zoom: 15}; // resets to philadelphia
      // resets camera angles
      lookAtPoint = {x: 0, y: 0, z: 0};
      cameraDelta = {d: NORMAL_DIST, elevation: 45 * (Math.PI / 180), heading: 180 * (Math.PI / 180)};
      // resets canvas size
      $("canvas").animate({
        width: (window.innerWidth - horizontalBuffer)*9/10,
        height: (window.innerHeight - verticalBuffer)*9/10
      }, 1000); 
      document.getElementById("infoPanel").innerHTML = "<br><br>";
      updateCache();
      updateCamera();
    }

    function pauseForGestures() {
      if (document.getElementById("pauseOnGesture").checked) {
        paused = true;
      } else {
        paused = false;
      }
    }
  </script>
</head>
<body>
	<div class="container">
		<table>
			<tr>
				<td><img
					src="<c:url value="/resources/img/leapvis-transparent.png"/>"
					width="200px" height="55px"></td>
				<td>
					<ul class="nav nav-justified" style="opacity: 0.8">
						<li><a href="about.html">About</a></li>
						<li><a href="#">Instructions</a></li>
					</ul>
				</td>
			</tr>
		</table>
	</div>
	<br>

	<div id="mapContainer" align="center">
		<div id="map"></div>
		<br>
		<div id="infoPanel" style="color: white">
			<br>
			<br>
		</div>
		<br>
		<div>
			<label style="color: white">Latitude</label> <input type="text"
				id="lat-in" name="lat"> <label style="color: white">
				Longitude</label> <input type="text" id="lng-in" name="lon"> <label
				style="color: white">Remarks</label> <input type="text" id="type"
				name="remarks">
			<button id="submitNewReport" style="color: black" type="button">Submit
				Report</button>
		</div>
		<div style="color: white">
			<input type="checkbox" id="pauseOnGesture"
				onclick="pauseForGestures()"> Pause gesture recognition</input>
		</div>
	</div>

	<script>
  	
    var paused = false;
    var verticalBuffer = 150;
    var horizontalBuffer = 200;
    var requestId;

    var scene = new THREE.Scene();
    var camera = new THREE.PerspectiveCamera(75, window.innerWidth/window.innerHeight, 0.1, 10000);
    var renderer = new THREE.WebGLRenderer();
    renderer.setSize((window.innerWidth - horizontalBuffer)*9/10, (window.innerHeight - verticalBuffer)*9/10);
    // document.body.appendChild(renderer.domElement);
    document.getElementById("map").appendChild(renderer.domElement);

    var render = function() {
        requestId = requestAnimationFrame(render);
        renderer.render(scene, camera);
      };
      
      
      function start(){
      	if (!requestId){
      		render();
      	}
      }
      
      function stop(){
      	if (requestId){
      		cancelAnimationFrame(render);
      		requestId =undefined;
      	}
      }
      
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
 
    var NUM_ROWS = 30.0;
    var TILE_H = 640;
    var TILE_W = 640;
    var MAX_X = TILE_W*0.75;
    var MIN_X = - TILE_W*0.75;
    var MAX_Y = TILE_H*0.75;
    var MIN_Y = - TILE_H*0.75;
    var NORMAL_DIST = 400;
    var MIN_DIST = 300;
    var MAX_DIST = 600;   
    var server = "/leapvisualization/";
    var mapLocation = {lat: 39.9516054, lon: -75.193764, zoom: 15};
    var API_KEY = "AIzaSyB6PUUj1nfpIUw3gmF2e0s5AaoZe-CFyRA";
    var lookAtPoint = {x: 0, y: 0, z: 0};
    var cameraDelta = {d: NORMAL_DIST, elevation: 45 * (Math.PI / 180), heading: 180 * (Math.PI / 180)};
    
    /* Submit remarks */
  	$("#submitNewReport").on("click",function(){
  		var lat = $("#lat-in").val();
  		var lng = $("#lng-in").val();
  		var type = $("#type").val();
  		$.ajax({
  			url:server+"add?x="+lat+"&y="+lng+"&type="+type
  		}).done(function(status) {
			console.log(status);
  		});
  		
  	});
   

    console.log("variables initialized");

    // function to populate heat map
    function getDataPoints(x1, x2, y1, y2) {
      var rowSize = (y2 - y1) / NUM_ROWS;
      var colSize = (x2 - x1) / NUM_ROWS;
      var dataPoints = Array.matrix(numRows, numRows, 0);
      var x;
      var y;
      var arr = JSON;
      for (var i = 0; i < JSON.length; i++) {
        x = Math.floor(JSON[i].POINT_X / colSize);
        y = Math.floor(JSON[i].POINT_Y / rowSize);
        dataPoints[x][y]++;
      }
    }

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
    for (var i = 0; i < 5; i++) sphereMat[i] = new THREE.MeshLambertMaterial({color: 0xffffff, ambient: heatColors[i], transparent: true, opacity: 0.3});

 // retrieves data points
    function getDataPoints() {
    	var curr_bounds = getBounds (mapLocation, 3 * TILE_H, 3 * TILE_W);
    	console.log("x1=" + curr_bounds.rightLon + "&y1=" + curr_bounds.upLat + "&x2=" +
    			curr_bounds.leftLon + "&y2=" + curr_bounds.downLat);
    	
    	var x1 = curr_bounds.rightLon;
    	var y1 = curr_bounds.upLat;
    	var x2 = curr_bounds.leftLon;
    	var y2 = curr_bounds.downLat;
    	$.ajax({
    		async: false,
    		url: server + "/area-count?x1=" + x1 + "&y1=" + y1 + "&x2=" + x2 + "&y2=" + y2 + "&width=" +
    		NUM_ROWS + "&height=" + NUM_ROWS,
    		beforeSend: function() {
    		    console.log("Querying database with x1=" + x1 + "&y1=" + y1 + "&x2=" + x2 + "&y2=" + y2 + "&width=" +
    				NUM_ROWS + "&height=" + NUM_ROWS);
    		    
    		  }
   		})
    		.done(function(data_new) {

    		    //stop();
    			console.log("function called");
    			data = data_new;
    			console.log(data);
				drawDataPoints();
				//render();
				//start();
		});
   	}
 
 

    //Draw data points
    var data = [];
    var doDraw = false;
    for (var i = 0; i < NUM_ROWS; i++) {
      data.push([]);
      for (var j = 0; j < NUM_ROWS; j++) {
        var x = i - NUM_ROWS/2;
        var y = j - NUM_ROWS/2;
        data[i][j] = 5;
      }
    }
    var rects = [];
    for (var i = 0; i < NUM_ROWS; i++) {
      rects.push([]);
      for (var j = 0; j < NUM_ROWS; j++) {
        data[i].push(0);
        rects[i][j] = new THREE.Mesh(new THREE.BoxGeometry(3*TILE_W/NUM_ROWS, 3*TILE_H/NUM_ROWS,1),sphereMat[0]);
        rects[i][j].position.x = (i - NUM_ROWS/2 + 0.5) * (3*TILE_W/NUM_ROWS);
        rects[i][j].position.y = (j - NUM_ROWS/2 + 0.5) * (3*TILE_H/NUM_ROWS);
        rects[i][j].position.z = 0;
        scene.add(rects[i][j]);
      }
    }

    function interpolate(c1, c2, lambda) {
      var r = (1-lambda)*(c1>>16) + lambda*(c2>>16);
      var g = (1-lambda)*((c1&0xffff)>>8) + lambda*((c2&0xffff)>>8);
      var b = (1-lambda)*(c1&0xff) + lambda*(c2&0xff);
      return (Math.floor(r) << 16) + (Math.floor(g) << 8) + Math.floor(b);
    }
    
    function drawDataPoints() {
      for (var i = 0; i < NUM_ROWS; i++) {
        for (var j = 0; j < NUM_ROWS; j++) {
          //console.log(i,j,data[i][j]);
          //rects[i][j].geometry = new THREE.BoxGeometry(3*TILE_W/NUM_ROWS, 3*TILE_H/NUM_ROWS,data[i][j]);
          if (mapLocation.zoom < 15) rects[i][j].scale.z = (data[i][j]+0.01)/Math.pow(3,15-mapLocation.zoom);
          else rects[i][j].scale.z = (data[i][j]+0.01);
          rects[i][j].position.z = rects[i][j].scale.z/2 + 0.5;
          var lambda = Math.min(data[i][j]/200, 0.99);
          var col = interpolate(0xffff00, 0xff0000, lambda);
          rects[i][j].material = new THREE.MeshLambertMaterial({color: col, transparent: true, opacity: 0.5});
        }
      }
    }
    //getDataPoints();
    //drawDataPoints();

    var selectRect = new THREE.Mesh(new THREE.BoxGeometry(1,1,1),new THREE.MeshBasicMaterial({color:0xffffff}));
    function setSelectRect(sx, sy) {
      scene.remove(selectRect);
	  if (!rects[sx]) return;
      var srect = rects[sx][sy];
	  if (!srect) return;
      selectRect = new THREE.Mesh(
        srect.geometry,
        new THREE.MeshBasicMaterial({color: 0x0000ff, wireframe: true})
      );
      selectRect.position.set(srect.position.x, srect.position.y, srect.position.z);
      scene.add(selectRect);
    }

    function growRects() {
      var t = 0;
      function animate () {
        for (var i = 0; i < NUM_ROWS; i++) {
          for (var j = 0; j < NUM_ROWS; j++) {
            rects[i][j].position.z += 15;
            rects[i][j].position.z = Math.min(data[i][j]/2 + 0.5,rects[i][j].position.z);
          }
        }
        t++;
        if (t < 40) setTimeout(animate,10);
      }
      animate();
    }
    function shrinkRects() {
      var t = 0;
      function animate () {
        for (var i = 0; i < NUM_ROWS; i++) {
          for (var j = 0; j < NUM_ROWS; j++) {
            rects[i][j].position.z -= 15;
            rects[i][j].position.z = Math.max(-data[i][j]/2 + 1,rects[i][j].position.z);
          }
        }
        t++;
        if (t < 40) setTimeout(animate,10);
      }
      animate();
    }

    function updateCache(dx,dy) {
      if (dx === undefined) dx = 1000;
      if (dy === undefined) dy = 1000;
      var newimgs = [[],[],[],[],[]];
      for (var i = 0; i < 5; i++) {
        for (var j = 0; j < 5; j++) {
          //console.log(i+dx,j+dy);
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
              //console.log(i,j,loc);
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

    var toUpdate = false;
    
    function updateMap() {
      if (lookAtPoint.x > MAX_X) {
        lookAtPoint.x -= TILE_W;
        mapLocation.lon = getBounds(mapLocation, TILE_H*2, TILE_W*2).rightLon;
        updateCache(1,0);
        toUpdate = true;
      }
      if (lookAtPoint.x < MIN_X) {
        lookAtPoint.x += TILE_W;
        mapLocation.lon = getBounds(mapLocation, TILE_H*2, TILE_W*2).leftLon;
        updateCache(-1,0);
        toUpdate = true;
      }
      if (lookAtPoint.y > MAX_Y) {
        lookAtPoint.y -= TILE_H;
        mapLocation.lat = getBounds(mapLocation, TILE_H*2, TILE_W*2).upLat;
        updateCache(0,1);
        toUpdate = true;
      }
      if (lookAtPoint.y < MIN_Y) {
        lookAtPoint.y += TILE_H;
        mapLocation.lat = getBounds(mapLocation, TILE_H*2, TILE_W*2).downLat;
        updateCache(0,-1);
        toUpdate = true;
      }
      if (cameraDelta.d < MIN_DIST) {
        mapLocation.zoom++;
        lookAtPoint.x *= 2;
        lookAtPoint.y *= 2;
        cameraDelta.d *= 2;
        updateCache();
        toUpdate = true;
      }
      if (cameraDelta.d > MAX_DIST) {
        mapLocation.zoom--;
        lookAtPoint.x /= 2;
        lookAtPoint.y /= 2;
        cameraDelta.d /= 2;
        updateCache();
        toUpdate = true;
      }
      if (toUpdate) {
    	  getDataPoints();
    	  toUpdate = false;
      }
    }

    function updateCamera() {
      camera.position.z = lookAtPoint.z + cameraDelta.d * Math.sin(cameraDelta.elevation);;
      camera.position.y = lookAtPoint.y + Math.cos(cameraDelta.heading)*Math.cos(cameraDelta.elevation)*cameraDelta.d;
      camera.position.x = lookAtPoint.x + Math.sin(cameraDelta.heading)*Math.cos(cameraDelta.elevation)*cameraDelta.d;
      camera.up = new THREE.Vector3(0,0,1);
      camera.lookAt(new THREE.Vector3(lookAtPoint.x, lookAtPoint.y, lookAtPoint.z));
      pointLight.position.set(camera.position.x, camera.position.y, 500);
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
      //console.log(query);
      return THREE.ImageUtils.loadTexture(query);
    }    

    var ambientLight = new THREE.AmbientLight(0x333333);
    scene.add(ambientLight);
    var pointLight = new THREE.PointLight(0xffffff);
    pointLight.position.set(200,200,500);
    scene.add(pointLight);

    updateCache();
    updateCamera();

    // speed of frame changing
    var MOVESPEED = 10;
    var SCROLLSPEED = 10;
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
      cameraDelta.elevation = clamp(10 * (Math.PI/180), cameraDelta.elevation + angle, 88 * (Math.PI/180));
    }
    function rotateDown(angle) {
      cameraDelta.elevation = clamp(10 * (Math.PI/180), cameraDelta.elevation - angle, 88 * (Math.PI/180));
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
    var selectX = NUM_ROWS / 2;
    var selectY = NUM_ROWS / 2;

    function convertXYToCoords(x, y) {
    	var bounds = getBounds(mapLocation, TILE_H*3, TILE_W*3);
    	var diffLat = bounds.upLat - bounds.downLat;
    	var diffLon = bounds.rightLon - bounds.leftLon;
    	var selectedLat = y/NUM_ROWS * diffLat + bounds.downLat;
    	var selectedLon = x/NUM_ROWS * diffLon + bounds.leftLon;
    	return {
    		"lat": selectedLat,
    		"lon": selectedLon
    	}
    }
    
    function performAction(x, y) {
      var coords = convertXYToCoords(x, y);
      $.ajax({
    	  url: server+"nearst?x="+coords.lon+"&y="+coords.lat
      }).done(function(result){
    	  if (result!=null){
	    	  var dataOutput = document.getElementById("infoPanel");
	          var dataString = "";
	          dataString += "Number of crimes: " + data[x][y] + "<br>";
	          dataString += "The most common crime is "+result.textGeneralCode+" at "+result.hour+" hours.";
	          dataOutput.innerHTML = dataString;
    	  }
      });
     
      
    }

    // TODO: query database
    function getDataForCoordinate(x, y) {
      return {
        "lat": x,
        "lon": y,
        "count": 5,
        "remarks": "The most frequent type of crime here is robbery that occurs between a 12-2am."
      }
    }

    Leap.loop({enableGestures: true}, function(frame) {
      if (paused) {
        return;
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
          }
          if (frame.pointables.length > 0) { // check for how many fingers are extended
            var countFingersExtended = 0;
            for (var i = 0; i < frame.pointables.length; i++) {
              var pointable = frame.pointables[i];
              if (pointable.extended && !pointable.tool) {
                countFingersExtended++;
              }
            }
            console.log("number of fingers extended: " + countFingersExtended);
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
              } else if (gesture.type == "keyTap") { // check for screen tap
                console.log("performing selection");
                performAction(selectX, selectY);
              } else {
                console.log("unknown gesture type");
              }
            }
          } else if (countFingersExtended == 1) {
            // select rect
            var handPosition = hand.palmPosition;
            var DIFF = 400.0;
            var LOWER_X_BOUND = -200;
            var LOWER_Y_BOUND = 0; 
            selectX = Math.floor(((handPosition[0] - LOWER_X_BOUND) / DIFF) * NUM_ROWS);
            selectY = Math.floor(((handPosition[1] - LOWER_Y_BOUND) / DIFF) * NUM_ROWS);
            setSelectRect(selectX, selectY);
          } else if (countFingersExtended > 1) {
            if (roll > 0.5) { // tilt left
              panLeft(SCROLLSPEED);
              console.log("shifting left");
            } else if (roll < -0.5) { // tilt right
              panRight(SCROLLSPEED);
              console.log("shifting right");
            } else if (pitch > 0.5) { // tilt back
              panBackward(SCROLLSPEED);
              console.log("tilting backward");
            } else if (pitch < -0.5) { // tilt forward
              panForward(SCROLLSPEED);
              console.log("tilting forward");
            } else if (yaw < -0.5) { // rotating counterclockwise
              rotateLeft(ROTATESPEED);
            } else if (yaw > 0.5) { // rotating clockwise
              rotateRight(ROTATESPEED);
            } else if (translation[1] > 5) {
              growRects();
            } else if (translation[1] < -5) {
              shrinkRects();              
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
                console.log("zooming out");
              } else if ((hand.type == "right" && translation[0] < -0.5) || (hand.type == "left" && translation[0] > 0.5)) {
                // zoom in
                zoomIn(ZOOMSPEED);
                console.log("zooming in");
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
        shrinkRects();
      } else if (e.keyCode == 71) { // G
        growRects();
      } else if (e.keyCode == 76) { // L
        performAction(15, 15); // hardcoded coords for testing
      } else if (e.keyCode == 82) { // R
        reset();
      } else if (e.keyCode == 80) { // P
        $('#pauseOnGesture').prop('checked', !document.getElementById("pauseOnGesture").checked);
        paused = document.getElementById("pauseOnGesture").checked;        
      } else {
        return;
      }
      updateMap();
      updateCamera();
      e.preventDefault();
    });

    $(document).ready(function(){
   	 	getDataPoints();
   	 	render();
    });
    
    
  </script>

	<!-- Site footer -->
	<div class="container">
		<div class="footer" style="color: white">
			&copy; Ignatius Damai, Jevon Yeoh, Lianhan Loh, Zhan Xiong Chin<br>
			PennApps - Fall 2014
		</div>
	</div>
</body>
</html>
