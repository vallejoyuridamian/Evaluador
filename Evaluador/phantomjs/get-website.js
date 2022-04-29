
	var webPage = require('webpage');
	var page = webPage.create();
	
	page.settings.loadImages  = false;
	
	page.open('https://www.supermatch.com.uy/live#/', function(status) {
	  
	  setTimeout(function() {
		console.log(page.content);
		phantom.exit();
	  }, 4000);
    });
	
	