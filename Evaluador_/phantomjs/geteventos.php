<?php
    
	require_once dirname(__FILE__) . '/PHPExcel-1.8/Classes/PHPExcel.php';
	require_once dirname(__FILE__) . '/PHPExcel-1.8/Classes/PHPExcel/IOFactory.php';
	require_once dirname(__FILE__) . '/get-website.php';
	
	$phantom_script= dirname(__FILE__). '/get-website.js'; 
	$response =  shell_exec(dirname(__FILE__).'/phantomjs '.$phantom_script);
	file_put_contents (dirname(__FILE__) .'/pagina_entera.txt',$response);

	$doc = new DOMDocument();
    @$doc->loadHTML($response);

	$ul  = $doc->getElementById('live_bet_menu');
	$html = $doc->saveHtml($ul);
	
	$doc = new DOMDocument();
    @$doc->loadHTML($html);


	file_put_contents (dirname(__FILE__) .'/live_bet_menu.txt',$html);
	
	$li = $doc->getElementsByTagName("li");
	
	foreach($li as $li){
		
		if($li->hasAttribute('class')){
			$clase =$li->getAttribute('class');
			if ($clase == 'sport code_sport-1'){
				$html = $doc->saveHtml($li);
				@$doc->loadHTML($html);
			}	
		}		
	}
	
	$li = $doc->getElementsByTagName("li");
	
	
	
	
	foreach($li as $li){
		if ($li->hasAttribute('class')){
			$clase =$li->getAttribute('class');
			if ($clase == 'event'){
				$html = $doc->saveHtml($li);
				$id = preg_match_all("'<a class=\"evento_menu \"(.*?)>'si",$html,$matches);
				if ($id == 1) {
					foreach ( $matches as $var ) {
						$id = $var[0];
					}				
					$ids.=preg_replace("/[^0-9]/","",$id)."<br>";				
					$infos.=preg_replace("/[^0-9]/","",$id)." ";
					// si tiene numero tambien traigamos cuanto va de partido, quien juega y el marcador
				
					$titulo = preg_match_all("'<span class=\"titulo\">(.*?)</span>'si",$html,$matches);
					if ($titulo == 1) {
						foreach ( $matches as $var ) {
							$titulo = $var[0];
						}
					$infos.=$titulo." ";	
					}	
					
					
					$marcador = preg_match_all("'<span class=\"marcador\">(.*?)</span>'si",$html,$matches);
					if ($marcador == 1) {
						foreach ( $matches as $var ) {
							$marcador = $var[0];
						}
					$infos.=$marcador." ";
					}
					
					
					$tiempo = preg_match_all("'<span>(.*?)</span>'si",$html,$matches);
					if ($tiempo == 1) {
						foreach ( $matches as $var ) {
							$tiempo = $var[0];
						}
						$infos.=$tiempo." ";
					}					
					$infos.="<br>";
				}			
			}			
		}
	}
	//echo $ids;
	echo $infos;
	file_put_contents (dirname(__FILE__) .'/infos.txt',$infos);
	
	
	$ids=explode("<br>",$ids);
	
	foreach($ids as $id){
		
		getWebsite($id);
		
		
	}
	
?>