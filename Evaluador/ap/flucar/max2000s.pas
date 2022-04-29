{			F    L    U    C    A    R          I  I  E    1  9  9  7



           A R C H I V O   D E   E N T R A D A   D E   D A T O S
}

+BARRAS   {Nom   Tipo   P       Q        V   delta   Vmin  Vmax  Qmin  Qmax }
        CSALU138  1     0       0       1.01    0                -2     4
        CSALA138  3     9.45    0       1.01    0                -2     4
        PALMA015  3     3       0       1.02    0                -0.9   1.2
        TERRA015  3     1.216   0       1.02    0                -0.28  0.28
        BAYGO007  3     1.026   0       1.02    0                -0.12  0.18
        SEXTA015  3     0.0     0       1.0     0                -0.3   0.6
		  QUINT012  3     0       0       1.0     0                -0.3   0.5
{*}     MONTA315  2     0       0.007   1.02    0                -0.6   1.4
        MONTA500  4     0       0       1.02    0                  N     N
        MONTB500  4     0       0       1.02    0                  N     N
        MONTI500  4     0       0       1.02    0                  N     N
        PALMA500  2     0       0       1       0                  N     N
        CPALM500  2     0       0       1       0                  N     N
        SALTU500  2     0       0       1       0                  N     N
        SALTA500  2    -5.016  -0.5     1       0                  N     N
        CSALU500  2     0       0       1       0                  N     N
        CSALA500  2     0       0       1       0                  N     N
        SJAVI500  2     0       0       1       0                  N     N
        CELIA500  2    -3.968   0.15    1       0                  N     N
        SCARL500  2     0       0       1       0                  N     N
        MONTA150  2    -0.342  -0.123   1       0                  N     N
        MONTB150  2    -0.103  -0.037   1       0                  N     N
        MONTC150  2    -0.642  -0.231   1       0                  N     N
        MONTD150  2     0       0       1       0                  N     N
        MONTE150  2    -1.371  -0.493   1       0                  N     N
        MONTF150  2    -0.902  -0.453   1       0                  N     N
        MONTG150  2    -0.936  -0.338   1       0                  N     N
        MONTH150  2    -1.091  -0.392   1       0                  N     N
        MONTI150  2     0       0       1       0                  N     N
        MONTJ150  2    -1.1    -0.396   1       0                  N     N
        MONTK150  2    -0.532  -0.191   1       0                  N     N
        MONTL150  2    -0.439  -0.158   1       0                  N     N
        MONTN150  2    -0.819  -0.295   1       0                  N     N
        MONTR150  2    -0.608  -0.219   1       0                  N     N
        SVAZQ150  2    -0.212  -0.077   1       0                  N     N
        SOLYM150  2    -0.136  -0.049   1       0                  N     N
        PANDO150  2    -0.568  -0.206   1       0                  N     N
        BIFUR150  2    -0.489  -0.176   1       0                  N     N
        PAZU1150  2    -0.103  -0.037   1       0                  N     N
        PAZU2150  2     0       0       1       0                  N     N
        MALDO150  2    -0.659  -0.077   1       0                  N     N
        SCARL150  2     0       0       1       0                  N     N
        MERCE150  2     0.567  -0.14    1       0                  N     N
        YOUNG150  2    -0.067  -0.025   1       0                  N     N
        PAYSA150  2    -0.392  -0.141   1       0                  N     N
        SALTO150  2    -0.262  -0.094   1       0                  N     N
        SALTU150  2    -0.153   0.065   1       0                  N     N
        SJAVI150  2     0       0       1       0                  N     N
        PALMA150  2     0       0       1       0                  N     N
        BAYGO150  2     0       0       1       0                  N     N
        TERRA150  2    -0.565   0.077   1       0                  N     N
        ACOR1150  2     0       0       1       0                  N     N
        ACOR2150  2     0       0       1       0                  N     N
        ACORR150  2    -0.375  -0.134   1       0                  N     N
        DURAZ150  2    -0.227  -0.082   1       0                  N     N
        FLORI150  2    -0.175  -0.062   1       0                  N     N
        RODRI150  2    -0.483  -0.128   1       0                  N     N
        PALMA315  2     0       0       1       0                  N     N
        NUDOA     2     0       0       1       0                  N     N
        NUDOP     2     0       0       1       0                  N     N


