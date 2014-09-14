<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Data visualization for Leap Motion">
    <meta name="author" content="">
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
	  p {
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
              <li class="active"><a href="#">About</a></li>
              <li><a href="<c:url value ="/instructions"/>">Instructions</a></li>
            </ul>
          </td>
        </tr>
      </table>

      <!-- Jumbotron -->
      <div class="jumbotron">
        <!-- <h1>LeapVis</h1> -->
        <p class="lead">
        	LeapVis is a data visualization platform that can be controlled using a Leap Motion controller.
        	<br><br>
        	This platform aims to make interacting with data more intuitive and easy to see such that analysis can be performed in an aesthetically pleasing way. 
        	<br><br>
        	LeapVis is built using the Leap Motion JavaScript API, with MongoDB on our backend.
        	<br><br>
        	Hacked on by Ignatius (igndamai@seas), Jevon (jevony@seas), Lianhan (lianhan@seas) and Zhan Xiong (chinz@seas) for PennApps X, Fall 2014.
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
