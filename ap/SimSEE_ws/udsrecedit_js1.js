<script language="JavaScript">
    var
       ncambiotexto = 0;

    function incambiotexto( ) {
        ncambiotexto += 1;
    }


// obtiene referencia a campo
    function campo(f, nombre) {
        var e = f.elements['CFrch_' + nombre];
        return e;
    }



// retorna true si checkStr parace un email válido
// si no es válido hace una alert( ) con la causa y retorna false
    function VerifyEmailAddress(checkStr)
    {
        var Reason = '';
        var Success = '';

        var ix = (checkStr.length - 4)
        var RC = true;
        var x = AtSignValid = DoublePeriod = PeriodValid = SpaceValid = ExtValid = RL = 0;
        for (i = 0; i < checkStr.length; i++)
        {
            if (checkStr.charAt(i) == '@')
                AtSignValid++;
            else if (checkStr.charAt(i) == '.')
            {
                if (x == (i - 1))
                    DoublePeriod++;
                else
                {
                    x = i;
                    PeriodValid++;
                }
            }
            else if (checkStr.charAt(i) == ' ')
                SpaceValid++;
        }


        var res = '';

        if (AtSignValid != 1) {
            if (AtSignValid > 1) {
                res += "\nTiene más de un @!";
            } else {
                res += "\nFalta @!";
            }
        }

        if (PeriodValid == 0)
            res += "\nFalta por lo menos un punto.";
        if (SpaceValid > 0)
            res += "\nTiene espacios";
        if (checkStr.length > 120)
            res += "\nDemasiado larga la dirección";



        if (res != '') {
            alert(res);
            return false;
        }
        return true;
    }


    function default_pO(f, xo, nido, kfoto) {
        var e = f.elements;
        var res = 1;

        f.action = '';

        if (xo == 'cancel') {
            e['xo'].value = xo;
            if (nido > 0)
                e['nido'].value = nido;
            e['kfoto'].value = kfoto;
            f.submit();
            return false;
        }

        if (xo == 'saveimg') {
            if (e['userfile'].value.length < 4) {
                alert('Debe seleccionar primero un archivo de imagen (jpg) de su computadora.');
                res = 0;
                return false;
            }
        }
        if (xo == 'savepdf') {
            if (e['userfile'].value.length < 4) {
                alert('Debe seleccionar primero un archivo PDF de su computadora.');
                res = 0;
                return false;
            }
        }
        if (xo == 'savemp3') {
            if (e['userfile'].value.length < 4) {
                alert('Debe seleccionar primero un archivo mp3 de su computadora.');
                res = 0;
                return false;
            }
        }

        if (xo == 'delrec') {
            input_box = confirm("Confime que realmente quiere eliminar este registro");
            if (!input_box) {
                alert('Eliminación cancelada');
                res = 0;
                return false;
            }
        }

        // si está definida la función chequeo_form la llamamos
        if (typeof (chequeo_form) == 'function') {
            if (!chequeo_form(f)) {
                res = 0;
                return false;
            }
        }

        if (xo == 'change_order_by')
        {
            e['order_by'].value = nido;
            nido = 0;
        }

        if (res == 1) {
            e['xo'].value = xo;
            if (nido > 0)
                e['nido'].value = nido;
            e['kfoto'].value = kfoto;
            f.submit();
        }
        return false;
    }

    function pO(f, xo, nido, kfoto) {
        var e = f.elements;
        var res = 1;

        // si está definida la función pre_pO( ) la llamo.
        if (typeof (pre_pO) == 'function') {
            // si el resultado es < 0 indica que algo falló y no hay que hacer submit
            // si el resultado es 0 indica ppor ahora todo Ok y continúa con la interpretación
            // si el resultado es > 0 indica ok ya hizo el submit y no hay que continuar
            var res_pre_pO = pre_pO(f, xo, nido, kfoto);
            if (res_pre_pO != 0) {
                res = 0;
                return false;
            } else {
                return default_pO(f, xo, nido, kfoto);
            }
        } else {
            return default_pO(f, xo, nido, kfoto);
        }
    }