{Nota 1: Tipos de nodo: Tipo 1:  Barra flotante (Datos: V,delta)
                        Tipo 2:  Barra de carga (Datos: P,Q)
                        Tipo 3:  Barra de generaci¢n (Datos: P,V)
                        Tipo 4:  Barra de voltaje controlado (Datos: P,Q,V)

 Nota 2:  Cuando una variable no sea dato deber  escribirse el valor inicial
			del cual se quiere que comience la iteraci¢n.

 Nota 3:  En las columnas de l¡mites deben escribirse dos l¡mites £nicamente
		  (m¡nimo y m ximo de V o de Q).  En el caso de querer correr el
		  flujo sin l¡mites en una barra se debe escribir la letra N (no
		  hay l¡mites) en las columnas correspondientes.
}


+IMPEDANCIAS
{
											 Z
                  b1---------/////////---------b2

}


      { Nombre   bs           bll         Z        Imax }
         z1     SALTA500   SALTA500    0+j2.00000   0    
         z2     PALMA500   PALMA500    0+j0.66666   0    
         z3     MONTB500   MONTB500    0+j2.00000   0    
         z4     SALTU500   SALTU500    0+j2.00000   0    
         z5     SJAVI500   SJAVI500    0+j1.00000   0    
         z6     PALMA315   PALMA315    0+j1.66667   0    
         z7     CELIA500   CELIA500    0+j2.00000   0    



+CUADRIPOLOSPI
 {                                 Z12
                       b1 -------////////-----   b2
                           ­                ­
                           /                /
                      Y13  /                /  Y23
                           /                /
                           ­                ­
                           N                N
 }

