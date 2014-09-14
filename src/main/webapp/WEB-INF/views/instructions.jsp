<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Data visualization for Leap Motion">
    <meta name="author" content="JY, ID, ZX, LH">
    <link rel="icon" href="<c:url value="/resources/img/leapvis-favicon.png"/>">

    <title>LeapVis - PennApps Fall 2014</title>

    <!-- Bootstrap core CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">

    <!-- Custom styles for this template -->
    <link href="http://getbootstrap.com/examples/justified-nav/justified-nav.css" rel="stylesheet">
    <link href='http://fonts.googleapis.com/css?family=Source+Sans+Pro:300' rel='stylesheet' type='text/css'>

    <style>
	  body {
	    font-family: 'Source Sans Pro', sans-serif;
	    background-image: url("<c:url value="/resources/img/use_your_illusion.png"/>");
	  }
	  h1 {
	  	color: white;
	  }
	  .jumbotron {
	  	color: white;
	  }
	  .footer {
	  	color: white;
	  }
	</style>
  </head>

  <body>

    <div class="container">
      <table>
        <tr>
          <td><a href="<c:url value ="/"/>"><img src="<c:url value="/resources/img/leapvis-transparent.png"/>" width="200px" height="55px"></a></td>
          <td>
            <ul class="nav nav-justified" style="opacity:0.8">
              <li><a href="<c:url value ="/about"/>">About</a></li>
              <li class="active"><a href="#">Instructions</a></li>
            </ul>
          </td>
        </tr>
      </table>

      <!-- Jumbotron -->
      <br>
      <div style="color:white">
        <p>
        	Required items
        	<ul>
        		<li>Leap Motion controller</li>
        		<li>Dextrous hands</li>
        	</ul>
        </p>
        <p>
        	If you don't happen to have a Leap Motion controller, you can use the arrow buttons and various keystrokes to
        	interact with the map. The buttons that work are
        	<ul>
        		<li>Up, Down, Left, Right arrow keys</li>
        		<li>W, A, S, D, Q, E</li>
        	</ul>

        </p>
      </div>

      <!-- Site footer -->
      <div class="footer">
        <p>&copy; Ignatius Damai, Jevon Yeoh, Lianhan Loh, Zhan Xiong Chin<br>
        	PennApps - Fall 2014

        </p>

      </div>

    </div> <!-- /container -->

  </body>
</html>
