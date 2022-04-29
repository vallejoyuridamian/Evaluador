{			F    L    U    C    A    R          I  I  E    1  9  9  7



           A R C H I V O   D E   E N T R A D A   D E   D A T O S
}

+BARRAS   {Nom   Tipo   P       Q        V   delta   Vmin  Vmax  Qmin  Qmax }
			  ROD5   1     0       0        1      0     N     N
			  S.G.   3     46.10   4.786    1.05   0                 -0.5  22.8


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


				  { Nombre   bs     bll    Z      Imax }
						z1     b1     b2     1+j1    0
						z2     N      b1     0-j100  0


+CUADRIPOLOSPI
 {       								Z12
						  b1 -------////////------- b2
								 ­                ­
								 /                /
						  Y13  /                /  Y23
								 /                /
								 ­                ­
								 N                N
 }


				{ b1   b2   b3   Y13         Z12       Y23    Imax}


+TRAFOS
{
									 1:n
								  -  -   -  -        Zcc
			  Nodo1  ----- -      -      - ----/////---- Nodo2
								  -  -   -  -
 }

				{ b1   b2   n    Zcc    Imax }


{Nota:	La corriente m xima admisible por una impedancia, cuadripolo,
			o transformador debe anotarse debajo de Imax.  En el caso de
			no querer establecer restricci¢n sobre la corriente escribir
			0. Para los trafos Imax es la del secundario
}
+REGULADORES

				{ b1   b2   n    nmin    nmax     delta_n    Zcc    Imax }

+TOLERANCIA     0.001

+NITS         50

+FIN.