{          b1         b2       b3      Y13             Z12          Y23       Imax}
 cua001 MONTA500   MONTB500    N    0+j0.10185   0.00011+j0.00107 0+j0.10185    0
 cua002 MONTA500   MONTI500    N    0+j0.16275   0.00018+j0.00171 0+j0.16275    0
 cua003 MONTI500   SCARL500    N    0+j1.30200   0.00144+j0.01369 0+j1.30200    0                                             
 cua004 MONTA500   PALMA500    N    0+j2.40345   0.00266+j0.02527 0+j2.40345    0
 cua005 MONTB500   PALMA500    N    0+j2.31315   0.00256+j0.02432 0+j2.31315    0
 cua006 PALMA500   SJAVI500    N    0+j0.81585   0.00090+j0.00858 0+j0.81585    0
 cua007 PALMA500   SJAVI500    N    0+j0.84210   0.00093+j0.00885 0+j0.84210    0
 cua008 CPALM500   PALMA500    N    0+j0.10710   0.00001+j0.00013 0+j0.10710    0
 cua009 SALTU500   SJAVI500    N    0+j1.52880   0.00169+j0.01607 0+j1.52880    0
 cua010 CSALU500   SALTU500    N    0+j0.01260   0.00001+j0.00013 0+j0.01260    0
 cua011 CSALA500   SALTA500    N    0+j0.03150   0.00003+j0.00033 0+j0.03150    0
 cua012 SALTA500   SALTU500    N    0+j0.03885   0.00004+j0.00041 0+j0.03885    0
 cua013 CELIA500   SALTA500    N    0+j1.65900   0.00183+j0.01744 0+j1.65900    0
 cua014 CELIA500   SJAVI500    N    0+j0.24675   0.00027+j0.00259 0+j0.24675    0
 cua015 MONTA150   MONTB150    N    0+j0.00691   0.00255+j0.01641 0+j0.00691    0
 cua016 MONTA150   MONTN150    N    0+j0.00338   0.00293+j0.00824 0+j0.00338    0
 cua017 MONTA150   MONTN150    N    0+j0.00338   0.00293+j0.00824 0+j0.00338    0
 cua018 MONTN150   MONTR150    N    0+j0.10846   0.00138+j0.00323 0+j0.10846    0
 cua019 MONTL150   MONTR150    N    0+j0.15625   0.00199+j0.00465 0+j0.15625    0
 cua020 MONTA150   MONTL150    N    0+j0.00774   0.00286+j0.01840 0+j0.00774    0
 cua021 MONTB150   MONTL150    N    0+j0.00698   0.00258+j0.01658 0+j0.00698    0
 cua022 MONTB150   MONTC150    N    0+j0.01088   0.00402+j0.02586 0+j0.01088    0
 cua023 MONTB150   MONTC150    N    0+j0.01088   0.00402+j0.02586 0+j0.01088    0
 cua024 MONTC150   MONTD150    N    0+j0.00167   0.00062+j0.00398 0+j0.00167    0
 cua025 MONTC150   MONTD150    N    0+j0.00167   0.00062+j0.00398 0+j0.00167    0
 cua026 MONTC150   SVAZQ150    N    0+j0.00551   0.00976+j0.01720 0+j0.00551    0
 cua027 MONTC150   SVAZQ150    N    0+j0.00551   0.00976+j0.01720 0+j0.00551    0
 cua028 MONTD150   MONTE150    N    0+j0.10300   0.00122+j0.00268 0+j0.10300    0
 cua029 MONTD150   MONTE150    N    0+j0.10300   0.00122+j0.00268 0+j0.10300    0
 cua030 MONTA150   MONTI150    N    0+j0.01290   0.00477+j0.03067 0+j0.01290    0
 cua031 MONTA150   SOLYM150    N    0+j0.01809   0.01039+j0.04422 0+j0.01809    0
 cua032 MONTI150   MONTH150    N    0+j0.05462   0.00058+j0.00122 0+j0.05462    0
 cua033 MONTI150   MONTH150    N    0+j0.05462   0.00058+j0.00122 0+j0.05462    0
 cua034 MONTI150   MONTH150    N    0+j0.05462   0.00058+j0.00122 0+j0.05462    0
 cua035 MONTI150   SOLYM150    N    0+j0.00951   0.00722+j0.02383 0+j0.00951    0
 cua036 MONTI150   MONTK150    N    0+j0.00340   0.00258+j0.00851 0+j0.00340    0
 cua037 MONTE150   MONTF150    N    0+j0.11397   0.00145+j0.00339 0+j0.11397    0
 cua038 MONTF150   MONTH150    N    0+j0.06066   0.00077+j0.00180 0+j0.06066    0
 cua039 MONTF150   MONTH150    N    0+j0.06066   0.00077+j0.00180 0+j0.06066    0
 cua040 MONTE150   MONTJ150    N    0+j0.06802   0.00086+j0.00202 0+j0.06802    0
 cua041 MONTJ150   MONTG150    N    0+j0.04779   0.00061+j0.00142 0+j0.04779    0
 cua042 MONTG150   MONTR150    N    0+j0.11528   0.00135+j0.00302 0+j0.11528    0
 cua043 SCARL150   MALDO150    N    0+j0.01179   0.00928+j0.03154 0+j0.01179    0
 cua044 SCARL150   MALDO150    N    0+j0.01482   0.01967+j0.04001 0+j0.01482    0
 cua045 SCARL150   PAZU1150    N    0+j0.02184   0.03160+j0.05981 0+j0.02184    0
 cua046 MONTA150   PANDO150    N    0+j0.01499   0.01428+j0.04305 0+j0.01499    0
 cua047 MONTA150   BIFUR150    N    0+j0.03636   0.06214+j0.10314 0+j0.03636    0
 cua048 MONTA150   BIFUR150    N    0+j0.03636   0.06214+j0.10314 0+j0.03636    0
 cua049 BIFUR150   PAZU1150    N    0+j0.02475   0.04229+j0.07020 0+j0.02475    0
 cua050 BIFUR150   PAZU2150    N    0+j0.02475   0.04229+j0.07020 0+j0.02475    0
 cua051 PAZU2150   MALDO150    N    0+j0.02354   0.04023+j0.06678 0+j0.02354    0
 cua052 SALTU150   SALTO150    N    0+j0.00831   0.00774+j0.02311 0+j0.00831    0
 cua053 SALTO150   PAYSA150    N    0+j0.06710   0.06253+j0.18667 0+j0.06710    0
 cua054 PAYSA150   YOUNG150    N    0+j0.03896   0.06658+j0.11079 0+j0.03896    0
 cua055 YOUNG150   MERCE150    N    0+j0.04826   0.08459+j0.14387 0+j0.04826    0
 cua056 SJAVI150   MERCE150    N    0+j0.05683   0.05412+j0.16316 0+j0.05683    0
 cua057 TERRA150   BAYGO150    N    0+j0.02345   0.02299+j0.07308 0+j0.02345    0
 cua058 BAYGO150   PALMA150    N    0+j0.05896   0.05515+j0.16668 0+j0.05896    0
 cua059 TERRA150   YOUNG150    N    0+j0.07386   0.12623+j0.21004 0+j0.07386    0
 cua060 DURAZ150   TERRA150    N    0+j0.03780   0.03285+j0.09234 0+j0.03780    0
 cua061 DURAZ150   MONTA150    N    0+j0.11475   0.09973+j0.28031 0+j0.11475    0
 cua062 FLORI150   MONTA150    N    0+j0.06075   0.05280+j0.14840 0+j0.06075    0
 cua063 FLORI150   TERRA150    N    0+j0.09180   0.07979+j0.22425 0+j0.09180    0
 cua064 MONTB150   ACOR1150    N    0+j0.02229   0.02084+j0.06300 0+j0.02229    0
 cua065 MONTB150   ACOR2150    N    0+j0.02229   0.02084+j0.06300 0+j0.02229    0
 cua066 ACOR1150   ACORR150    N    0+j0.00441   0.00420+j0.01266 0+j0.00441    0
 cua067 ACOR2150   ACORR150    N    0+j0.00441   0.00420+j0.01266 0+j0.00441    0
 cua068 ACOR1150   PALMA150    N    0+j0.13276   0.12417+j0.37530 0+j0.13276    0
 cua069 ACOR2150   RODRI150    N    0+j0.01019   0.00953+j0.02880 0+j0.01019    0
 cua070 RODRI150   BAYGO150    N    0+j0.12671   0.11852+j0.35820 0+j0.12671    0


