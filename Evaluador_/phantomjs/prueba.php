 <?php echo '<p>Hola Mundo</p>'; 


$cronfiles=exec('crontab -l',$output);
echo "<pre>";
print_r($output);
?>