// agrega un campo hidden al formulario al vuelo.
// es útil para agregar campos en pre_pO( ) por ejemplo si el submit
// se realiza a una página que espera campos diferentes.
    function append_hidden(f, name, value)
    {
        var input = document.createElement("input");
        input.setAttribute("type", "hidden");
        input.setAttribute("name", name);
        input.setAttribute("id", name);
        input.setAttribute("value", value);
        f.appendChild(input);
    }

</script>
<script language="JavaScript">

    function strToFloat(s) {
        vr = new String(s);
        while (vr.indexOf(sep_miles) >= 0)
            vr = vr.replace(sep_miles, "");
        while (vr.indexOf(sep_millones) >= 0)
            vr = vr.replace(sep_millones, "");
        vr = vr.replace(sep_decimales, ".");
        return parseFloat(vr);
    }

    function floatToStr(f, ndecs) {
        for (k = 0; k < ndecs; k++)
            f = f * 10;
        var s = new String('' + parseInt(f + 0.5));

        while (s.length < (ndecs + 1)) {
            s = '0' + s;
        }

        ic = s.length - ndecs;
        r = sep_decimales + s.substr(ic);
        ic--;
        k = 0;
        while (ic >= 0) {
            if ((k > 0) && ((k % 3) == 0)) {
                if ((k % 6) == 0) {
                    r = sep_millones + r;
                } else {
                    r = sep_miles + r;
                }
            }
            letra = s.charAt(ic);
            r = letra + r;
            ic--;
            k++;
        }
        return r;
    }


// onkeydown_numero
    function onkeydown_numero(campo, tammax, ndecs, teclapres) {
        var tecla = teclapres.keyCode;
        var tk;
        var c;

//  tk = ( (QualNavegador()=="IE") ? teclapres.keyCode : teclapres.which);

        tk = teclapres.keyCode;

        if ((tk >= 96) && (tk <= 105))
            tk = tk - 96 + 48; // para que funcione el teclado numérico
        c = String.fromCharCode(tk);
        tecla = tk;

        s = campo.value;

        if (ndecs > 0) {
            v = strToFloat(s);
        } else {
            v = parseInt(s);
        }


        if (tecla == 8 || (c >= '0' && c <= '9')) {
            if (tecla != 8) {
                if (s.length < tammax) {
                    if (ndecs > 0) {
                        campo.value = floatToStr(v * 10, ndecs - 1) + c;
                    } else {
                        campo.value = v + c;
                    }
                }
                return false;
            } else {
                if (ndecs > 0) {
                    campo.value = floatToStr(v / 10, ndecs);
                } else {
                    campo.value = parseInt(v / 10);
                }
                return false;
            }

        } else {
            if (tecla < 32) {
                return true;
            } else {
                if (tecla == 46) {
                    campo.value = floatToStr(0, ndecs);
                    return true;
                } else {
                    return false;
                }

            }
        }
    }



// onkeydown_numero
    function onkeydown_solodigitos(campo, tammax, teclapres) {
        var tecla = teclapres.keyCode;
        var tk;
        var c;

//  tk = ( (QualNavegador()=="IE") ? teclapres.keyCode : teclapres.which);

        tk = teclapres.keyCode;

        if ((tk >= 96) && (tk <= 105))
            tk = tk - 96 + 48; // para que funcione el teclado numérico
        c = String.fromCharCode(tk);
        tecla = tk;

        s = campo.value;

        if (tecla == 8 || (c >= '0' && c <= '9')) {
            if (tecla != 8) {
                if (s.length < tammax) {
                    campo.value = s + c;
                }
                return false;
            } else {
                campo.value = s.substr(0, s.length - 1);
                return false;
            }
        } else {
            if (tecla < 32) {
                return true;
            } else {
                if (tecla == 46) {
                    campo.value = '';
                    return true;
                } else {
                    return false;
                }
            }
        }
    }

</script>
