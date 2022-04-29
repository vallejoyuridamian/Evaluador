<?php

function getWebsite($idEvento){
   
	require_once dirname(__FILE__) . '/PHPExcel-1.8/Classes/PHPExcel.php';
	require_once dirname(__FILE__) . '/PHPExcel-1.8/Classes/PHPExcel/IOFactory.php';
    
	//$idEvento = '12508594';
	//echo "abriendo <br>";
	echo $idEvento."<br>";
	$archijscont=	
	"
	var webPage = require('webpage');
	var page = webPage.create();
	
	page.settings.loadImages  = false;
	
	page.open('https://www.supermatch.com.uy/live#/$idEvento', function(status) {
	  
	  setTimeout(function() {
		console.log(page.content);
		phantom.exit();
	  }, 4000);
    });
	
	";
	
	
		
	/*$archijscont=	
	"
	var webPage = require('webpage');
	var page = webPage.create();

	page.open('https://www.example.com/', function(status) {
	  
	  setTimeout(function() {
		console.log(page.content);
		page.render('yourLoadedPage.png');
		phantom.exit();
	  }, 2000);
  
  
	});";*/
	
	$archijsdir=dirname(__FILE__). '/get-website.js';
	file_put_contents ($archijsdir,$archijscont);
	
	$phantom_script= dirname(__FILE__). '/get-website.js'; 
	
	echo "corriendo el phantom <br>";
	$response =  shell_exec(dirname(__FILE__).'/phantomjs '.$phantom_script);
	echo "corrio<br>";
	file_put_contents (dirname(__FILE__).'/pagina_entera.txt',$response);

	//echo "cargo <br>";
	$doc = new DOMDocument();
    @$doc->loadHTML($response);

	$div  = $doc->getElementById('livematchtracker');
	$html = $doc->saveHtml($div);
	
	$Nequipos = preg_match_all("'<span class=\"sr-full  sr-ltr-text\">(.*?)</span>'si",$html,$matches);
	if ($Nequipos == 2) {
		$partido= strip_tags((string)$matches[0][0]." VS ".(string)$matches[0][1])." (id=$idEvento)"."<br>";					
	}
	else{
		$partido= "\$Nequipos no es 2, es ".$Nequipos."<br>";
	}
			
	$tiempo = preg_match_all("'<span class=\"countdown_row countdown_amount\">(.*?)</span>'si",$html,$matches);
	if ($tiempo == 1) {
			foreach ( $matches as $var ) {
				$tiempo = $var[0];
			}			
			$tiempoglob= "Tiempo: ".$tiempo."<br>";	
	}
	else{
		
		$tiempo = preg_match_all("'<div class=\"sr-live sr-clock-inactive\">(.*?)</div>'si",$html,$matches);
		if ($tiempo == 1) {
			foreach ( $matches as $var ) {
				$tiempo = $var[0];
			}			
			$tiempoglob= "Tiempo: ".$tiempo;	
			$complemento = preg_match_all("'<div class=\"sr-live-overtime hasCountdown\">(.*?)</div>'si",$html,$matches);
			if ($complemento == 1) {
				foreach ( $matches as $var ) {
					$complemento = $var[0];
				}
			}
			$tiempoglob.= $complemento."<br>";		
		}	
		else{
			
				$Nestado = preg_match_all("'<div class=\"sr-status-info-fullscore\">(.*?)</div>'si",$html,$matches);
				//echo $Nestado."<br>";
				if ($Nestado == 1) {
					foreach ( $matches as $var ) {
						$estado = $var[0];
					}
					//$estado = str_replace(array("\r", "\n"), '', (string)matches[0][0]);
					
				}		
		}
	}

	
	$GolesLocal = preg_match_all("'<div class=\"sr-result-value sr-home\">(.*?)</div>'si",$html,$matches);
	if ($GolesLocal == 1) {
		foreach ( $matches as $var ) {
			$goles = $var[0];
		}
		$marcador.="Marcador: ".(string)$goles.":";					
	}	
	$GolesVisitante = preg_match_all("'<div class=\"sr-result-value sr-away\">(.*?)</div>'si",$html,$matches);
	if ($GolesVisitante == 1) {
		foreach ( $matches as $var ) {
			$goles = $var[0];
		}
		$marcador.= (string)$goles."<br>";					
	}	
	
	// Me quedo con la parte de las apuestas en vivo
	$div = $doc->getElementById('live_center');
	if ($div !=null){
		$output = '';
		foreach($div->childNodes as $element)
		{
			$output .= $element->ownerDocument->saveHtml($element);
		}
		/*echo htmlspecialchars($output);*/
		file_put_contents (dirname(__FILE__).'/divs_live_center.txt',$output);
		/*echo htmlspecialchars($doc->SaveHTML());*/
			
		// Creo un nuevo DOM solo con la columna del medio
		$doc = new DOMDocument();
		@$doc->loadHTML($output);
		
		$div = $doc->getElementsByTagName('div');
		foreach($div as $div){
			if ($div->hasAttribute('class')){
				$clase =$div->getAttribute('class');
				if ((strcmp($clase,"opcion ") == 0)OR(strcmp($clase,"columns small-12 large-4 opcion "))==0){
					$span = $div->getElementsByTagName('span');

					foreach($span as $span){
						if ($span->hasAttribute('class')){
							$clase = $span->getAttribute('class');
							if (strcmp($clase,"linea_descripcion")==0){
								$html = $doc->saveHtml($div);
								
								$descripcion = preg_match_all("'<span class=\"linea_descripcion\" style=\"display:none\">(.*?)</span>'si",$html,$matches);
								if ($descripcion == 1) {
									foreach ( $matches as $var ) {
										$descripcion = $var[0];
									}		
									
									if (preg_match_all("/Marcador exacto/i",$descripcion,$matches)){
										
											$opcion = preg_match_all("'<span class=\"option_id\" style=\"display:none\">(.*?)</span>'si",$html,$matches);
											if ($opcion == 1) {
												foreach ( $matches as $var ) {
													$opcion = $var[0];
												}		
																						
											}
											$dividendo = preg_match_all("'<span class=\"chances \">(.*?)</span>'si",$html,$matches);
											if ($dividendo == 1) {
												foreach ( $matches as $var ) {
													$dividendo = $var[0];
												}
												$renglones.='Marcador Exacto '.$opcion."; ".$dividendo."<br>";											
											}										
											
									}																
								}
							}	
						}
					}					
				}		
			}
		}
		date_default_timezone_set("America/Montevideo");
		$timestamp="Fecha y hora ". date("Y-m-d / H:i:s")."<br>";
		$estado="Estado: ".$estado."<br>";
		// escupimiento
		//echo $partido;
		//echo $timestamp;
		//echo $estado;					
		//echo $tiempoglob;
		//echo $marcador;
		$renglones = explode("<br>",$renglones);
		$renglones = array_unique($renglones);
		$renglones = implode ( "<br>" ,  $renglones );
		//echo $renglones;	
		$columna=$partido.$timestamp.$estado.$tiempoglob.$marcador.$renglones;
		echo $columna;
		//$columna=str_replace("<br>","\r\n",$columna);
		$columna=explode("<br>",$columna);
		$filename=dirname(__FILE__)."/".str_replace(" ","_",str_replace("<br>","",$partido)).'.xlsx';
		if (file_exists ($filename)){
		  
		  $xls = PHPExcel_IOFactory::load($filename);
				
		  $valor='dummy';
		  $columnaExcel=0;
		  while ($valor != ''){
			
			$colString = PHPExcel_Cell::stringFromColumnIndex($columnaExcel);
			$valor = $xls->getActiveSheet()->getCell($colString.'1')->getValue();
			$columnaExcel = $columnaExcel + 1;	  
			
		  }
		  
		  
		}
		else{
			$xls = new PHPExcel();	
			$colString='A';
		}		
		$xls->setActiveSheetIndex(0);
		$fila=1;	
	   
		foreach($columna as $renglon){
			$xls->setActiveSheetIndex(0)
				->setCellValue($colString.$fila, $renglon);
			$fila=$fila+1;			   
		}    	
		$xls->getActiveSheet()->setTitle('Hoja1');		
		$xlsWriter = PHPExcel_IOFactory::createWriter($xls, 'Excel2007');
		$xlsWriter->save($filename);
	}
}

?>