+TRAFOS
{
                                             1:n
                                         -  -   -  -        Zcc
			  Nodo1  ----- -      -      - ----/////---- Nodo2
                                         -  -   -  -
 }

    {  Nombre           b1       b2      n       Zcc         Imax }

       traf001       MONTA150   NUDOA    1     0+j0.00153      0
       traf002       MONTA315   NUDOA    1     0+j0.02835      0                                          
       traf003       PALMA500   NUDOP    1     0+j0.04750      0
       traf004       PALMA150   NUDOP  0.932   0-j0.00750      0
       traf005       PALMA315   NUDOP    1     0+j0.04250      0
       traf006       SJAVI500   SJAVI150 1     0+j0.10666      0
       traf007       SALTU500   SALTU150 1     0+j0.10666      0
       traf008       SCARL500   SCARL150 1.05  0+j0.03200      0
       traf009       MONTE150   TRECU105 1.029 0+j0.09500      0 
       traf010       PALMA015   CPALM500 1.050 0+j0.03601      0
       traf011       TERRA015   TERRA150 1.1   0+j0.08403      0
       traf012       BAYGO007   BAYGO150 1.1   0+j0.11870      0  
       traf013       MONTE150   SEXTA015 1.033 0+j0.07000      0  
       traf014       MONTE150   QUINT012 1.127 0+j0.11800      0
       traf015       CSALU138   CSALU500 1.050 0+j0.02964      0
       traf016       CSALA138   CSALA500 1.050 0+j0.02964      0
                


{Nota:	La corriente m xima admisible por una impedancia, cuadripolo,
        o transformador debe anotarse debajo de Imax.  En el caso de
        no querer establecer restricci¢n sobre la corriente escribir
        0. Para los trafos Imax es la del secundario
}
+REGULADORES

  {Nombre     b1       b2         n    nmin     nmax         Zcc         Imax }
	reg001  MONTA500  NUDOA       1.02   0.9      1.1      0+j0.02012       0
	reg002  MONTB500  MONTB150    1.02   0.9      1.1      0+j0.02894       0
	reg003  MONTI500  MONTI150    1.02   0.9      1.1      0+j0.02165       0



+TOLERANCIA     0.001

+NITS         50

+FIN.
