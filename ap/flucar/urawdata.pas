unit urawdata;

interface

uses
  uauxiliares, Classes, SysUtils, AlgebraC, xMatDefs,
  uactoresflucar,
  MatCPX,
  usistema,
  Dialogs;
// lexemas32


var
  NombreArch, NombreArchsal, NombreArchent, extensionent, extensionsal: string;
  f: Text;
  //procedure leerraw( archi: string );

  RAW_VER: integer;

type

  TRaw_CaseIdentification = class( TActorDato )
    IC:     integer;
    // Change Code 0: Clear Working Space before add data to it
    //       Code 1: add data to the working space
    // IC = 0 by default

    SBASE:  double;
    // System base MVA. SBASE = 100.0 by default

    //When current ratings are being specified, ratings are entered as:
    //MVArated =  3  x  Ebase  x  Irated  x  10-6
    //where:
    //Ebase Is the branch or transformer winding voltage base in volts.
    //Irated Is the rated phase current in amps.

    REV:    integer;
    //PSS®E revision number. REV = current revision (32) by default.
    XFRRAT: double;
    //Units of transformer ratings (refer to Transformer Data). The transformer percent
    //loading units program option setting (refer to Saved Case Specific Option Settings) is
    //set according to this data value.
    //XFRRAT < 0 for MVA
    //XFRRAT > 0 for current expressed as MVA
    //XFRRAT = present transformer percent loading program option setting by default
    //(refer to activity OPTN).
    NXFRAT: double;
    //Units of ratings of non-transformer branches (refer to Non-Transformer Branch
    //Data). The non-transformer branch percent loading units program option setting
    //(refer to Saved Case Specific Option Settings) is set according to this data value.
    //NXFRAT < 0 for MVA
    //NXFRAT > 0 for current expressed as MVA
    //NXFRAT = present non-transformer branch percent loading program option setting
    //by default (refer to activity OPTN).
    BASFRQ: double;
    //System base frequency in Hertz. The base frequency program option setting (refer to
    //Saved Case Specific Option Settings) is set to this data value. BASFRQ = present
    //base frequency program option setting value by default (refer to activity OPTN).

    //The next two records each contain a line of text to be associated with the case as its case title. Each
    //line may contain up to 60 characters, which are entered in columns 1 through 60.

    ds1, ds2: string; // dos líneas de 60 caracteres para descripción del caso
    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);
  end;

type
  TRaw_Bus = class( TBarra )
    Name: string[8];
    // 12 caracteres entre comillas 'Bus Name____' (no puede empezar con - (menos), 12 blancos por defecto)
    // Alphanumeric identifier assigned to bus "I". The name may be up to twelve characters
    // and must be enclosed in single quotes. NAME may contain any combination
    // of blanks, uppercase letters, numbers and special characters, but the first character
    // must not be a minus sign. NAME is twelve blanks by default.

    BASKV: double;     // BusVoltage in kV BASKV = 0.0 por defecto

    IDE: integer;
    // BusType 1: load bus (no generator boundary condition)
    //         2: generator or plan bus (either voltage regulator or fixed MVAR)
    //         3: swing bus
    //         4: disconnected (isolated ) bus
    // IDE = 1 by defualt


    GL: double;
    // Active component of shunt admitance to ground; in MW at one per unit voltage
    // GL should not include any resistive impedance load, which is entered as
    // part of load data. GL = 0.0 by default.

    BL: double;
    // Reactive componet of shunt admitance to ground; in MW at one per unit voltage
    // BL should not include any reactive impedance load, which is entered as
    // part of transformer data. BL is positive for a capacitor, an negative for
    // a reactor or inductive load. BL = 0.0 by default.


    AREA: integer;
    // Area number (1 through the maximum number of areas at the current size level
    // AREA = 1 by default.

    ZONE: integer;
    // Zone number ( 1 through the maximum number of zones at the current size level
    // ZONE = 1 by default.

    VM: double; // Bus voltage magnitude; entered in pu. VM = 1.0 by default.

    VA: double; // Bus voltage phase angle; entered in degrees. VA = 0.0 by default.

    OWNER:  integer;
    // Owner number ( 1 through the maximum number of owners at the current size level
    // OWNER = 1 by default

    constructor LoadFromText(sala: TSalaFlucar; var f: textfile); override;

    procedure cargue;


  end;

  TRaw_Load = class(TActorMonoBarra)
    ID: string; // one or two character upper case nonblank alphanumeric load
    // identifier used to distinguish among multiple load at bus "I"
    // It is recommended that, at buses for which a single load is present,
    // the load be designated having the load identifier '1'. ID = '1' by default.

    STATUS: integer; // Initial load status   of one for in-service and zero for
    // out-of-service. STATUS = 1 by default

    AREA: integer;
    // Area number (1 through the maximum number of areas at the current size level
    // By default the AREA is the area to which the bus "I" is assigned.

    ZONE: integer;
    // Zone number ( 1 through the maximum number of zones at the current size level
    // By default the AREA is the area to which the bus "I" is assigned.

    PL: double;
    // Active power component of constant MVA load; entered in MW. PL = 0.0 by default

    QL: double;
    // Reactive power component of constant MVA load; entered in Mvar. QL = 0.0 by default

    IP: double;
    // Active power compoent of constant current load; entered in Mvar at one per unit
    // voltage. IQ = 0.0 by default

    IQ: double;
    // Reactive power compoent of constant current load; entered in Mvar at one per unit
    // voltage. IQ = 0.0 by default

    YP: double; // Active power component of constant admitance load; entered in MW at one per
    // unit voltage. YP = 0.0 by default.

    YQ: double;
    // Reactive power component of constant admitance load; entered in Mvar at one per
    // unit voltage. YQ = 0.0 by default. YQ is negative for an inductive load.

    OWNER: integer;
    // Owner number ( 1 through the maximum number of owners at the current size level
    // By default the AREA is the area to which the bus "I" is assigned.


    // desde la ver32
    SCALE: integer;
    QSobreP:double;
    factorZona:double;
    constructor LoadFromText(sala: TSalaFlucar; var f: textfile); override;
    procedure cargue; override;
  end;

  TRaw_FixedShunt = class(TActorMonoBarra)

    //Fixed Bus Shunt Data

    //    Each network bus at which fixed bus shunt is to be represented must be specified in at least one
    //fixed bus shunt data record. Multiple fixed bus shunts may be represented at a bus by specifying
    //more than one fixed bus shunt data record for the bus, each with a different shunt identifier.

    //  Each fixed bus shunt data record has the following format:
    //I, ID, STATUS, GL, BL
    //where:
    //Fixed bus shunt data input is terminated with a record specifying a bus number of zero.
    //Fixed Shunt Data Notes
    //The area, zone, and owner assignments of the bus to which the shunt is connected are used for
    //area, zone, and owner totaling purposes (e.g., in activities AREA, OWNR, and ZONE; refer to
    //Sections 10.7 through 10.12) and for shunt scaling purposes (refer to SCAL).
    //The admittance specified in the data record can represent a shunt capacitor or a shunt reactor (both
    //with or without a real component) or a shunt resistor. It must not represent line connected admit-
    //tance, switched shunts, loads, line charging or transformer magnetizing impedance, all of which are
    //entered in other data categories.
//    I:      longint;
    //Bus number, or extended bus name enclosed in single quotes (refer to Extended
    //Bus Names). No default allowed.
    ID:     string;
    //One- or two-character uppercase non-blank alphanumeric shunt identifier used to
    //distinguish among multiple shunts at bus I. It is recommended that, at buses for
    //which a single shunt is present, the shunt be designated as having the shunt identi-
    //fier 1. ID = 1 by default.
    STATUS: integer;
    //Shunt status of one for in-service and zero for out-of-service. STATUS = 1 by
    //default.

    GL:     double;
    //Active component of shunt admittance to ground; entered in MW at one per unit
    //voltage. GL should not include any resistive impedance load, which is entered as
    //part of load data. GL = 0.0 by default.
    BL:     double;
    //Reactive component of shunt admittance to ground; entered in Mvar at one per unit
    //voltage. BL should not include any reactive impedance load, which is entered as
    //part of load data; line charging and line connected shunts, which are entered as part
    //of non-transformer branch data; transformer magnetizing admittance, which is
    //entered as part of transformer data; or switched shunt admittance, which is entered
    //as part of switched shunt data. BL is positive for a capacitor, and negative for a
    //reactor or an inductive load. BL = 0.0 by default.

    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);
    procedure cargue; override;

  end;




  TRaw_Generator = class(TActorMonoBarra)

//    I: longint; // Bus Number

    ID: string; // one or two character upper case nonblank alphanumeric load
    // identifier used to distinguish among multiple load at bus "I"
    // It is recommended that, at buses for which a single load is present,
    // the load be designated having the load identifier '1'. ID = '1' by default.

    PG: double; // Generator active power output; entered in MW. PG = 0.0 by default

    QG: double; // generator reactive power output; entered in Mvar. QG need to be entered
    // only if the case, as read in, is to be treated as a solved case. QG = 0.0 by default

    QT: double; // maximum generator reactive power output; entered in Mvar. For fixed
    // output generators ( i.e. nonregulating ), QT must be equal to the fixed Mvar output
    // QT = 9999.0 by default

    QB: double; // Minimum generator reactive power output; enterd in Mvar. For fixed
    // output generators, QB must be equal to the fixed Mvar outpu. QB = -9999.0 by default.

    VS: double; // Regulated voltage setpoint; entered in pu. VS = 1.0 by deafult.

    IREG: longint; // Bus number or extendes bus name enclosed in sigle quotes of a remote
    // type 1 or 2 bus who voltage is  to be regulated by this plant to the value
    // specified by VS. If the gus IREG is other than a type 1 or 2 bus, bus I regulates
    // it owns voltage to the value specified by VS. IREG is entered as zero if the plant is
    // to regulate it own voltage and MUST be zero for a type three (swing) bus. IREG = 0

    MBASE: double; // Total MVA base of the units represented by this machine; entered in MVA.
    // This data is not needed in normal power flow and equivalent construction work, but is
    // required for switching stuides, fault analysis, and dynamic simulation.
    // MBASE = system base MVA by default.

    ZR, ZX: double;
    // Complex machine impedance, ZSORCE; entered in pu on MBASE base. This data
    // is not needed in normal power flow and equivalent construction work, but is
    // required for switching studies, fault analysis, and dynamic simulation. For
    // dynamic simulation, this impedance this impedance must be set equal to the subtransient
    // impedance for those generators to be modeled by subtransient level machine models, and
    // to transient impedance for those to be modeled by classical or transient level models.
    // ZR = 0.0 and ZX = 1.0 by default.

    RT, XT: double; // Set-up tranformer impedance, XTRAN; entered in pu of MBASE base.
    // XTRAN should be entered as zero if the set-up transformer is explicity modeled as a
    // network branch and bus I is the terminal bus. RT+jXT = 0.0 by default.

    GTAP: double; // setu-up trnasfromer off-nominal turns ratio; entered in pu.
    // GTAP is used only if XTRAN is nonzero. GTAP = 1.0 by default.

    STAT: integer;
    // Initial machine status of one for in-service and zero for out-of-service;
    // STAT = 1 by default.

    RMPCT: double;
    // Percent of the total Mvar required to hold the voltage at te bus controlled by
    // bus I that are not contributed by the generation at bus I; RMPCT must be positive.
    // RMPCT is needed only if IREG specifies a valid remote bus and there are more than one
    // local ore remoting controlling device ( plant, switched shunt, FACTS device shunt element,
    // or VSC dc line converter) controlling the voltage at bus IREG to a setpoint, or IREG is
    // zero but bus I is controlled bus, lcal or remote, of one or more other setpoint voltage
    // controlling devices. RMCPT = 100.0 by default.

    PT: double; // Maximum generator active power output; entered in MW. PT = 9999.0 by default.

    PB: double;
    // Minimum generator active power output; entered in MW. PB = -9999.0 by default.

    O_: array[1..4] of integer;
    // Owner Number. ( 1 trought the maximum number of owners at the current size level);
    // Each machine may have up to four owners. By default, O1 is the owner to wich bus "I" is assigned
    // and O2, O3 and O4 are zero.

    F_: array[1..4] of double;
    // F_[i] is the fractional of total ownership assigned to the owner O_[i];
    // Each F_[i] must be positive. Th F_[i] values are normalized such that they sum to 1.0 before they are
    // placed in the working case. By default, each F_[i] = 1.0.


          (*
        0: NO WINDMACHINE
        1: WindMachine con límites de reactiva especificada por QT y QB
        2: WindMachine con límites de reactiva iguales y de magnitudes opuestas, determinados por la potencia ACTIVA y el WPF
        3: WindMachine con límites de reactiva fijos. Si WPF > 0 entonces la reactiva de la máquina tiene el mismo signo que la activa.
          Si WPF < 0 entonces la reactiva tiene signo contrario a la activa.

       WindPowerFactor. POr defecto 1. Determina los límites de reactiva según WMOD = 2 o 3.
      *)
    WMOD: integer;
    WPF:  NReal;


    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);
    procedure cargue; override;

  end;

  TRaw_Branch = class(TActorBiBarra)

    // 4.1.1.5  Nontransformer Branch Data

    // Each ac network branch to be represented in PSS/E as a nontransformer branch is introduced by
    // reading a nontransformer branch data record. (Data records for transformers are entered in the trans-
    // former data category described in Section 4.1.1.6.) Each nontransformer branch data record has the
    // following format:
    //           I,J,CKT,R,X,B,RATEA,RATEB,RATEC,GI,BI,GJ,BJ,ST,LEN,O1,F1,...,O4,F4
    // where:


//    I: longint;    // Branch "from bus" number, or extended bus name enclosed in single quotes
//    J: longint;
    // Branch "to bus" number, or extended bus name enclosed in single quotes (see
    // Section 4.1.2). J is entered as a negative number, or with a minus sign before the
    // first character of the extended bus name, to designate it as the metered end; other-
    // wise, bus I is assumed to be the metered end.


    CKT: string;
    // One- or two-character uppercase nonblank alphanumeric branch circuit identifier;
    // the first character of CKT must not be an ampersand ("&"); see Section 4.1.1.13.
    // It is recommended that single circuit branches be designated as having the circuit
    // identifier ’1’. CKT = ’1’ by default.
    RR:  double;
    // Branch resistance; entered in pu. A value of R must be entered for each branch.

    X: double;
    // Branch reactance; entered in pu. A nonzero value of X must be entered for each
    // branch. See Section 4.1.4 for details on the treatment of branches as zero impedance lines.

    B: double;         // Total branch charging susceptance; entered in pu. B = 0.0 by default.

    RATEA: double;
    // First current rating; entered in MVA. RATEA = 0.0 (bypass check for this branch)
    // by default. See also Section 4.53.
    RATEB: double;     // Second current rating; entered in MVA. RATEB = 0.0 by default.

    RATEC: double;     //  Third current rating; entered in MVA. RATEC = 0.0 by default.

    RATIO: double;     //  Transformer off-nominal ratio, entered in pu. RATIO is
    //  entered as 0 if the branch is not a transformer. RATIO=0 by default.

    ANGLE: double;

    GI, BI: double;
    // Complex admittance of the line shunt at the bus "I" end of the branch; entered in
    // pu. BI is negative for a line connected reactor. GI + jBI = 0.0 by default.

    GJ, BJ: double;
    // Complex admittance of the line shunt at the bus "J" end of the branch; entered in
    // pu. BJ is negative for a line connected reactor. GJ + jBJ = 0.0 by default.

    ST: integer;
    // Initial branch status where 1 designates in-service and 0 designates out-of-service.
    //ST = 1 by default.


    // dsde VER 32
    MET: integer;
    // Metered end flag;
    // <= 1 to designate bus I as the metered end
    // >= 2 to designate bus J as the metered end
    // MET = 1 by default

    LEN: double;        // Line length; entered in user-selected units. LEN = 0.0 by default.

    O_: array[1..4] of integer;
    // Owner number (1 through the maximum number of owners at the current size level;
    // see Table P-1). Each branch may have up to four owners. By default, O1 is the owner
    // to which bus "I" is assigned (see Section 4.1.1.2) and O2, O3, and O4 are zero.

    F_: array[1..4] of double;
    // Fi Fraction of total ownership assigned to owner Oi; each Fi must be positive. The Fi
    // values are normalized such that they sum to 1.0 before they are placed in the
    //working case. By default, each Fi is 1.0.

    // When specifying a nontransformer branch between buses I and J with circuit identifier CKT, if a
    // two-winding transformer between buses I and J with a circuit identifier of CKT is already present
    // in the working case, it is replaced (i.e., the transformer is deleted from the working case and the
    // newly specified branch is then added to the working case).
    // Note again that branches to be modeled as transformers are not specified in this data category;
    // rather, they are specified in the transformer data category described in Section 4.1.1.6.
    // Nontransformer branch data input is terminated with a record specifying a "from bus" number of zero.


    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);
    procedure cargue; override;
    procedure Calculo_potencias(var S12, S21, Sconsumida, I: NComplex);
    //function PotenciaJ();
  end;
  TRaw_Branch_Impedancia_cero = class(TRaw_Branch)

    //ST: integer;
    // Initial branch status where 1 designates in-service and 0 designates out-of-service.
    //ST = 1 by default.

    //procedure cargue; override;
    //procedure Calculo_potencias(var S12, S21, Sconsumida, I: NComplex);
  end;

  TRaw_Transformer = class(Tactorbibarra)

    //   Each ac transformer to be represented in PSS®E is introduced through transformer data record
    //blocks that specify all the data required to model transformers in power flow calculations, with one
    //exception. That exception is an optional set of ancillary data, transformer impedance correction
    //tables, which define the manner in which transformer impedance changes as off-nominal turns ratio
    //or phase shift angle is adjusted. Those data records are described in Transformer Impedance
    //Correction Tables.
    //Both two-winding and three-winding transformers are specified in transformer data record blocks.
    //Two-winding transformers require a block of four data records. Three-winding transformers require
    //five data records.
    //t1:
    //t2:
    //t = t1 / t2; transformer turns ratio
    //winding 1 turns ratio in kV or pu on bus voltage base or winding
    //voltage base
    //winding 2 turns ratio in kV or pu on bus voltage base or winding
    //voltage base
    // The five record transformer data block for three-winding transformers has the following format:
    // I,J,K,CKT,CW,CZ,CM,MAG1,MAG2,NMETR,’NAME’,STAT,O1,F1,...,O4,F4
    // R1-2,X1-2,SBASE1-2,R2-3,X2-3,SBASE2-3,R3-1,X3-1,SBASE3-1,VMSTAR,ANSTAR
    // WINDV1,NOMV1,ANG1,RATA1,RATB1,RATC1,COD1,CONT1,RMA1,RMI1,VMA1,VMI1,NTP1,TAB1,CR1,CX1
    // WINDV2,NOMV2,ANG2,RATA2,RATB2,RATC2,COD2,CONT2,RMA2,RMI2,VMA2,VMI2,NTP2,TAB2,CR2,CX2
    // WINDV3,NOMV3,ANG3,RATA3,RATB3,RATC3,COD3,CONT3,RMA3,RMI3,VMA3,VMI3,NTP3,TAB3,CR3,CX3
    //The four-record transformer data block for two-winding transformers is a subset of the data required
    //for three-winding transformers and has the following format:
    // I,J,K,CKT,CW,CZ,CM,MAG1,MAG2,NMETR,’NAME’,STAT,O1,F1,...,O4,F4
    // R1-2,X1-2,SBASE1-2
    // WINDV1,NOMV1,ANG1,RATA1,RATB1,RATC1,COD1,CONT1,RMA1,RMI1,VMA1,VMI1,NTP1,TAB1,CR1,CX1
    // WINDV2,NOMV2
    //Control parameters for the automatic adjustment of transformers and phase shifters are specified
    //on the third record of the two-winding transformer data block, and on the third through fifth records
    //of the three-winding transformer data block. All transformers are adjustable and the control param-eters may be specified either at the time of raw data input or subsequently via activity CHNG or the
    //transformer [Spreadsheets]. Any two-winding transformer and any three-winding transformer winding
    //for which no control data is provided has default data assigned to it; the default data is such that the
    //two-winding transformer or three-winding transformer winding is treated as locked.
    //Refer to Transformer Sequence Numbers and Three-Winding Transformer Notes for additional
    //details on the three-winding transformer model used in PSS®E.
    //When specifying a two-winding transformer between buses I and J with circuit identifier CKT, if a
    //nontransformer branch between buses I and J with a circuit identifier of CKT is already present in
    //the working case, it is replaced (i.e., the nontransformer branch is deleted from the working case
    //and the newly specified two-winding transformer is then added to the working case).
    //All data items on the first record are specified for both two- and three-winding transformers:
    //I The bus number, or extended bus name enclosed in single quotes (refer to
    //Extended Bus Names), of the bus to which Winding 1 is connected. The trans-
    //former’s magnetizing admittance is modeled on Winding 1. Winding 1 is the only
    //winding of a two-winding transformer for which tap ratio or phase shift angle may be
    //adjusted by the power flow solution activities; any winding(s) of a three-winding
    //transformer may be adjusted. No default is allowed.
    //J The bus number, or extended bus name enclosed in single quotes, of the bus to
    //which Winding 2 is connected. No default is allowed.
    //K The bus number, or extended bus name enclosed in single quotes, of the bus to
    //which Winding 3 is connected. Zero is used to indicate that no third winding is
    //present (i.e., that a two-winding rather than a three-winding transformer is being
    //specified). K = 0 by default.
    //CKT One- or two-character uppercase non-blank alphanumeric transformer circuit identi-
    //fier; the first character of CKT must not be an ampersand ( & ), at sign ( @ ), or
    //asterisk (  ); refer to Multi-Section Line Grouping Data and Section 6.13.2, Outage
    //Statistics Data File Contents. CKT = 1 by default.
    //CW The winding data I/O code that defines the units in which the turns ratios WINDV1,
    //WINDV2 and WINDV3 are specified (the units of RMAn and RMIn are also
    //governed by CW when |CODn| is 1 or 2):
    //1  for off-nominal turns ratio in pu of winding bus base voltage
    //2  for winding voltage in kV
    //3  for off-nominal turns ratio in pu of nominal winding voltage,
    // NOMV1, NOMV2 and NOMV3.
    //CW = 1 by default.
    //CZ The impedance data I/O code that defines the units in which the winding imped-
    //ances R1-2, X1-2, R2-3, X2-3, R3-1 and X3-1 are specified:
    //1  for resistance and reactance in pu on system MVA base and
    // winding voltage base
    //2  for resistance and reactance in pu on a specified MVA base and
    // winding voltage base
    //3  for transformer load loss in watts and impedance magnitude in pu
    // on a specified MVA base and winding voltage base.
    //In specifying transformer leakage impedances, the base voltage values are always
    //the nominal winding voltages that are specified on the third, fourth and fifth records
    //of the transformer data block (NOMV1, NOMV2 and NOMV3). If the default NOMVn
    //is specified, it is assumed to be identical to the winding n bus base voltage.
    //CZ = 1 by default.
    //All data items on the first record are specified for both two- and three-winding transformers:


    I:     longint;
    //The bus number, or extended bus name enclosed in single quotes (refer to
    //Extended Bus Names), of the bus to which Winding 1 is connected. The trans-
    //former’s magnetizing admittance is modeled on Winding 1. Winding 1 is the only
    //winding of a two-winding transformer for which tap ratio or phase shift angle may be
    //adjusted by the power flow solution activities; any winding(s) of a three-winding
    //transformer may be adjusted. No default is allowed.
    J:     longint;
    //The bus number, or extended bus name enclosed in single quotes, of the bus to
    //which Winding 2 is connected. No default is allowed.
    K:     longint;
    //The bus number, or extended bus name enclosed in single quotes, of the bus to
    //which Winding 3 is connected. Zero is used to indicate that no third winding is
    //present (i.e., that a two-winding rather than a three-winding transformer is being
    //specified). K = 0 by default.
    CKT:   string;
    //One- or two-character uppercase non-blank alphanumeric transformer circuit identi-
    //fier; the first character of CKT must not be an ampersand ( & ), at sign ( @ ), or
    //asterisk (  ); refer to Multi-Section Line Grouping Data and Section 6.13.2, Outage
    //Statistics Data File Contents. CKT = 1 by default.
    CW:    longint;
    //The winding data I/O code that defines the units in which the turns ratios WINDV1,
    //WINDV2 and WINDV3 are specified (the units of RMAn and RMIn are also
    //governed by CW when |CODn| is 1 or 2):
    //1  for off-nominal turns ratio in pu of winding bus base voltage
    //2  for winding voltage in kV
    //3  for off-nominal turns ratio in pu of nominal winding voltage,
    // NOMV1, NOMV2 and NOMV3.
    //CW = 1 by default.
    CZ:    longint;
    //The impedance data I/O code that defines the units in which the winding imped-
    //ances R1-2, X1-2, R2-3, X2-3, R3-1 and X3-1 are specified:
    //1  for resistance and reactance in pu on system MVA base and
    // winding voltage base
    //2  for resistance and reactance in pu on a specified MVA base and
    // winding voltage base
    //3  for transformer load loss in watts and impedance magnitude in pu
    // on a specified MVA base and winding voltage base.
    //In specifying transformer leakage impedances, the base voltage values are always
    //the nominal winding voltages that are specified on the third, fourth and fifth records
    //of the transformer data block (NOMV1, NOMV2 and NOMV3). If the default NOMVn
    //is specified, it is assumed to be identical to the winding n bus base voltage.
    //CZ = 1 by default.
    CM:    longint;
    //The magnetizing admittance I/O code that defines the units in which MAG1 and
    //MAG2 are specified:
    //1  for complex admittance in pu on system MVA base and Winding 1
    // bus voltage base
    //2  for no load loss in watts and exciting current in pu on Winding 1 to
    // two MVA base (SBASE1-2) and nominal Winding 1 voltage, NOMV1.
    //CM = 1 by default.
    MAG1, MAG2: double;
    //The transformer magnetizing admittance connected to ground at bus I.
    //When CM is 1, MAG1 and MAG2 are the magnetizing conductance and suscep-
    //tance, respectively, in pu on system MVA base and Winding 1 bus voltage base.
    //When a non-zero MAG2 is specified, it should be entered as a negative quantity.
    //When CM is 2, MAG1 is the no load loss in watts and MAG2 is the exciting current
    //in pu on Winding 1 to two MVA base (SBASE1-2) and nominal Winding 1 voltage
    //(NOMV1). For three-phase transformers or three-phase banks of single phase
    //transformers, MAG1 should specify the three-phase no-load loss. When a non-zero
    //MAG2 is specified, it should be entered as a positive quantity.
    //MAG1 = 0.0 and MAG2 = 0.0 by default.
    NMETR: longint;
    //The nonmetered end code of either 1 (for the Winding 1 bus) or 2 (for the Winding 2
    //bus). In addition, for a three-winding transformer, 3 (for the Winding 3 bus) is a valid
    //specification of NMETR. NMETR = 2 by default.
    NAMECKT: string;
    //Alphanumeric identifier assigned to the transformer. NAME may be up to twelve
    //characters and may contain any combination of blanks, uppercase letters, numbers
    //and special characters. NAME must be enclosed in single or double quotes if it
    //contains any blanks or special characters. NAME is twelve blanks by default.
    STAT:  longint;
    //Transformer status of one for in-service and zero for out-of-service.
    //In addition, for a three-winding transformer, the following values of STAT provide for
    //one winding out-of-service with the remaining windings in-service:
    //2  for only Winding 2 out-of-service
    //3  for only Winding 3 out-of-service
    //4  for only Winding 1 out-of-service
    //STAT = 1 by default.
    O_:    array[1..4] of integer;
    //An owner number (1 through 9999). Each transformer may have up to four owners.
    //By default, O1 is the owner to which bus I is assigned and O2, O3, and O4 are zero.
    F_:    array[1..4] of double;
    //The fraction of total ownership assigned to owner Oi; each Fi must be positive. The
    //Fi values are normalized such that they sum to 1.0 before they are placed in the
    //working case. By default, each Fi is 1.0.
    //The first three data items on the second record are read for both two- and three-winding trans-
    //formers; the remaining data items are used only for three-winding transformers:
    R1_2, X1_2: double;
    //The measured impedance of the transformer between the buses to which its first
    //and second windings are connected.
    //When CZ is 1, they are the resistance and reactance, respectively, in pu on system
    //MVA base and winding voltage base.
    //When CZ is 2, they are the resistance and reactance, respectively, in pu on Winding
    //1 to 2 MVA base (SBASE1-2) and winding voltage base.
    //When CZ is 3, R1-2 is the load loss in watts, and X1-2 is the impedance magnitude
    //in pu on Winding 1 to 2 MVA base (SBASE1-2) and winding voltage base. For
    //three-phase transformers or three-phase banks of single phase transformers, R1-2
    //should specify the three-phase load loss.
    //R1-2 = 0.0 by default, but no default is allowed for X1-2.
    SBASE1_2: double;
    //The Winding 1 to 2 three-phase base MVA of the transformer. SBASE1-2 = SBASE
    //(the system base MVA) by default.
    R2_3, X2_3: double;
    //The measured impedance of a three-winding transformer between the buses to
    //which its second and third windings are connected; ignored for a two-winding
    //transformer.
    //When CZ is 1, they are the resistance and reactance, respectively, in pu on system
    //MVA base and winding voltage base.
    //When CZ is 2, they are the resistance and reactance, respectively, in pu on Winding
    //2 to 3 MVA base (SBASE2-3) and winding voltage base.
    //When CZ is 3, R2-3 is the load loss in watts, and X2-3 is the impedance magnitude
    //in pu on Winding 2 to 3 MVA base (SBASE2-3) and winding voltage base. For
    //three-phase transformers or three-phase banks of single phase transformers, R2-3
    //should specify the three-phase load loss.
    //R2-3 = 0.0 by default, but no default is allowed for X2-3.

    SBASE2_3: double;
    //The Winding 2 to 3 three-phase base MVA of a three-winding transformer; ignored
    //for a two-winding transformer. SBASE2-3 = SBASE (the system base MVA) by default.

    R3_1, X3_1: double;
    //The measured impedance of a three-winding transformer between the buses to
    //which its third and first windings are connected; ignored for a two-winding
    //transformer.
    //When CZ is 1, they are the resistance and reactance, respectively, in pu on system
    //MVA base and winding voltage base.
    //When CZ is 2, they are the resistance and reactance, respectively, in pu on Winding
    //3 to 1 MVA base (SBASE3-1) and winding voltage base.
    //When CZ is 3, R3-1 is the load loss in watts, and X3-1 is the impedance magnitude
    //in pu on Winding 3 to 1 MVA base (SBASE3-1) and winding voltage base. For
    //three-phase transformers or three-phase banks of single phase transformers, R3-1
    //should specify the three-phase load loss.
    //R3-1 = 0.0 by default, but no default is allowed for X3-1.

    SBASE3_1: double;
    //The Winding 3 to 1 three-phase base MVA of a three-winding transformer; ignored
    //for a two-winding transformer. SBASE3-1 = SBASE (the system base MVA) by
    //default.
    //All data items on the third record are read for both two- and three-winding transformers:

    VMSTAR: double;
    //The voltage magnitude at the hidden star point bus; entered in pu. VMSTAR = 1.0
    //by default.

    ANSTAR: double;
    //The bus voltage phase angle at the hidden star point bus; entered in degrees.
    //ANSTAR = 0.0 by default.

    WINDV1: double;
    //When CW is 1, WINDV1 is the Winding 1 off-nominal turns ratio in pu of Winding 1
    //bus base voltage; WINDV1 = 1.0 by default.
    //When CW is 2, WINDV1 is the actual Winding 1 voltage in kV; WINDV1 is equal to
    //the base voltage of bus I by default.
    //When CW is 3, WINDV1 is the Winding 1 off-nominal turns ratio in pu of nominal
    //Winding 1 voltage, NOMV1; WINDV1 = 1.0 by default.

    NOMV1: double;
    //The nominal (rated) Winding 1 voltage base in kV, or zero to indicate that nominal
    //Winding 1 voltage is assumed to be identical to the base voltage of bus I. NOMV1 is
    //used in converting magnetizing data between physical units and per unit admittance
    //values when CM is 2. NOMV1 is used in converting tap ratio data between values in
    //per unit of nominal Winding 1 voltage and values in per unit of Winding 1 bus base
    //voltage when CW is 3. NOMV1 = 0.0 by default.

    ANG1: double;
    //The winding one phase shift angle in degrees. For a two-winding transformer,
    //ANG1 is positive when the winding one bus voltage leads the winding two bus
    //voltage; for a three-winding transformer, ANG1 is positive when the winding one
    //bus voltage leads the T (or star) point bus voltage. ANG1 must be greater than -
    //180.0º and less than or equal to +180.0º. ANG1 = 0.0 by default.

    RATA1, RATB1, RATC1: double;
    //Winding 1’s three three-phase ratings, entered in either MVA or current expressed
    //as MVA, according to the value specified for XFRRAT specified on the first data
    //record (refer to Case Identification Data). RATA1 = 0.0, RATB1 = 0.0 and
    //RATC1 = 0.0 (bypass loading limit check for this transformer winding) by default.

    COD1: integer;
    //The transformer control mode for automatic adjustments of the Winding 1 tap or
    //phase shift angle during power flow solutions:
    //0  for no control (fixed tap and fixed phase shift)
    //±1  for voltage control
    //±2  for reactive power flow control
    //±3  for active power flow control
    //±4  for control of a dc line quantity (valid only for two-winding
    // transformers).
    //If the control mode is entered as a positive number, automatic adjustment of this
    //transformer winding is enabled when the corresponding adjustment is activated
    //during power flow solutions; a negative control mode suppresses the automatic
    //adjustment of this transformer winding. COD1 = 0 by default.

    CONT1: integer;
    //The bus number, or extended bus name enclosed in single quotes (refer to
    //Extended Bus Names), of the bus for which voltage is to be controlled by the trans-
    //former turns ratio adjustment option of the power flow solution activities when
    //COD1 is 1. CONT1 should be non-zero only for voltage controlling transformer
    //windings.
    //CONT1 may specify a bus other than I, J, or K; in this case, the sign of CONT1
    //defines the location of the controlled bus relative to the transformer winding. If
    //CONT1 is entered as a positive number, or a quoted extended bus name, the ratio
    //is adjusted as if bus CONT1 is on the Winding 2 or Winding 3 side of the trans-
    //former; if CONT1 is entered as a negative number, or a quoted extended bus name
    //with a minus sign preceding the first character, the ratio is adjusted as if bus
    //|CONT1| is on the Winding 1 side of the transformer. CONT1 = 0 by default.

    RMA1, RMI1: double;
    //When |COD1| is 1, 2 or 3, the upper and lower limits, respectively, of one of the
    //following:
    //• Off-nominal turns ratio in pu of Winding 1 bus base voltage when |COD1| is
    //1 or 2 and CW is 1; RMA1 = 1.1 and RMI1 = 0.9 by default.
    //• Actual Winding 1 voltage in kV when  |COD1| is 1 or 2 and CW is 2. No
    //default is allowed.
    //• Off-nominal turns ratio in pu of nominal Winding 1 voltage (NOMV1) when
    //|COD1| is 1 or 2 and CW is 3; RMA1 = 1.1 and RMI1 = 0.9 by default.
    //• Phase shift angle in degrees when |COD1| is 3. No default is allowed.
    //Not used when |COD1| is 0 or 4; RMA1 = 1.1 and RMI1 = 0.9 by default.

    VMA1, VMI1: double;
    //When |COD1| is 1, 2 or 3, the upper and lower limits, respectively, of one of the
    //following:
    //• Voltage at the controlled bus (bus |CONT1|) in pu when |COD1| is 1.
    //VMA1 = 1.1 and VMI1 = 0.9 by default.
    //• Reactive power flow into the transformer at the Winding 1 bus end in Mvar
    //when |COD1| is 2. No default is allowed.
    //• Active power flow into the transformer at the Winding 1 bus end in MW when
    //|COD1| is 3. No default is allowed.
    //Not used when |COD1| is 0 or 4; VMA1 = 1.1 and VMI1 = 0.9 by default.

    NTP1: integer;
    //The number of tap positions available; used when COD1 is 1 or 2. NTP1 must be
    //between 2 and 9999. NTP1 = 33 by default.

    TAB1: integer;
    //The number of a transformer impedance correction table if this transformer
    //winding’s impedance is to be a function of either off-nominal turns ratio or phase
    //shift angle (refer to Transformer Impedance Correction Tables), or 0 if no trans-
    //former impedance correction is to be applied to this transformer winding. TAB1 = 0
    //by default.

    CR1, CX1: double;
    //The load drop compensation impedance for voltage controlling transformers
    //entered in pu on system base quantities; used when COD1 is 1. CR1 + j CX1 = 0.0
    //by default.
    //The first two data items on the fourth record are read for both two- and three-winding transformers;
    //the remaining data items are used only for three-winding transformers:

    WINDV2:   integer;
    //When CW is 1, WINDV2 is the Winding 2 off-nominal turns ratio in pu of Winding 2
    //bus base voltage; WINDV2 = 1.0 by default.
    //When CW is 2, WINDV2 is the actual Winding 2 voltage in kV; WINDV2 is equal to
    //the base voltage of bus J by default.
    //When CW is 3, WINDV2 is the Winding 2 off-nominal turns ratio in pu of nominal
    //Winding 2 voltage, NOMV2; WINDV2 = 1.0 by default.
    NOMV2:    double;
    //The nominal (rated) Winding 2 voltage base in kV, or zero to indicate that nominal
    //Winding 2 voltage is assumed to be identical to the base voltage of bus J. NOMV2
    //is used in converting tap ratio data between values in per unit of nominal Winding 2
    //voltage and values in per unit of Winding 2 bus base voltage when CW is 3.
    //NOMV2 = 0.0 by default.
    ANG2:     double;
    //The winding two phase shift angle in degrees. ANG2 is ignored for a two-winding
    //transformer. For a three-winding transformer, ANG2 is positive when the winding
    //two bus voltage leads the T (or star) point bus voltage. ANG2 must be greater than
    //-180.0º and less than or equal to +180.0º. ANG2 = 0.0 by default.
    RATA2, RATB2, RATC2: double;
    //Winding 2’s three three-phase ratings, entered in either MVA or current expressed
    //as MVA, according to the value specified for XFRRAT specified on the first data
    //record (refer to Case Identification Data). RATA2 = 0.0, RATB2 = 0.0 and
    //RATC2 = 0.0 (bypass loading limit check for this transformer winding) by default.
    COD2:     integer;
    //The transformer control mode for automatic adjustments of the Winding 2 tap or
    //phase shift angle during power flow solutions:
    //0  for no control (fixed tap and fixed phase shift)
    //±1  for voltage control
    //±2  for reactive power flow control
    //±3  for active power flow control.
    //If the control mode is entered as a positive number, automatic adjustment of this
    //transformer winding is enabled when the corresponding adjustment is activated
    //during power flow solutions; a negative control mode suppresses the automatic
    //adjustment of this transformer winding. COD2 = 0 by default.
    CONT2:    integer;
    //The bus number, or extended bus name enclosed in single quotes (refer to
    //Extended Bus Names), of the bus for which voltage is to be controlled by the trans-
    //former turns ratio adjustment option of the power flow solution activities when
    //COD2 is 1. CONT2 should be non-zero only for voltage controlling transformer
    //windings.
    //CONT2 may specify a bus other than I, J, or K; in this case, the sign of CONT2
    //defines the location of the controlled bus relative to the transformer winding. If
    //CONT2 is entered as a positive number, or a quoted extended bus name, the ratio
    //is adjusted as if bus CONT2 is on the Winding 1 or Winding 3 side of the trans-
    //former; if CONT2 is entered as a negative number, or a quoted extended bus name
    //with a minus sign preceding the first character, the ratio is adjusted as if bus
    //|CONT2| is on the Winding 2 side of the transformer. CONT2 = 0 by default.
    //The fifth data record is specified only for three-winding transformers:
    RMA2, RMI2: double;
    //When |COD2| is 1, 2 or 3, the upper and lower limits, respectively, of one of the
    //following:
    //• Off-nominal turns ratio in pu of Winding 2 bus base voltage when |COD2| is
    //1 or 2 and CW is 1; RMA2 = 1.1 and RMI2 = 0.9 by default.
    //• Actual Winding 2 voltage in kV when |COD2| is 1 or 2 and CW is 2. No default
    //is allowed.
    //• Off-nominal turns ratio in pu of nominal Winding 2 voltage (NOMV2) when
    //|COD2| is 1 or 2 and CW is 3; RMA2 = 1.1 and RMI2 = 0.9 by default.
    //• Phase shift angle in degrees when |COD2| is 3. No default is allowed.
    //Not used when |COD2| is 0; RMA2 = 1.1 and RMI2 = 0.9 by default.
    VMA2, VMI2: double;
    //When |COD2| is 1, 2 or 3, the upper and lower limits, respectively, of one of the
    //following:
    //• Voltage at the controlled bus (bus  |CONT2|) in pu when |COD2| is 1.
    //VMA2 = 1.1 and VMI2 = 0.9 by default.
    //• Reactive power flow into the transformer at the Winding 2 bus end in Mvar
    //when |COD2| is 2. No default is allowed.
    //• Active power flow into the transformer at the Winding 2 bus end in MW when
    //|COD2| is 3. No default is allowed.
    //Not used when |COD2| is 0; VMA2 = 1.1 and VMI2 = 0.9 by default.
    NTP2:     integer;
    //The number of tap positions available; used when COD2 is 1 or 2. NTP2 must be
    //between 2 and 9999. NTP2 = 33 by default.
    TAB2:     integer;
    //The number of a transformer impedance correction table if this transformer
    //winding’s impedance is to be a function of either off-nominal turns ratio or phase
    //shift angle (refer to Transformer Impedance Correction Tables), or 0 if no trans-
    //former impedance correction is to be applied to this transformer winding. TAB2 = 0
    //by default.
    CR2, CX2: double;
    //The load drop compensation impedance for voltage controlling transformers
    //entered in pu on system base quantities; used when COD2 is 1. CR2 + j CX2 = 0.0
    //by default.
    WINDV3:   integer;
    //When CW is 1, WINDV3 is the Winding 3 off-nominal turns ratio in pu of Winding 3
    //bus base voltage; WINDV3 = 1.0 by default.
    //When CW is 2, WINDV3 is the actual Winding 3 voltage in kV; WINDV3 is equal to
    //the base voltage of bus K by default.
    //When CW is 3, WINDV3 is the Winding 3 off-nominal turns ratio in pu of nominal
    //Winding 3 voltage, NOMV3; WINDV3 = 1.0 by default.
    NOMV3:    double;
    //The nominal (rated) Winding 3 voltage base in kV, or zero to indicate that nominal
    //Winding 3 voltage is assumed to be identical to the base voltage of bus K. NOMV3
    //is used in converting tap ratio data between values in per unit of nominal Winding 3
    //voltage and values in per unit of Winding 3 bus base voltage when CW is 3. NOMV3
    //= 0.0 by default.
    ANG3:     double;
    //The winding three phase shift angle in degrees. ANG3 is positive when the winding
    //three bus voltage leads the T (or star) point bus voltage. ANG3 must be greater
    //than -180.0º and less than or equal to +180.0º. ANG3 = 0.0 by default.
    RATA3, RATB3, RATC3: double;
    //Winding 3’s three three-phase ratings, entered in either MVA or current expressed
    //as MVA, according to the value specified for XFRRAT specified on the first data
    //record (refer to Case Identification Data). RATA3 = 0.0, RATB3 = 0.0 and
    //RATC3 = 0.0 (bypass loading limit check for this transformer winding) by default.
    COD3:     integer;
    //The transformer control mode for automatic adjustments of the Winding 3 tap or
    //phase shift angle during power flow solutions:
    //0  for no control (fixed tap and fixed phase shift)
    //±1  for voltage control
    //±2  for reactive power flow control
    //±3  for active power flow control.
    //If the control mode is entered as a positive number, automatic adjustment of this
    //transformer winding is enabled when the corresponding adjustment is activated
    //during power flow solutions; a negative control mode suppresses the automatic
    //adjustment of this transformer winding. COD3 = 0 by default.
    CONT3:    integer;
    //The bus number, or extended bus name enclosed in single quotes (refer to
    //Extended Bus Names), of the bus for which voltage is to be controlled by the trans-
    //former turns ratio adjustment option of the power flow solution activities when
    //COD3 is 1. CONT3 should be non-zero only for voltage controlling transformer
    //windings.
    //CONT3 may specify a bus other than I, J, or K; in this case, the sign of CONT3
    //defines the location of the controlled bus relative to the transformer winding. If
    //CONT3 is entered as a positive number, or a quoted extended bus name, the ratio
    //is adjusted as if bus CONT3 is on the Winding 1 or Winding 2 side of the trans-
    //former; if CONT3 is entered as a negative number, or a quoted extended bus name
    //with a minus sign preceding the first character, the ratio is adjusted as if bus
    //|CONT3| is on the Winding 3 side of the transformer. CONT3 = 0 by default.
    RMA3, RMI3: double;
    //When |COD3| is 1, 2 or 3, the upper and lower limits, respectively, of one of the
    //following:
    //• Off-nominal turns ratio in pu of Winding 3 bus base voltage when |COD3| is
    //1 or 2 and CW is 1; RMA3 = 1.1 and RMI3 = 0.9 by default.
    //• Actual Winding 3 voltage in kV when |COD3| is 1 or 2 and CW is 2. No default
    //is allowed.
    //• Off-nominal turns ratio in pu of nominal Winding 3 voltage (NOMV3) when
    //|COD3| is 1 or 2 and CW is 3; RMA3 = 1.1 and RMI3 = 0.9 by default.
    //• Phase shift angle in degrees when |COD3| is 3. No default is allowed.
    //Not used when |COD3| is 0; RMA3 = 1.1 and RMI3 = 0.9 by default.
    //Transformer data input is terminated with a record specifying a Winding 1 bus number of zero.
    //Three-Winding Transformer Notes
    //The transformer data record blocks described in Transformer Data provide for the specification of
    //both two-winding transformers and three-winding transformers. A three-winding transformer is
    //modeled in PSS®E as a grouping of three two-winding transformers, where each of these two-
    //winding transformers models one of the windings. While most of the three-winding transformer data
    //is stored in the two-winding transformer data arrays, it is accessible for reporting and modification
    //only as three-winding transformer data.
    //In deriving winding impedances from the measured impedance data input values, one winding with
    //a small impedance, in many cases negative, often results. In the extreme case, it is possible to
    //specify a set of measured impedances that themselves do not individually appear to challenge the
    //precision limits of typical power system calculations, but which result in one winding impedance of
    //nearly (or identically) 0.0. Such data could result in precision difficulties, and hence inaccurate
    //results, when processing the system matrices in power flow and short circuit calculations.
    //Whenever a set of measured impedance results in a winding reactance that is identically 0.0, a
    //warning message is printed by the three-winding transformer data input or data changing function,
    //and the winding’s reactance is set to the zero impedance line threshold tolerance (or to 0.0001 if
    //the zero impedance line threshold tolerance itself is 0.0). Whenever a set of measured impedances
    //results in a winding impedance for which magnitude is less than 0.00001, a warning message is
    //printed. As with all warning and error messages produced during data input and data modification
    //phases of PSS®E, the user should resolve the cause of the message (e.g., was correct input data
    //specified?) and use engineering judgement to resolve modeling issues (e.g., is this the best way to
    //model this transformer or would some other modeling be more appropriate?).
    VMA3, VMI3: double;
    //When |COD3| is 1, 2 or 3, the upper and lower limits, respectively, of one of the
    //following:
    //• Voltage at the controlled bus (bus  |CONT3|) in pu when |COD3| is 1.
    //VMA3 = 1.1 and VMI3 = 0.9 by default.
    //• Reactive power flow into the transformer at the Winding 3 bus end in Mvar
    //when |COD3| is 2. No default is allowed.
    //• Active power flow into the transformer at the Winding 3 bus end in MW when
    //|COD3| is 3. No default is allowed.
    //Not used when |COD3| is 0; VMA3 = 1.1 and VMI3 = 0.9 by default.
    NTP3:     integer;
    //The number of tap positions available; used when COD3 is 1 or 2. NTP3 must be
    //between 2 and 9999. NTP3 = 33 by default.
    TAB3:     integer;
    //The number of a transformer impedance correction table if this transformer
    //winding’s impedance is to be a function of either off-nominal turns ratio or phase
    //shift angle (refer to Transformer Impedance Correction Tables), or 0 if no trans-
    //former impedance correction is to be applied to this transformer winding. TAB3 = 0
    //by default.
    CR3, CX3: double;
    //The load drop compensation impedance for voltage controlling transformers
    //entered in pu on system base quantities; used when COD3 is 1. CR3 + j CX3 = 0.0
    //by default.
    //Activity BRCH may be used to detect the presence of branch reactance magnitudes less than a
    //user-specified threshold tolerance; its use is always recommended whenever the user begins
    //power system analysis work using a new or modified system model.
    //Example Two-Winding Transformer Data Records
    //Figure 5-10 shows the data records for a 50 MVA, 138/34.5 kV two-winding transformer connected
    //to system buses with nominal voltages of 134 kV and 34.5 kV, and sample data on 100 MVA system
    //base and winding voltage bases of 134 kV and 34.5 kV.

    //Figure 5-10.  Sample Data for Two-Winding Transformer
    //I, J, K, CKT, CW, CZ, CM, MAG1, MAG2, NMETR, ’NAME’, STAT, O1, F1, ..., O4, F4
    //R1-2, X1-2, SBASE1-2
    //WINDV1, NOMV1, ANG1, RATA1, RATB1, RATC1, COD1, CONT1, RMA1, RMI1, VMA1, VMI1
    //NTP1, TAB1, CR1, CX1
    //WINDV2, NOMV2
    //t1 : t2
    //Example Three-Winding Transformer Data Records
    //Figure 5-11 shows the data records for a 300 MVA, 345/138/13.8 kV three-winding transformer
    //connected to system buses with nominal voltages of 345 kV, 138 kV and 13.8 kV, respectively, and
    //sample data on 100 MVA system base and winding base voltages of 345 kV, 138 kV and 13.8 kV.
    //Figure 5-11.  Sample Data for Three-Winding Transformer
    //Adjustable tap
    //on winding 2
    //Adjustable tap
    //on winding 3
    //I, J, K, CKT, CW, CZ, CM, MAG1, MAG2, NMETR, ’NAME’, STAT, O1, F1, ..., O4, F4
    //R1-2, X1-2, SBASE1-2, R2-3, X2-3, SBASE2-3, R3-1, X3-1, SBASE3-1, VMSTAR, ANSTAR
    //WINDV1, NOMV1, ANG1, RATA1, RATB1, RATC1, COD1, CONT1, RMA1, RMI1, VMA1, VMI1,
    //NTP1, TAB1, CR1, CX1
    //WINDV2, NOMV2, ANG2, RATA2, RATB2, RATC2, COD2, CONT2, RMA2, RMI2, VMA2, VMI2,
    //NTP2, TAB2, CR2, CX2
    //WINDV3, NOMV3, ANG3, RATA3, RATB3, RATC3, COD3, CONT3, RMA3, RMI3, VMA3, VMI3,
    //NTP3, TAB3, CR3, CX3
    //t1 t2
    //t3


  end;


  TRaw_TransformerAdjust = class(TactorTriBarra)

    // 4.1.1.6  Transformer Data

    // Each ac transformer to be represented in PSS/E is introduced by reading a transformer data record
    // block. Transformer data record blocks specify all the data needed to model transformers in power
    // flow calculations. Both two-winding transformers and three-winding transformers are specified in
    // transformer data record blocks; two-winding transformers require a block of four data records, and
    // three-winding transformers require five data records.

    // The five record transformer data block for three-winding transformers has the following format:
    //     I,J,K,CKT,CW,CZ,CM,MAG1,MAG2,NMETR,’NAME’,STAT,O1,F1,...,O4,F4
    //     R1-2,X1-2,SBASE1-2,R2-3,X2-3,SBASE2-3,R3-1,X3-1,SBASE3-1,VMSTAR,ANSTAR
    //     WINDV1,NOMV1,ANG1,RATA1,RATB1,RATC1,COD1,CONT1,RMA1,RMI1,VMA1,VMI1,NTP1,TAB1,CR1,CX1
    //     WINDV2,NOMV2,ANG2,RATA2,RATB2,RATC2,COD2,CONT2,RMA2,RMI2,VMA2,VMI2,NTP2,TAB2,CR2,CX2
    //     WINDV3,NOMV3,ANG3,RATA3,RATB3,RATC3,COD3,CONT3,RMA3,RMI3,VMA3,VMI3,NTP3,TAB3,CR3,CX3
    // The four-record transformer data block for two-winding transformers is a subset of the data required
    // for three-winding transformers and has the following format:
    //     I,J,K,CKT,CW,CZ,CM,MAG1,MAG2,NMETR,’NAME’,STAT,O1,F1,...,O4,F4
    //     R1-2,X1-2,SBASE1-2
    //     WINDV1,NOMV1,ANG1,RATA1,RATB1,RATC1,COD1,CONT1,RMA1,RMI1,VMA1,VMI1,NTP1,TAB1,CR1,CX1
    //     WINDV2,NOMV2
    // Control parameters for the automatic adjustment of transformers and phase shifters are specified on
    // the third record of the two-winding transformer data block, and on the third through fifth records of
    // the three-winding transformer data block. All transformers are adjustable and the control parame-
    // ters may be specified either at the time of raw data input or subsequently via activities CHNG or
    // XLIS, or the data editor windows. Any two-winding transformer and any three-winding transformer
    // winding for which no control data is provided has default data assigned to it; the default data is such
    // that the two-winding transformer or three-winding transformer winding is treated as fixed.
    // See Section 4.1.2.6 and 4.1.5 for further details on the three-winding transformer model used in
    // PSS/E.
    // All data items on the first record are specified for both two- and three-winding transformers:

//    I: longint;  // The bus number, or extended bus name enclosed in single quotes (see
    // Section 4.1.2), of the bus to which the first winding is connected. The trans-
    // former’s magnetizing admittance is modeled on winding one. The first
    // winding is the only winding of a two-winding transformer whose tap ratio or
    // phase shift angle may be adjusted by the power flow solution activities; any
    // winding(s) of a three-winding transformer may be adjusted. No default is
    // allowed.

//    J: longint;  // The bus number, or extended bus name enclosed in single quotes (see
    // Section 4.1.2), of the bus to which the second winding is connected. No default
    // is allowed.

//    K: longint;  // The bus number, or extended bus name enclosed in single quotes (see
    // Section 4.1.2), of the bus to which the third winding is connected. Zero is used
    // to indicate that no third winding is present (i.e., that a two-winding rather than
    // a three-winding transformer is being specified). K = 0 by default.


    CKT: string;// One- or two-character uppercase nonblank alphanumeric transformer circuit
    // identifier; the first character of CKT must not be an ampersand ("&"); see
    // Section 4.1.1.13. CKT = ’1’ by default.

    CW: integer; // The winding data I/O code which defines the units in which WINDV1,
    // WINDV2 and WINDV3 are specified (the units of RMAn and RMIn are also
    // governed by CW when |CODn| is 1 or 2): 1 for off-nominal turns ratio in pu of
    // winding bus base voltage; 2 for winding voltage in kV. CW = 1 by default.

    CZ: integer;
    // The impedance data I/O code that defines the units in which R1-2, X1-2, R2-3,
    // X2-3, R3-1 and X3-1 are specified: 1 for resistance and reactance in pu on
    // system base quantities; 2 for resistance and reactance in pu on a specified base
    // MVA and winding base voltage; 3 for transformer load loss in watts and
    // impedance magnitude in pu on a specified base MVA and winding base
    // voltage. CZ = 1 by default.

    CM: integer; // The magnetizing admittance I/O code that defines the units in which MAG1
    // and MAG2 are specified: 1 for complex admittance in pu on system base quan-
    // tities; 2 for no load loss in watts and exciting current in pu on winding one to
    // two base MVA and nominal voltage. CM = 1 by default.

    MAG1, MAG2: double;
    // The magnetizing conductance and susceptance, respectively, in pu on system
    // base quantities when CM is 1; MAG1 is the no load loss in watts and MAG2
    // is the exciting current in pu on winding one to two base MVA (SBASE1-2) and
    // nominal voltage (NOMV1) when CM is 2. MAG1 = 0.0 and MAG2 = 0.0 by
    // default.
    // When CM is 1 and a non-zero MAG2 is specified, MAG2 should be entered as
    // a negative quantity; when CM is 2 and a non-zero MAG2 is specified, MAG2
    // should always be entered as a positive quantity.

    NMETR: integer;
    //  The nonmetered end code of either 1 (for the winding one bus) or 2 (for the
    // winding two bus). In addition, for a three-winding transformer, 3 (for the
    // winding three bus) is a valid specification of NMETR. NMETR = 2 by default.

    Name: string;// An alphanumeric identifier assigned to the transformer. The name may be up
    // to twelve characters and must be enclosed in single quotes. NAME may con-
    // tain any combination of blanks, uppercase letters, numbers and special
    // characters. NAME is twelve blanks by default.

    STAT: integer;
    // The initial transformer status, where 1 designates in-service and 0 designates
    // out-of-service. In addition, for a three-winding transformer, 2 designates that
    // only winding two is out-of-service, 3 indicates that only winding three is out-
    // of-service, and 4 indicates that only winding one is out-of-service, with the
    // remaining windings in-service. STAT = 1 by default.

    Oi_: array[1..4] of integer;
    // An owner number (1 through the maximum number of owners at the current
    // size level; see Table P-1). Each transformer may have up to four owners. By
    // default, O1 is the owner to which bus I is assigned and O2, O3, and O4 are zero.

    Fi_: array[1..4] of double;
    // The fraction of total ownership assigned to owner Oi; each Fi must be positive.
    // The Fi values are normalized such that they sum to 1.0 before they are placed
    // in the working case. By default, each Fi is 1.0.

    // The first three data items on the second record are read for both two- and three-winding transformers;
    // the remaining data items are used only for three-winding transformers:

    R1_2, X1_2: double;
    // The measured impedance of the transformer between the buses to which its
    // first and second windings are connected. When CZ is 1, they are the resistance
    // and reactance, respectively, in pu on system base quantities; when CZ is 2, they
    // are the resistance and reactance, respectively, in pu on winding one to two base
    // MVA (SBASE1-2) and winding one base voltage; when CZ is 3, R1-2 is the
    // load loss in watts, and X1-2 is the impedance magnitude in pu on winding one
    // to two base MVA (SBASE1-2) and winding base voltage. R1-2 = 0.0 by
    // default, but no default is allowed for X1-2.

    SBASE1_2: double;
    // The winding one to two base MVA of the transformer. SBASE1-2 = SBASE
    // (the system base MVA) by default.

    R2_3, X2_3: double;
    // The measured impedance of a three-winding transformer between the buses to
    // which its second and third windings are connected; ignored for a two-winding
    // transformer. When CZ is 1, they are the resistance and reactance, respectively,
    // in pu on system base quantities; when CZ is 2, they are the resistance and reac-
    // tance, respectively, in pu on winding two to three base MVA (SBASE2-3) and
    // winding two base voltage; when CZ is 3, R2-3 is the load loss in watts, and X2-
    // 3 is the impedance magnitude in pu on winding two to three base MVA
    // (SBASE2-3) and winding base voltage. R2-3 = 0.0 by default, but no default
    // is allowed for X2-3.

    SBASE2_3: double;
    // The winding two to three base MVA of a three-winding transformer; ignored
    // for a two-winding transformer. SBASE2-3 = SBASE (the system base MVA)
    // by default.

    R3_1, X3_1: double;
    // The measured impedance of a three-winding transformer between the buses to
    // which its third and first windings are connected; ignored for a two-winding
    // transformer. When CZ is 1, they are the resistance and reactance, respectively,
    // in pu on system base quantities; when CZ is 2, they are the resistance and
    // reactance, respectively, in pu on winding three to one base MVA (SBASE3-1)
    // and winding three base voltage; when CZ is 3, R3-1 is the load loss in watts,
    // and X3-1 is the impedance magnitude in pu on winding three to one base MVA
    // (SBASE3-1) and winding base voltage. R3-1 = 0.0 by default, but no default
    // is allowed for X3-1.

    SBASE3_1: double;
    // The winding three to one base MVA of a three-winding transformer; ignored
    // for a two-winding transformer. SBASE3-1 = SBASE (the system base MVA)
    // by default.

    VMSTAR: double;   // The voltage magnitude at the hidden "star point" bus; entered in pu.
    // VMSTAR = 1.0 by default.

    ANSTAR: double;
    // The bus voltage phase angle at the hidden "star point" bus; entered in degrees.
    // ANSTAR = 0.0 by default.

    // All data items on the third record are read for both two- and three-winding transformers:

    WINDV1: double;
    // The winding one off-nominal turns ratio in pu of winding one bus base voltage
    // when CW is 1; WINDV1 = 1.0 by default. WINDV1 is the actual winding one
    // voltage in kV when CW is 2; WINDV1 is equal to the base voltage of bus I by
    // default.

    NOMV1: double;
    // The nominal (rated) winding one voltage in kV, or zero to indicate that nominal
    // winding one voltage is to be taken as the base voltage of bus I. NOMV1 is used
    // only in converting magnetizing data between per unit admittance values and
    // physical units when CM is 2. NOMV1 = 0.0 by default.

    ANG1: double;
    // The winding one phase shift angle in degrees. ANG1 is positive for a positive
    // phase shift from the winding one side to the winding two side (for a two-
    // winding transformer), or from the winding one side to the "T" (or "star") point
    // bus (for a three-winding transformer). ANG1 must be greater than -180.0 and
    // less than or equal to +180.0. ANG1 = 0.0 by default.

    RATA1, RATB1, RATC1: double;
    // The first winding’s three ratings entered in MVA (not current expressed in
    // MVA). RATA1 = 0.0, RATB1 = 0.0 and RATC1 = 0.0 (bypass flow limit
    // check for this transformer winding) by default.

    COD1: integer;
    // The transformer control mode for automatic adjustments of the winding one
    // tap or phase shift angle during power flow solutions: 0 for no control (fixed tap
    // and phase shift); ±1 for voltage control; ±2 for reactive power flow control; ±3
    // for active power flow control; ±4 for control of a dc line quantity (+4 is valid
    // only for two-winding transformers). If the control mode is entered as a positive
    // number, automatic adjustment of this transformer winding is enabled when the
    // corresponding adjustment is activated during power flow solutions; a negative
    // control mode suppresses the automatic adjustment of this transformer winding.
    // COD1 = 0 by default.

    CONT1: longint;
    // The bus number, or extended bus name enclosed in single quotes (see
    // Section 4.1.2), of the bus whose voltage is to be controlled by the transformer
    // turns ratio adjustment option of the power flow solution activities when COD1
    // is 1. CONT1 should be nonzero only for voltage controlling transformer
    // windings.
    // CONT1 may specify a bus other than I, J, or K; in this case, the sign of CONT1
    // defines the location of the controlled bus relative to the transformer winding.
    // If CONT1 is entered as a positive number, or a quoted extended bus name, the
    // ratio is adjusted as if bus CONT1 is on the winding two or winding three side
    // of the transformer; if CONT1 is entered as a negative number, or a quoted
    // extended bus name with a minus sign preceding the first character, the ratio is
    // adjusted as if bus |CONT1| is on the winding one side of the transformer.
    // CONT1 = 0 by default.

    RMA1, RMI1: double;// The upper and lower limits, respectively, of either:
    // • Off-nominal turns ratio in pu of winding one bus base voltage when
    // |COD1| is 1 or 2 and CW is 1; RMA1 = 1.1 and RMI1 = 0.9 by default.
    // • Actual winding one voltage in kV when |COD1| is 1 or 2 and CW is 2. No
    // default is allowed.
    // • Phase shift angle in degrees when |COD1| is 3. No default is allowed.
    // • Not used when |COD1| is 0 or 4; RMA1 = 1.1 and RMI1 = 0.9 by default.

    VMA1, VMI1: double;// The upper and lower limits, respectively, of either:
    // • Voltage at the controlled bus (bus |CONT1|) in pu when |COD1| is 1.
    // VMA1 = 1.1 and VMI1 = 0.9 by default.
    // • Reactive power flow into the transformer at the winding one bus end in
    // Mvar when |COD1| is 2. No default is allowed.
    // • Active power flow into the transformer at the winding one bus end in MW
    // when |COD1| is 3. No default is allowed.
    // • Not used when |COD1| is 0 or 4; VMA1 = 1.1 and VMI1 = 0.9 by default.

    NTP1: integer;
    // The number of tap positions available; used when COD1 is 1 or 2. NTP1 must be
    // between 2 and 9999. NTP1 = 33 by default.

    TAB1: integer;
    // The number of a transformer impedance correction table if this transformer
    // winding’s impedance is to be a function of either off-nominal turns ratio or
    // phase shift angle (see Section 4.1.1.11), or 0 if no transformer impedance cor-
    // rection is to be applied to this transformer winding. TAB1 = 0 by default.

    CR1, CX1: double;
    // The load drop compensation impedance for voltage controlling transformers
    // entered in pu on system base quantities; used when COD1 is 1.
    // CR1 + j CX1 = 0.0 by default.

    // The first two data items on the fourth record are read for both two- and three-winding transformers;
    // the remaining data items are used only for three-winding transformers:

    WINDV2: double;
    // The winding two off-nominal turns ratio in pu of winding two bus base voltage
    // when CW is 1; WINDV2 = 1.0 by default. WINDV2 is the actual winding two
    // voltage in kV when CW is 2; WINDV2 is equal to the base voltage of bus J by
    // default.

    NOMV2: double;
    // The nominal (rated) winding two voltage in kV, or zero to indicate that nom-
    // inal winding two voltage is to be taken as the base voltage of bus J. NOMV2
    // is present for information purposes only; it is not used in any of the calculations
    // for modeling the transformer. NOMV2 = 0.0 by default.

    ANG2: double;
    // The winding two phase shift angle in degrees; ignored for a two-winding trans-
    // former. ANG2 is positive for a positive phase shift from the winding two side
    // to the "T" (or "star") point bus.  ANG2 must be greater than -180.0 and less
    // than or equal to +180.0. ANG2 = 0.0 by default.

    RATA2, RATB2, RATC2: double;
    // The second winding’s three ratings entered in MVA (not current expressed
    // in MVA); ignored for a two-winding transformer. RATA2 = 0.0, RATB2 = 0.0
    // and RATC2 = 0.0 (bypass flow limit check for this transformer winding) by
    // default.

    COD2: integer;
    // The transformer control mode for automatic adjustments of the winding two
    // tap or phase shift angle during power flow solutions: 0 for no control (fixed tap
    // and phase shift); ±1 for voltage control; ±2 for reactive power flow control; ±3
    // for active power flow control. If the control mode is entered as a positive
    // number, automatic adjustment of this transformer winding is enabled when the
    // corresponding adjustment is activated during power flow solutions; a negative
    // control mode suppresses the automatic adjustment of this transformer winding.
    // COD2 = 0 by default.

    CONT2: string;    // The bus number, or extended bus name enclosed in single quotes (see
    // Section 4.1.2), of the bus whose voltage is to be controlled by the transformer
    // turns ratio adjustment option of the power flow solution activities when COD2
    // is 1. CONT2 should be nonzero only for voltage controlling transformer
    // windings.
    // CONT2 may specify a bus other than I, J, or K; in this case, the sign of CONT2
    // defines the location of the controlled bus relative to the transformer winding.
    // If CONT2 is entered as a positive number, or a quoted extended bus name, the
    // ratio is adjusted as if bus CONT2 is on the winding one or winding three side
    // of the transformer; if CONT2 is entered as a negative number, or a quoted
    // extended bus name with a minus sign preceding the first character, the ratio is
    // adjusted as if bus |CONT2| is on the winding two side of the transformer.
    // CONT2 = 0 by default.

    RMA2, RMI2: double; // The upper and lower limits, respectively, of either:
    // • Off-nominal turns ratio in pu of winding two bus base voltage when
    // |COD2| is 1 or 2 and CW is 1; RMA2 = 1.1 and RMI2 = 0.9 by default.
    // • Actual winding two voltage in kV when |COD2| is 1 or 2 and CW is 2. No
    // default is allowed.
    // • Phase shift angle in degrees when |COD2| is 3. No default is allowed.
    // • Not used when |COD2| is 0; RMA2 = 1.1 and RMI2 = 0.9 by default.

    VMA2, VMI2: double; // The upper and lower limits, respectively, of either:
    // • Voltage at the controlled bus (bus |CONT2|) in pu when |COD2| is 1.
    // VMA2 = 1.1 and VMI2 = 0.9 by default.
    // • Reactive power flow into the transformer at the winding two bus end in
    // Mvar when |COD2| is 2. No default is allowed.
    // • Active power flow into the transformer at the winding two bus end in MW
    // when |COD2| is 3. No default is allowed.
    // • Not used when |COD2| is 0; VMA2 = 1.1 and VMI2 = 0.9 by default.

    NTP2: integer;
    // The number of tap positions available; used when COD2 is 1 or 2. NTP2 must be
    // between 2 and 9999. NTP2 = 33 by default.

    TAB2: integer;
    // The number of a transformer impedance correction table if this transformer
    // winding’s impedance is to be a function of either off-nominal turns ratio or
    // phase shift angle (see Section 4.1.1.11), or 0 if no transformer impedance cor-
    // rection is to be applied to this transformer winding. TAB2 = 0 by default.

    CR2, CX2: double;
    // The load drop compensation impedance for voltage controlling transformers
    // entered in pu on system base quantities; used when COD2 is 1.
    // CR2 + j CX2 = 0.0 by default.
    // The fifth data record is specified only for three-winding transformers:

    WINDV3: double;
    // The winding three off-nominal turns ratio in pu of winding three bus base
    // voltage when CW is 1; WINDV3 = 1.0 by default. WINDV3 is the actual
    // winding three voltage in kV when CW is 2; WINDV3 is equal to the base
    // voltage of bus K by default.

    NOMV3: double;
    // The nominal (rated) winding three voltage in kV, or zero to indicate that nom-
    // inal winding three voltage is to be taken as the base voltage of bus K. NOMV3
    // is present for information purposes only; it is not used in any of the calculations
    // for modeling the transformer. NOMV3 = 0.0 by default.

    ANG3: double;
    // The winding three phase shift angle in degrees. ANG3 is positive for a positive
    // phase shift from the winding three side to the "T" (or “star”) point bus. ANG3
    // must be greater than -180.0 and less than or equal to +180.0. ANG3 = 0.0 by
    // default.

    RATA3, RATB3, RATC3: double;
    // The third winding’s three ratings entered in MVA (not current expressed in
    // MVA). RATA3 = 0.0, RATB3 = 0.0 and RATC3 = 0.0 (bypass flow limit
    // check for this transformer winding) by default.

    COD3: integer;
    // The transformer control mode for automatic adjustments of the winding three
    // tap or phase shift angle during power flow solutions: 0 for no control (fixed tap
    // and phase shift); ±1 for voltage control; ±2 for reactive power flow control; ±3
    // for active power flow control. If the control mode is entered as a positive
    // number, automatic adjustment of this transformer winding is enabled when the
    // corresponding adjustment is activated during power flow solutions; a negative
    // control mode suppresses the automatic adjustment of this transformer winding.
    // COD3 = 0 by default.

    CONT3:      string;
    // The bus number, or extended bus name enclosed in single quotes (see
    // Section 4.1.2), of the bus whose voltage is to be controlled by the transformer
    // turns ratio adjustment option of the power flow solution activities when COD3
    // is 1. CONT3 should be nonzero only for voltage controlling transformer
    // windings.
    // CONT3 may specify a bus other than I, J, or K; in this case, the sign of CONT3
    // defines the location of the controlled bus relative to the transformer winding.
    // If CONT3 is entered as a positive number, or a quoted extended bus name, the
    // ratio is adjusted as if bus CONT3 is on the winding one or winding two side of
    // the transformer; if CONT3 is entered as a negative number, or a quoted
    // extended bus name with a minus sign preceding the first character, the ratio is
    // adjusted as if bus |CONT3| is on the winding three side of the transformer.
    // CONT3 = 0 by default.
    RMA3, RMI3: double;           // The upper and lower limits, respectively, of either:
    // • Off-nominal turns ratio in pu of winding three bus base voltage when
    // |COD3| is 1 or 2 and CW is 1; RMA3 = 1.1 and RMI3 = 0.9 by default.
    // • Actual winding three voltage in kV when |COD3| is 1 or 2 and CW is 2.
    // No default is allowed.
    // • Phase shift angle in degrees when |COD3| is 3. No default is allowed.
    // • Not used when |COD3| is 0; RMA3 = 1.1 and RMI3 = 0.9 by default.

    VMA3, VMI3: double;           // The upper and lower limits, respectively, of either:
    // • Voltage at the controlled bus (bus |CONT3|) in pu when |COD3| is 1.
    // VMA3 = 1.1 and VMI3 = 0.9 by default.
    // • Reactive power flow into the transformer at the winding three bus end in
    // Mvar when |COD3| is 2. No default is allowed.
    // • Active power flow into the transformer at the winding three bus end in
    // MW when |COD3| is 3. No default is allowed.
    // • Not used when |COD3| is 0; VMA3 = 1.1 and VMI3 = 0.9 by default.

    NTP3: integer;
    // The number of tap positions available; used when COD3 is 1 or 2. NTP3 must be
    // between 2 and 9999. NTP3 = 33 by default.

    TAB3: integer;
    // The number of a transformer impedance correction table if this transformer
    // winding’s impedance is to be a function of either off-nominal turns ratio or
    // phase shift angle (see Section 4.1.1.11), or 0 if no transformer impedance cor-
    // rection is to be applied to this transformer winding. TAB3 = 0 by default.

    CR3, CX3: double;
    // The load drop compensation impedance for voltage controlling transformers
    // entered in pu on system base quantities; used when COD3 is 1.
    // CR3 + j CX3 = 0.0 by default.

    // When specifying a two-winding transformer between buses I and J with circuit identifier CKT, if a
    // nontransformer branch between buses I and J with a circuit identifier of CKT is already present in
    // the working case, it is replaced (i.e., the nontransformer branch is deleted from the working case
    // and the newly specified two-winding transformer is then added to the working case).
    // Transformer data input is terminated with a record specifying a winding one bus number of zero.

    // Datos para la version 26

    ICONT, TABLE, CNTRL: longint;

    RMA, RMI, VMA, VMI, STEP, CR, CX: double;


    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);
    procedure cargue; override;
    procedure Calculo_potencias(var S12, S21, Sconsumida, I: NComplex);
  end;



  TRaw_AreaInterchange = class( TActorDato )

    // 4.1.1.7  Area Interchange Data

    // Area identifiers and interchange control parameters are specified in area interchange data records.
    // Data for each interchange area may be specified either at the time of raw data input or subsequently
    // via activities CHNG or XLIS, or the data editor windows. Each area interchange data record has the
    // following format:
    // I, ISW, PDES, PTOL, 'ARNAME'
    // where:

    I: longint;
    // Area number (1 through the maximum number of areas at the current size level; see
    // Table P-1).

    ISW: longint;
    // Bus number, or extended bus name enclosed in single quotes (see Section 4.1.2),
    // of the area slack bus for area interchange control. The bus must be a generator
    // (type two) bus in the specified area. Any area containing a system swing bus (type
    // three) must have either that swing bus or a bus number of zero specified for its area
    // slack bus number. Any area with an area slack bus number of zero is considered a
    // "floating area" by the area interchange control option of the power flow solution
    // activities. ISW = 0 by default.

    PDES: double;
    // Desired net interchange leaving the area (export); entered in MW. PDES must be
    // specified such that is consistent with the area interchange definition implied by the
    // area interchange control code (tie lines only, or tie lines and loads) to be specified
    // during power flow solutions (see Sections 4.10.3 and 4.10.3.3). PDES = 0.0 by
    // default.

    PTOL: double;
    // Interchange tolerance bandwidth; entered in MW. PTOL = 10.0 by default.

    ARNAME: string;
    // Alphanumeric identifier assigned to area I. The name may contain up to twelve
    // characters and must be enclosed in single quotes. ARNAME may be any combi-
    // nation of blanks, uppercase letters, numbers, and special characters. ARNAME is
    // set to twelve blanks by default.

    // Refer to Section 4.10.3.3 for further discussion on the area interchange control option of the power
    // flow solution activities.
    // Area interchange data input is terminated with a record specifying an area number of zero.

    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);


  end;

  TRaw_TwoTerminal_DCLine = class(TActorBiBarra)

    //   4.1.1.8  Two-Terminal dc Transmission Line Data

    // Each two-terminal dc transmission line to be represented in PSS/E is introduced by reading three
    // consecutive data records. Each set of dc line data records has the following format:
    // I,MDC,RDC,SETVL,VSCHD,VCMOD,RCOMP,DELTI,METER,DCVMIN,CCCITMX,CCCACC
    // IPR,NBR,ALFMX,ALFMN,RCR,XCR,EBASR,TRR,TAPR,TMXR,TMNR,STPR,ICR,IFR,ITR,IDR,XCAPR
    // IPI,NBI,GAMMX,GAMMN,RCI,XCI,EBASI,TRI,TAPI,TMXI,TMNI,STPI,ICI,IFI,ITI,IDI,XCAPI
    // The first of the three dc line data records defines the following line quantities and control
    // parameters:

    I:    integer;      // The dc line number.
    Name: string;
    MDC:  integer;
    // Control mode: 0 for blocked, 1 for power, 2 for current. MDC = 0 by default.

    RDC: double;     // The dc line resistance; entered in ohms. No default allowed.

    SETVL: double;
    // Current (amps) or power (MW) demand. When MDC is one, a positive value of
    // SETVL specifies desired power at the rectifier and a negative value specifies
    // desired inverter power. No default allowed.

    VSCHD: double;    // Scheduled compounded dc voltage; entered in kV. No default allowed.

    VCMOD: double;
    // Mode switch dc voltage; entered in kV. When the inverter dc voltage falls below
    // this value and the line is in power control mode (i.e., MDC = 1), the line switches
    // to current control mode with a desired current corresponding to the desired power
    // at scheduled dc voltage. VCMOD = 0.0 by default.

    RCOMP: double;
    // Compounding resistance; entered in ohms. Gamma and/or TAPI is used to attempt
    // to hold the compounded voltage (VDCI + DCCURRCOMP) at VSCHD. To con-
    // trol the inverter end dc voltage VDCI, set RCOMP to zero; to control the rectifier
    // end dc voltage VDCR, set RCOMP to the dc line resistance, RDC; otherwise, set
    // RCOMP to the appropriate fraction of RDC. RCOMP = 0.0 by default.

    DELTI: double;
    // Margin entered in per unit of desired dc power or current. This is the fraction by
    // which the order is reduced when ALPHA is at its minimum and the inverter is con-
    // trolling the line current. DELTI = 0.0 by default.

    METER: string;
    // Metered end code of either ’R’ (for rectifier) or ’I’ (for inverter). METER = ’I’ by
    // default.

    DCVMIN: double;
    // Minimum compounded dc voltage; entered in kV. Only used in constant gamma
    // operation (i.e., when GAMMX = GAMMN) when TAPI is held constant and an ac
    // transformer tap is adjusted to control dc voltage (i.e., when IFI, ITI, and IDI specify
    // a two-winding transformer). DCVMIN = 0.0 by default.

    CCCITMX: integer;
    // Iteration limit for capacitor commutated two-terminal dc line Newton solution pro-
    // cedure. CCCITMX = 20 by default.

    CCCACC: double;
    // Acceleration factor for capacitor commutated two-terminal dc line Newton solu-
    // tion procedure. CCCACC = 1.0 by default.
    // The second of the three dc line data records defines rectifier end data quantities and control
    // parameters:

    IPR: string;
    // Rectifier converter bus number, or extended bus name enclosed in single quotes
    // (see Section 4.1.2). No default allowed.

    NBR: integer;    // Number of bridges in series (rectifier). No default allowed.

    ALFMX: double;
    // Nominal maximum rectifier firing angle; entered in degrees. No default allowed.

    ALFMN: double;
    // Minimum steady-state rectifier firing angle; entered in degrees. No default allowed.

    RCR: double;
    // Rectifier commutating transformer resistance per bridge; entered in ohms. No
    // default allowed.

    XCR: double;
    // Rectifier commutating transformer reactance per bridge; entered in ohms. No
    // default allowed.

    EBASR: double;   // Rectifier primary base ac voltage; entered in kV. No default allowed.

    TRR: double;     // Rectifier transformer ratio. TRR = 1.0 by default.

    TAPR: double;    // Rectifier tap setting. TAPR = 1.0 by default.

    TMXR: double;    // Maximum rectifier tap setting. TMXR = 1.5 by default.

    TMNR: double;    // Minimum rectifier tap setting. TMNR = 0.51 by default.

    STPR: double;    // Rectifier tap step; must be positive. STPR = 0.00625 by default.

    ICR: string;
    // Rectifier firing angle measuring bus number, or extended bus name enclosed in
    // single quotes (see Section 4.1.2). The firing angle and angle limits used inside the
    // dc model are adjusted by the difference between the phase angles at this bus and
    // the ac/dc interface (i.e., the converter bus, IPR). ICR = 0 by default.

    IFR: longint;
    // Winding one side "from bus" number, or extended bus name enclosed in single
    // quotes (see Section 4.1.2), of a two-winding transformer. IFR = 0 by default.

    ITR: longint;
    // Winding two side "to bus" number, or extended bus name enclosed in single quotes
    // (see Section 4.1.2), of a two-winding transformer. ITR = 0 by default.



    IDR: string;
    // Circuit identifier; the branch described by IFR, ITR, and IDR must have been
    // entered as a two-winding transformer; an ac transformer may control at most only
    // one dc converter. IDR = '1' by default.
    // If no branch is specified, TAPR is adjusted to keep alpha within limits; otherwise,
    // TAPR is held fixed and this transformer’s tap ratio is adjusted. The adjustment logic
    // assumes that the rectifier converter bus is on the winding two side of the transformer.
    // The limits TMXR and TMNR specified here are used; except for the transformer con-
    // trol mode flag (COD of Section 4.1.1.6), the ac tap adjustment data is ignored.

    XCAPR: double;   // Commutating capacitor reactance magnitude per bridge; entered in ohms.
    // XCAPR = 0.0 by default.

    // Data on the third of the three dc line data records contains the inverter quantities corresponding to
    // the rectifier quantities specified on the second record described above.
    // Dc line converter buses, IPR and IPI, may be type one, two, or three buses. Generators, loads, fixed
    // and switched shunt elements, other dc line converters, and FACTS device sending ends are per-
    // mitted at converter buses.
    // When either XCAPR > 0.0 or XCAPI > 0.0, the two-terminal dc line is treated as capacitor com-
    // mutated. Capacitor commutated two-terminal dc lines preclude the use of a remote ac transformer
    // as commutation transformer tap and remote commutation angle buses at either converter. Any data
    // provided in these fields are ignored for capacitor commutated two-terminal dc lines.
    // Further details on dc line modeling in power flow solutions are given in Section 4.8.6.
    // Dc line data input is terminated with a record specifying a dc line number of zero.

    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);
    procedure cargue; override;
  end;


  TRaw_VoltageSourceConverter_DCLine = class(Tactorbibarra)

    //   4.1.1.9  Voltage Source Converter (VSC) Dc Line Data

    // Each voltage source converter (VSC) dc line to be represented in PSS/E is introduced by reading a
    // set of three consecutive data records. Each set of VSC dc line data records has the following format:

    //     'NAME', MDC, RDC, O1, F1, ... O4, F4
    //     IBUS,TYPE,MODE,DCSET,ACSET,ALOSS,BLOSS,MINLOSS,SMAX,IMAX,PWF,MAXQ,MINQ,REMOT,RMPCT
    //     IBUS,TYPE,MODE,DCSET,ACSET,ALOSS,BLOSS,MINLOSS,SMAX,IMAX,PWF,MAXQ,MINQ,REMOT,RMPCT

    // The first of the three VSC dc line data records defines the following line quantities and control
    // parameters:

    Name: string;
    // The non-blank alphanumeric identifier assigned to this VSC dc line. Each VSC dc
    // line must have a unique NAME. The name may be up to twelve characters and must
    // be enclosed in single quotes. NAME may contain any combination of blanks,
    // uppercase letters, numbers and special characters. No default allowed.

    MDC: integer;
    // Control mode: 0 for out-of-service, 1 for in-service. MDC = 1 by default.

    RDC: double;
    // The dc line resistance; entered in ohms. RDC must be positive. No default allowed.

    Oi_: array[1..4] of integer;
    // An owner number (1 through the maximum number of owners at the current size
    // level; see Table P-1). Each VSC dc line may have up to four owners. By default,
    // O1 is 1, and O2, O3 and O4 are zero.

    Fi_: array[1..4] of double;
    // The fraction of total ownership assigned to owner Oi; each Fi must be positive. The
    // Fi values are normalized such that they sum to 1.0 before they are placed in the
    // working case. By default, each Fi is 1.0.

    // The remaining two data records define the converter buses (converter 1 and converter 2), along with
    // their data quantities and control parameters:

    IBUS: string;
    // Converter bus number, or extended bus name enclosed in single quotes (see
    // Section 4.1.2). No default allowed.

    TIPO: integer;
    // TYPE Code for the type of converter dc control: 0 for converter out-of-service, 1 for dc
    // voltage control, or 2 for MW control. When both converters are in-service, exactly
    // one converter of each VSC dc line must be TYPE 1. No default allowed.

    MODE: integer;
    // Converter ac control mode: 1 for ac voltage control or 2 for fixed ac power factor.
    // MODE = 1 by default.

    DCSET: double;
    // Converter dc setpoint. For TYPE = 1, DCSET is the scheduled dc voltage on the
    // dc side of the converter bus; entered in kV. For TYPE = 2, DCSET is the power
    // demand, where a positive value specifies that the converter is feeding active power
    // into the ac network at bus IBUS, and a negative value specifies that the converter
    // is withdrawing active power from the ac network at bus IBUS; entered in MW. No
    // default allowed.

    ACSET: double;
    // Converter ac setpoint. For MODE = 1, ACSET is the regulated ac voltage setpoint;
    // entered in pu. For MODE = 2, ACSET is the power factor setpoint. ACSET = 1.0
    // by default.

    Aloss, Bloss: double;
    // Coefficients of the linear equation used to calculate converter losses:
    // KWconv loss = Aloss + Idc*Bloss
    // Aloss is entered in kW. Bloss is entered in kW/amp. Aloss = Bloss = 0.0 by default.

    MINloss: double;  // Minimum converter losses; entered in kW. MINloss = 0.0 by default.

    SMAX: double;
    // Converter MVA rating; entered in MVA. SMAX = 0.0 to allow unlimited con-
    // verter MVA loading. SMAX = 0.0 by default.

    IMAX: double;
    // Converter ac current rating; entered in amps. IMAX = 0.0 to allow unlimited con-
    // verter current loading. If a positive IMAX is specified, the base voltage assigned
    // to bus IBUS must be positive. IMAX = 0.0 by default.

    PWF: double;
    // Power weighting factor fraction (0.0 < PWF < 1.0) used in reducing the active
    // power order and either the reactive power order (when MODE is 2) or the reactive
    // power limits (when MODE is 1) when the converter MVA or current rating is vio-
    // lated. When PWF is 0.0, only the active power is reduced; when PWF is 1.0, only
    // the reactive power is reduced; otherwise, a weighted reduction of both active and
    // reactive power is applied. PWF = 1.0 by default.

    MAXQ: double;
    // Reactive power upper limit; entered in Mvar. A positive value of reactive power
    // indicates reactive power flowing into the ac network from the converter; a negative
    // value of reactive power indicates reactive power withdrawn from the ac network.
    // Not used if MODE = 2. MAXQ = 9999.0 by default.

    MINQ: double;
    // Reactive power lower limit; entered in Mvar. A positive value of reactive power
    // indicates reactive power flowing into the ac network from the converter; a negative
    // value of reactive power indicates reactive power withdrawn from the ac network.
    // Not used if MODE = 2. MINQ = -9999.0 by default.

    REMOT: string;
    // Bus number, or extended bus name enclosed in single quotes (see Section 4.1.2),
    // of a remote type 1 or 2 bus whose voltage is to be regulated by this converter to the
    // value specified by ACSET. If bus REMOT is other than a type 1 or 2 bus, bus IBUS
    // regulates its own voltage to the value specified by ACSET. REMOT is entered as
    // zero if the converter is to regulate its own voltage. Not used if MODE = 2.
    // REMOT = 0 by default.

    RMPCT: double;
    // Percent of the total Mvar required to hold the voltage at the bus controlled by bus
    // IBUS that are to be contributed by this VSC; RMPCT must be positive. RMPCT is
    // needed only if REMOT specifies a valid remote bus and there is more than one
    // local or remote voltage controlling device (plant, switched shunt, FACTS device
    // shunt element, or VSC dc line converter) controlling the voltage at bus REMOT to
    // a setpoint, or REMOT is zero but bus IBUS is the controlled bus, local or remote,
    // of one or more other setpoint mode voltage controlling devices. Not used if
    // MODE = 2. RMPCT = 100.0 by default.


    // Each VSC dc line converter bus:
    // • must be a type one or two bus. Generators, loads, fixed and switched shunt elements,
    // other dc line converters, and FACTS device sending ends are permitted at converter
    // buses.
    // • must not have the terminal end of a FACTS device connected to the same bus.
    // • must not be connected by a zero impedance line to another bus which violates any of
    // the above restrictions.

    // In specifying reactive power limits for converters which control ac voltage (i.e., those with unequal
    // reactive power limits whose MODE is 1), the use of very narrow var limit bands is discouraged.
    // The Newton-Raphson based power flow solutions require that the difference between the control-
    // ling equipment's high and low reactive power limits be greater than 0.002 pu for all setpoint mode
    // voltage controlling equipment (0.2 Mvar on a 100 MVA system base). It is recommended that
    // voltage controlling VSC converters have Mvar ranges substantially wider than this minimum per-
    // missible range.

    // For interchange and loss assignment purposes, the dc voltage controlling converter is assumed to
    // be the non-metered end of each VSC dc line. As with other network branches, losses are assigned
    // to the subsystem of the non-metered end, and flows at the metered ends are used in interchange
    // calculations.

    // Further details on dc line modeling in power flow solutions are given in Section 4.8.6.

    // VSC dc line data input is terminated with a record specifying a blank dc line name (’ ’) or a dc line
    // name of ’0’.

    //constructor LoadFromText(sala: TSalaFlucar;  var f: textfile );
    //procedure cargue_MY(var MatAdmitancias:TMatrizDeAdmitancias; Sbase:double);override;
  end;


  TRaw_SwitcheShunt = class(TActorMonobarra)

    //4.1.1.10  Switched Shunt Data

    //Each network bus to be represented in PSS/E with switched shunt admittance devices must have a
    //switched shunt data record specified for it. The switched shunts are represented with up to eight
    //blocks of admittance, each one of which consists of up to nine steps of the specified block admit-
    //tance. Each switched shunt data record has the following format:
    //I, MODSW, VSWHI, VSWLO, SWREM, RMPCT, ’RMIDNT’, BINIT, N1, B1, N2, B2, ... N8, B8
    //where:

   // I: longint;
    //Bus number, or extended bus name enclosed in single quotes (see Section 4.1.2).


    MODSW: integer;     //Control mode:
    //0 - fixed
    //1 - discrete adjustment, controlling voltage locally or at bus SWREM
    //2 - continuous adjustment, controlling voltage locally or at bus SWREM
    //3 - discrete adjustment, controlling reactive power output of the plant at bus
    //     SWREM
    //4 - discrete adjustment, controlling reactive power output of the VSC dc line
    //     converter at bus SWREM of the VSC dc line whose name is specified as
    //     RMIDNT
    //5 - discrete adjustment, controlling admittance setting of the switched shunt at
    //     bus SWREM
    //MODSW = 1 by default.

    ADJM: integer;

    //                   Adjustment method:

    //                   0     steps and blocks are switched on in input order, and off in reverse
    //                         input order; this adjustment method was the only method available
    //                         prior to PSS®E-32.0.

    //                   1     steps and blocks are switched on and off such that the next highest
    //                         (or lowest, as appropriate) total admittance is achieved.

    //                   ADJM = 0 by default.

    STAT: integer;

    //           Initial switched shunt status of one for in-service and zero for out-of-service;
    //           STAT = 1 by default.




    VSWHI: double;
    //When MODSW is 1 or 2, the controlled voltage upper limit; entered in pu.
    //When MODSW is 3, 4 or 5, the controlled reactive power range upper limit;
    //entered in pu of the total reactive power range of the controlled voltage controlling
    //device.
    //VSWHI is not used when MODSW is 0. VSWHI = 1.0 by default.

    VSWLO: double;
    //When MODSW is 1 or 2, the controlled voltage lower limit; entered in pu.
    //When MODSW is 3, 4 or 5, the controlled reactive power range lower limit;
    //entered in pu of the total reactive power range of the controlled voltage controlling
    //device.
    //VSWLO is not used when MODSW is 0. VSWLO = 1.0 by default.

    SWREM: longint;
    //Bus number, or extended bus name enclosed in single quotes (see Section 4.1.2),
    //of the bus whose voltage or connected equipment reactive power output is con-
    //trolled by this switched shunt.
    //When MODSW is 1 or 2, SWREM is entered as 0 if the switched shunt is to regu-
    //late its own voltage; otherwise, SWREM specifies the remote type one or two bus
    //whose voltage is to be regulated by this switched shunt.
    //When MODSW is 3, SWREM specifies the type two or three bus whose plant reac-
    //tive power output is to be regulated by this switched shunt. Set SWREM to "I" if
    //the switched shunt and the plant which it controls are connected to the same bus.
    //When MODSW is 4, SWREM specifies the converter bus of a VSC dc line whose
    //converter reactive power output is to be regulated by this switched shunt. Set
    //SWREM to "I" if the switched shunt and the VSC dc line converter which it con-
    //trols are connected to the same bus.
    //When MODSW is 5, SWREM specifies the remote bus to which the switched
    //shunt whose admittance setting is to be regulated by this switched shunt is
    //connected.
    //SWREM is not used when MODSW is 0. SWREM = 0 by default.

    RMPCT: double;
    //Percent of the total Mvar required to hold the voltage at the bus controlled by bus
    //I that are to be contributed by this switched shunt; RMPCT must be positive.
    //RMPCT is needed only if SWREM specifies a valid remote bus and there is more
    //than one local or remote voltage controlling device (plant, switched shunt, FACTS
    //device shunt element, or VSC dc line converter) controlling the voltage at bus
    //SWREM to a setpoint, or SWREM is zero but bus I is the controlled bus, local or
    //remote, of one or more other setpoint mode voltage controlling devices. Only used
    //if MODSW = 1 or 2. RMPCT = 100.0 by default.

    RMIDNT: string;
    //When MODSW is 4, the name of the VSC dc line whose converter bus is specified
    //in SWREM. RMIDNT is not used for other values of MODSW. RMIDNT is a
    //blank name by default.

    BINIT: double;
    //Initial switched shunt admittance; entered in Mvar at unity voltage. BINIT = 0.0 by
    //default.

    Ni_: array[1..8] of integer;
    //Number of steps for block i. The first zero value of Ni or Bi is interpreted as the
    //end of the switched shunt blocks for bus I. Ni = 0 by default.

    Bi_: array[1..8] of double;
    //Admittance increment for each of Ni steps in block i; entered in Mvar at unity
    //voltage. Bi = 0.0 by default.

    //BINIT needs to be set to its actual solved case value only when the network, as entered into the
    //working case via activity READ, is to be considered solved as read in, or when the device is to be
    //treated as "fixed" (i.e., MODSW is set to zero or switched shunts are to be locked during power flow
    //solutions).

    //The switched shunt elements at a bus may consist entirely of reactors (each Bi is a negative quan-
    //tity) or entirely of capacitor banks (each Bi is a positive quantity). In these cases, the shunt blocks
    //are specified in the order in which they are switched on the bus.

    //If the switched shunt devices at a bus are a mixture of reactors and capacitors, the reactor blocks are
    //specified first in the order in which they are switched on, followed by the capacitor blocks in the
    //order in which they are switched on.

    //In specifying reactive power limits for setpoint mode voltage controlling switched shunts (i.e., those
    //with MODSW of 1 or 2), the use of a very narrow admittance range is discouraged. The Newton-
    //Raphson based power flow solutions require that the difference between the controlling equipment's
    //high and low reactive power limits be greater than 0.002 pu for all setpoint mode voltage controlling
    //equipment (0.2 Mvar on a 100 MVA system base). It is recommended that voltage controlling
    //switched shunts have admittance ranges substantially wider than this minimum permissible range.

    //When MODSW is 3, 4 or 5, VSWLO and VSWHI define a restricted band of the controlled device’s
    //reactive power range. They are specified in pu of the total reactive power range of the controlled
    //device (i.e., the plant QMAX - QMIN when MODSW is 3, MAXQ - MINQ of a VSC dc line con-
    //verter when MODSW is 4, and NiBi  NjBj when MODSW is 5, where "i" are those switched
    //shunt blocks for which Bi is positive and "j" are those for which Bi is negative). VSWLO must be
    //greater than 0.0 and less than VSWHI, and VSWHI must be less than 1.0. That is, the following
    //relationship must be honored:

    //             0.0 < VSWLO < VSWHI < 1.0

    //The reactive power band for switched shunt control is calculated by applying VSWLO and VSWHI
    //to the reactive power band extremes of the controlled plant or VSC converter. For example, with
    //MINQ of -50.0 and MAXQ of +50.0, if VSWLO is 0.2 and VSWHI is 0.75, then the reactive power
    //band defined by VSWLO and VSWHI is:

    //     -50.0 + 0.2*(50.0 - (-50.0)) = -50.0 + 0.2*100.0 = -50.0 + 20.0 = -30.0 Mvar

    //through:

    //     -50.0 + 0.75*(50.0 - (-50.0)) = -50.0 + 0.75*100.0 = -50.0 + 75.0 = +25.0 Mvar

    //The switched shunt admittance is kept in the working case and reported in output tabulations sepa-
    //rately from the fixed bus shunt, which is input on the bus data record (see Section 4.1.1.2).

    //Refer to Sections 4.8.4, 4.8.6 and 4.10.3.4 for details on the handling of switched shunts during
    //power flow solutions.

    //It is recommended that data records for switched shunts whose control mode is 5 (i.e., they control
    //the setting of other switched shunts) be grouped together following all other switched shunt data
    //records. This practice will eliminate any warnings of no switched shunt at the specified remote bus
    //simply because the remote bus’ switched shunt record has not as yet been read.

    //Switched shunt data input is terminated with a record specifying a bus number of zero.

    // variables auxiliares
    QMIN, QMAX, QINIT: double;


    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);
    procedure cargue; override;

  end;



  TRaw_TransformerImpedanceCorrectionTables = class( TActorDato )

    //  4.1.1.11  Transformer Impedance Correction Tables

    //Transformer impedance correction tables are used to model a change of transformer impedance as
    //off-nominal turns ratio or phase shift angle is adjusted. Data for each table may be specified either
    //at the time of raw data input or subsequently via activity CHNG or the impedance correction table
    //data editor window. Each transformer impedance correction data record has the following format:

    //     I, T1, F1, T2, F2, T3, F3, ... T11, F11

    //where:

    I: longint;    //Impedance correction table number.

    Ti_: array[1..11] of double;
    //Either off-nominal turns ratio in pu or phase shift angle in degrees. Ti = 0.0 by default.

    Fi_: array[1..11] of double;
    //Scaling factor by which transformer nominal impedance is to be multiplied to
    //obtain the actual transformer impedance for the corresponding "Ti". Fi = 0.0 by default.

    //The "Ti" values on a transformer impedance correction table record must all be either tap ratios or
    //phase shift angles. They must be entered in strictly ascending order; i.e., for each "i", Ti+1>Ti. Each
    //"Fi" entered must be greater than zero. On each record, at least 2 pairs of values must be specified
    //and up to 11 may be entered.

    //The Ti values for tables that are a function of tap ratio (rather than phase shift angle) are in units of
    //the controlling winding’s off-nominal turns ratio in pu of the controlling winding’s bus base voltage.

    //A transformer winding is assigned to an impedance correction table either on the third, fourth or
    //fifth record of the transformer data record block of activities READ, TREA, RDCH (see
    //Section 4.1.1.6), or via activities CHNG or XLIS, or the data editor windows. Each table may be
    //shared among many transformer windings. If the first "T" in a table is less than 0.5 or the last "T"
    //entered is greater than 1.5, "T" is assumed to be the phase shift angle and the impedance of each
    //transformer winding assigned to the table is treated as a function of phase shift angle. Otherwise,
    //the impedances of the transformer windings assigned to the table are made sensitive to off-nominal
    //turns ratio.

    //The working case provides for the storage of both a nominal and actual impedance for each trans-
    //former winding impedance. The value of transformer impedance entered in activities READ,
    //TREA, RDCH, CHNG, or XLIS, and in the data editor windows is taken as the nominal value of
    //impedance. Each time the complex tap ratio of a transformer is changed, either automatically by the
    //power flow solution activities or manually by the user, and the transformer winding has been
    //assigned to an impedance correction table, actual transformer winding impedance is redetermined
    //if appropriate. First, the scaling factor is established from the appropriate table by linear interpola-
    //tion; then nominal impedance is multiplied by the scaling factor to determine actual impedance. An
    //appropriate message is printed any time the actual impedance is modified.

    //Transformer impedance correction data input is terminated with a record specifying a table number
    //of zero.

    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);
    //procedure cargue_MY(var MatAdmitancias:TMatrizDeAdmitancias; Sbase:double);override;
  end;


  TRaw_MultiTerminal_DCLine = class( TActorDato )

    //  4.1.1.12  Multiterminal dc Transmission Line Data

    //Each multiterminal dc transmission line to be represented in PSS/E is introduced by reading a series
    //of data records. Each set of multiterminal dc line data records begins with a record of the following
    //format:

    //       I, NCONV, NDCBS, NDCLN, MDC, VCONV, VCMOD, VCONVN

    //where:

    I: longint;         // Multiterminal dc line number.

    NCONV: integer;
    //Number of ac converter station buses in multiterminal dc line "I". No default allowed.

    NDCBS: integer;
    //Number of "dc buses" in multiterminal dc line "I" (NCONV < NDCBS). No default allowed.

    NDCLN: integer;
    //Number of dc links in multiterminal dc line "I". No default allowed.

    MDC: integer;       //Control mode:
    //0 - blocked
    //1 - power
    //2 - current
    //MDC = 0 by default.

    VCONV: string;
    //Bus number, or extended bus name enclosed in single quotes (see Section 4.1.2),
    //of the ac converter station bus that controls dc voltage on the positive pole of multi-
    //terminal dc line "I". Bus VCONV must be a positive pole inverter. No default
    //allowed.

    VCMOD: double;
    //Mode switch dc voltage; entered in kV. When any inverter dc voltage magnitude
    //falls below this value and the line is in power control mode (i.e., MDC = 1), the
    //line switches to current control mode with converter current setpoints corre-
    //sponding to their desired powers at scheduled dc voltage. VCMOD = 0.0 by
    //default.

    VCONVN: string;
    //Bus number, or extended bus name enclosed in single quotes (see Section 4.1.2),
    //of the ac converter station bus that controls dc voltage on the negative pole of
    //multiterminal dc line "I". If any negative pole converters are specified (see below),
    //bus VCONVN must be a negative pole inverter. If the negative pole is not being
    //modeled, VCONVN must be specified as zero. VCONVN = 0 by default.

    //This data record is followed by "NCONV" converter records of the following format:

    //     IB,N,ANGMX,ANGMN,RC,XC,EBAS,TR,TAP,TPMX,TPMN,TSTP,SETVL,DCPF,MARG,CNVCOD

    //where:

    IB: string;
    //Ac converter bus number, or extended bus name enclosed in single quotes (see
    //Section 4.1.2). No default allowed.

    N: integer;         //Number of bridges in series. No default allowed.

    ANGMX: double;
    //Nominal maximum ALPHA or GAMMA angle; entered in degrees. No default allowed.

    ANGMN: double;
    //Minimum steady-state ALPHA or GAMMA angle; entered in degrees. No default allowed.

    RC: double;
    //Commutating resistance per bridge; entered in ohms. No default allowed.

    XC: double;         //Commutating reactance per bridge; entered in ohms. No default allowed.

    EBAS: double;       //Primary base ac voltage; entered in kV. No default allowed.

    TR: double;         //Actual transformer ratio. TR = 1.0 by default.

    TAP: double;        //Tap setting. TAP = 1.0 by default.

    TPMX: double;       //Maximum tap setting. TPMX = 1.5 by default.

    TPMN: double;       //Minimum tap setting. TPMN = 0.51 by default.

    TSTP: double;       //Tap step; must be positive. TSTP = 0.00625 by default.

    SETVL: double;
    //Converter setpoint. When IB is equal to VCONV or VCONVN, SETVL specifies
    //the scheduled dc voltage magnitude, entered in kV, across the converter. For other
    //converter buses, SETVL contains the converter current (amps) or power (MW)
    //demand; a positive value of SETVL indicates that bus IB is a rectifier, and a neg-
    //ative value indicates an inverter. No default allowed.

    DCPF: double;
    //Converter "participation factor." When the order at any rectifier in the multi-
    //terminal dc line is reduced, either to maximum current or margin, the orders at the
    //remaining converters on the same pole are modified according to their DCPFs to:
    //SETVL + (DCPF/SUM)R
    //where SUM is the sum of the DCPFs at the unconstrained converters on the same
    //pole as the constrained rectifier, and R is the order reduction at the constrained rec-
    //tifier. DCPF = 1. by default.

    MARG: double;
    //Rectifier margin entered in per unit of desired dc power or current. The converter
    //order reduced by this fraction, (1.-MARG)SETVL, defines the minimum order
    //for this rectifier. MARG is used only at rectifiers. MARG = 0.0 by default.

    CNVCOD: double;
    //Converter code. A positive value or zero must be entered if the converter is on the
    //positive pole of multiterminal dc line "I". A negative value must be entered for
    //negative pole converters. CNVCOD = 1 by default.

    //These data records are followed by "NDCBS" dc bus records of the following format:

    //      IDC, IB, IA, ZONE, 'NAME', IDC2, RGRND, OWNER

    //where:

    IDC: integer;
    //Dc bus number (1 to NDCBS). The dc buses are used internally within each mul-
    //titerminal dc line and must be numbered 1 through NDCBS. No default allowed.

    //IB:string;         //Ac converter bus number, or extended bus name enclosed in single quotes (see
    //Section 4.1.2), or zero. Each converter station bus specified in a converter record must
    //be specified as IB in exactly one dc bus record. Dc buses that are connected only to
    //other dc buses by dc links and not to any ac converter buses must have a zero specified
    //for IB. A dc bus specified as IDC2 on one or more other dc bus records must have a
    //zero specified for IB on its own dc bus record. IB = 0 by default.

    IA: integer;
    //Area number (1 through the maximum number of areas at the current size level; see
    //Table P-1). IA = 1 by default.

    ZONE: integer;
    //Zone number (1 through the maximum number of zones at the current size level;
    //see Table P-1). ZONE = 1 by default.

    Name: string;
    //Alphanumeric identifier assigned to dc bus "IDC". The name may be up to twelve
    //characters and must be enclosed in single quotes. NAME may contain any combi-
    //nation of blanks, uppercase letters, numbers, and special characters. NAME is
    //twelve blanks by default.

    IDC2: integer;
    //Second dc bus to which converter IB is connected, or zero if the converter is con-
    //nected directly to ground. For voltage controlling converters, this is the dc bus with
    //the lower dc voltage magnitude and SETVL specifies the voltage difference
    //between buses IDC and IDC2. For rectifiers, dc buses should be specified such that
    //power flows from bus IDC2 to bus IDC. For inverters, dc buses should be specified
    //such that power flows from bus IDC to bus IDC2. IDC2 is ignored on those dc bus
    //records that have IB specified as zero. IDC2 = 0 by default.

    RGRND: double;
    //Resistance to ground at dc bus IDC; entered in ohms. During solutions RGRND is
    //used only for those dc buses specified as IDC2 on other dc bus records.
    //RGRND = 0.0 by default.

    OWNER: integer;
    //Owner number (1 through the maximum number of owners at the current size level;
    //see Table P-1). OWNER = 1 by default.

    //These data records are followed by "NDCLN" dc link records of the following format:

    //      IDC, JDC, DCCKT, RDC, LDC

    //where:

    //IDC:integer;       //Branch "from bus" dc bus number.

    JDC: integer;
    //Branch "to bus" dc bus number. JDC is entered as a negative number to designate
    //it as the metered end for area and zone interchange calculations. Otherwise, bus
    //IDC is assumed to be the metered end.

    DCCKT: string;
    //One-character uppercase alphanumeric branch circuit identifier. It is recommended
    //that single circuit branches be designated as having the circuit identifier ’1’.
    //DCCKT = ’1’ by default.

    RDC: double;        //DC link resistance, entered in ohms. No default allowed.

    LDC: double;
    //Dc link inductance, entered in mH. LDC is not used by the power flow solution
    //activities but is available to multiterminal dc line dynamics models. LDC = 0.0 by
    //default.

    //The following points should be noted in specifying multiterminal dc line data:

    //1. Conventional two-terminal (see Section 4.1.1.8) and multiterminal dc lines are stored
    //separately in PSS/E working memory. Therefore, there may simultaneously exist, for
    //example, a two-terminal dc line identified as dc line number 1 along with a multiter-
    //minal line numbered 1.

    //2. Multiterminal lines should have at least three converter terminals; conventional dc lines
    //consisting of two terminals should be modeled as two-terminal lines (see
    //Section 4.1.1.8).

    //3. Ac converter buses may be type one, two, or three buses. Generators, loads, fixed and
    //switched shunt elements, other dc line converters, and FACTS device sending ends are
    //permitted at converter buses.

    //4. Each multiterminal dc line is treated as a subnetwork of "dc buses" and "dc links" con-
    //necting its ac converter buses. For each multiterminal dc line, the dc buses must be
    //numbered 1 through NDCBS.

    //5. Each ac converter bus must be specified as IB on exactly one dc bus record; there may
    //be dc buses connected only to other dc buses by dc links but not to any ac converter bus.

    //6. Ac converter bus "IB" may be connected to a dc bus "IDC", which is connected directly
    //to ground. "IB" is specified on the dc bus record for dc bus "IDC"; the IDC2 field is
    //specified as zero.

    //7. Alternatively, ac converter bus "IB" may be connected to two dc buses "IDC" and "IDC2",
    //the second of which is connected to ground through a specified resistance. "IB" and
    //"IDC2" are specified on the dc bus record for dc bus "IDC"; on the dc bus record for bus
    //"IDC2", the ac converter bus and second dc bus fields (IB and IDC2, respectively) must be
    //specified as zero and the grounding resistance is specified as RGRND.

    //8. The same dc bus may be specified as the second dc bus for more than one ac converter
    //bus.

    //9. All dc buses within a multiterminal dc line must be reachable from any other point
    //within the subnetwork.

    //10. The area number assigned to dc buses and the metered end designation of dc links are
    //used in calculating area interchange and assigning losses in activities AREA, INTA,
    //TIES, and SUBS as well as in the interchange control option of the power flow solution
    //activities. Similarly, the zone assignment and metered end specification is used in
    //activities ZONE, INTZ, TIEZ, and SUBS.

    //11. Section 4.3.2 describes the specification of NCONV, NDCBS and NDCLN when spec-
    //ifying changes to an existing multi-terminal dc line in activity RDCH

    //Further details on dc line modeling in power flow solutions are given in Section 4.8.6.

    //Multiterminal dc line data input is terminated with a record specifying a dc line number of zero.

    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);
    //procedure cargue_MY(var MatAdmitancias:TMatrizDeAdmitancias; Sbase:double);override;
  end;

  TRaw_MultiSectionLineGrouping = class( TActorDato )

    //4.1.1.13  Multisection Line Grouping Data

    //Each multisection line grouping to be represented in PSS/E is introduced by reading a multisection
    //line grouping data record. Each multisection line grouping data record has the following format:

    //     I, J, ID, DUM1, DUM2, ... DUM9

    //where:

    I: longint;
    //"From bus" number, or extended bus name enclosed in single quotes (see
    //Section 4.1.2).

    J:  longint;
    //"To bus" number, or extended bus name enclosed in single quotes (see
    //Section 4.1.2). J is entered as a negative number or with a minus sign before the
    //first character of the extended bus name to designate it as the metered end; other-
    //wise, bus I is assumed to be the metered end.

    ID: string;
    //Two-character upper case alphanumeric multisection line grouping identifier. The
    //first character must be an ampersand ("&"). ID = ’&1’ by default.

    DUMi_: array[1..11] of string;
    //Bus numbers, or extended bus names enclosed in single quotes (see Section 4.1.2),
    // the "dummy buses" connected by the branches that comprise this multisection
    //line grouping. No defaults allowed.

    //The "DUMi" values on each record define the branches connecting bus I to bus J, and are entered
    //so as to trace the path from bus I to bus J. Specifically, for a multisection line grouping consisting
    //of three "line sections" (and hence two "dummy buses"):

    //      I     D1    D2     j
    //      -----------------
    //         C1    C2    C3

    //The path from "I" to "J" is defined by the following branches:

    //      From  To  Circuit
    //      I     D1  C1
    //      D1    D2  C2
    //      D2    J   C3

    //If this multisection line grouping is to be assigned the line identifier "&1", the corresponding multi-
    //section line grouping data record is given by:

    //        I   J   &1   D1   D2

    //Up to 10 line sections (and hence 9 dummy buses) may be defined in each multisection line
    //grouping. A branch may be a line section of at most one multisection line grouping.

    //Each dummy bus must have exactly two branches connected to it, both of which must be members
    //of the same multisection line grouping. A multisection line dummy bus may not be a converter bus
    //of a dc transmission line. A FACTS control device may not be connected to a multisection line
    //dummy bus.

    //The status of line sections and type codes of dummy buses are set such that the multisection line is
    //treated as a single entity with regards to its service status.

    //When the multisection line reporting option is enabled (see Sections 3.11 and 6.10), several power
    //flow reporting activities such as POUT and LOUT do not tabulate conditions at multisection line
    //dummy buses. Accordingly, care must be taken in interpreting power flow output reports when
    //dummy buses are other than passive nodes (e.g., if load or generation is present at a dummy bus).


    //Multisection line grouping data input is terminated with a record specifying a "from bus" number
    //of zero.

    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);

  end;

  TRaw_Zone = class( TActorDato )

    //4.1.1.14  Zone Data

    //Zone identifiers are specified in zone data records. Data for each zone may be specified either at the
    //time of raw data input or subsequently via activities CHNG or XLIS, or the data editor windows.
    //Each zone data record has the following format:

    //     I, 'ZONAME'

    //where:

    I: longint;
    //Zone number (1 through the maximum number of zones at the current size level;
    //see Table P-1).

    ZONAME: string;
    //Alphanumeric identifier assigned to zone I. The name may contain up to twelve
    //characters and must be enclosed in single quotes. ZONAME may be any combi-
    //nation of blanks, uppercase letters, numbers, and special characters. ZONAME is
    //set to twelve blanks by default.

    //Zone data input is terminated with a record specifying a zone number of zero.

    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);

  end;

  TRaw_InterAreaTransfer = class( TActorDato )

    //4.1.1.15  Interarea Transfer Data

    //Scheduled active power transfers between pairs of areas are specified in interarea transfer data
    //records. Each interarea transfer data record has the following format:

    //         ARFROM, ARTO, TRID, PTRAN
    //where:

    ARFROM: longint;
    //"From area" number (1 through the maximum number of areas at the current size
    //level; see Table P-1).

    ARTO: longint;
    //"To area" number (1 through the maximum number of areas at the current size
    //level; see Table P-1).

    TRID: string;
    //Single-character (0 through 9 or A through Z) upper case interarea transfer identi-
    //fier used to distinguish among multiple transfers between areas ARFROM and
    //ARTO. TRID = ’1’ by default.

    PTRAN: double;
    //MW comprising this transfer. A positive PTRAN indicates that area ARFROM is
    //selling to area ARTO. PTRAN = 0.0 by default.

    //Following the completion of interarea transfer data input, activity READ alarms any area for which
    //at least one interarea transfer is present and whose "sum of transfers" differs from its desired net
    //interchange, PDES (see Section 4.1.1.7).

    //Interarea transfer data input is terminated with a record specifying a from area number of zero.

    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);

  end;

  TRaw_Owner = class( TActorDato )

    //4.1.1.16  Owner Data

    //Owner identifiers are specified in owner data records. Data for each owner may be specified either
    //at the time of raw data input or subsequently via activities CHNG or XLIS, or the data editor win-
    //dows. Each owner data record has the following format:

    //      I, 'OWNAME'

    //where:

    I: longint;
    //Owner number (1 through the maximum number of owners at the current size level;
    //see Table P-1).

    OWNAME: string;
    //Alphanumeric identifier assigned to owner I. The name may contain up to twelve
    //characters and must be enclosed in single quotes. OWNAME may be any combi-
    //nation of blanks, uppercase letters, numbers, and special characters. OWNAME is
    //set to twelve blanks by default.

    //Owner data input is terminated with a record specifying an owner number of zero.

    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);

  end;


  TRaw_Facts = class(TactorBiBarra)

    //4.1.1.17  FACTS Device Data

    //Each FACTS (Flexible AC Transmission System) device to be represented in PSS/E is specified in
    //FACTS device data records. Each FACTS device data record has the following format:

    //      N,I,J,MODE,PDES,QDES,VSET,SHMX,TRMX,VTMN,VTMX,VSMX,IMX,LINX,RMPCT,OWNER,SET1,SET2,VSREF

    //where:

    N: longint;        //FACTS device number.

//    I: longint;
    //Sending end bus number, or extended bus name enclosed in single quotes (see
    //Section 4.1.2). No default allowed.

//    J: longint;
    //Terminal end bus number, or extended bus name enclosed in single quotes (see
    //Section 4.1.2); 0 for a STATCON. J = 0 by default.

    NIDi, NIDj: longint;

    MODE: integer;     //Control mode:
    //0 - out-of-service (i.e., series and shunt links open)
    //1 - series and shunt links operating.
    //2 - series link bypassed (i.e., like a zero impedance line) and shunt link operating
    //        as a STATCON.
    //3 - series and shunt links operating with series link at constant series impedance.
    //4 - series and shunt links operating with series link at constant series voltage.
    //5 - "master" device of an IPFC with P and Q setpoints specified; FACTS device
    //       "N+1" must be the "slave" device (i.e., its MODE is 6 or 8) of this IPFC.
    //6  -  "slave" device of an IPFC with P and Q setpoints specified; FACTS device
    //       "N-1" must be the "master" device (i.e., its MODE is 5 or 7) of this IPFC. The
    //       Q setpoint is ignored as the "master" device dictates the active power
    //       exchanged between the two devices.
    //7 - "master" device of an IPFC with constant series voltage setpoints specified;
    //       FACTS device "N+1 must be the "slave" device (i.e., its MODE is 6 or 8) of
    //       this IPFC.
    //8  -  "slave" device of an IPFC with constant series voltage setpoints specified;
    //       FACTS device "N-1" must be the "master" device (i.e., its MODE is 5 or 7) of
    //      this IPFC. The complex Vd + jVq setpoint is modified during power flow
    //      solutions to reflect the active power exchange determined by the "master"
    //      device.
    //If J is specified as 0, MODE must be either 0 or 1. MODE = 1 by default.

    PDES: double;
    //Desired active power flow arriving at the terminal end bus; entered in MW.
    //PDES = 0.0 by default.

    QDES: double;
    //Desired reactive power flow arriving at the terminal end bus; entered in MVAR.
    //QDES = 0.0 by default.

    VSET: double;
    //Voltage setpoint at the sending end bus; entered in pu. VSET = 1.0 by default.

    SHMX: double;
    //Maximum shunt current at the sending end bus; entered in MVA at unity voltage.
    //SHMX = 9999.0 by default.

    TRMX: double;
    //Maximum bridge active power transfer; entered in MW. TRMX = 9999.0 by default.

    VTMN: double;
    //Minimum voltage at the terminal end bus; entered in pu. VTMN = 0.9 by default.

    VTMX: double;
    //Maximum voltage at the terminal end bus; entered in pu. VTMX = 1.1 by default.

    VSMX: double;      //Maximum series voltage; entered in pu. VSMX = 1.0 by default.

    IMX: double;
    //Maximum series current, or zero for no series current limit; entered in MVA at
    //unity voltage. IMX = 0.0 by default.

    LINX: double;
    //Reactance of the dummy series element used during model solution; entered in pu.
    //LINX = 0.05 by default.

    RMPCT: double;
    //Percent of the total Mvar required to hold the voltage at bus I that are to be contrib-
    //uted by the shunt element of this FACTS device; RMPCT must be positive.
    //RMPCT is needed only if  there is more than one local or remote voltage control-
    //ling device (plant, switched shunt, FACTS device shunt element, or VSC dc line
    //converter) controlling the voltage at bus I to a setpoint. RMPCT = 100.0 by default.

    OWNER: integer;
    //Owner number (1 through the maximum number of owners at the current size level;
    //see Table P-1). OWNER = 1 by default.

    SET1, SET2: double;
    //If MODE is 3, resistance and reactance respectively of the constant impedance,
    //entered in pu; if MODE is 4, the magnitude (in pu) and angle (in degrees) of the
    //constant series voltage with respect to the quantity indicated by VSREF; if MODE
    //is 7 or 8, the real (Vd) and imaginary (Vq) components (in pu) of the constant series
    //voltage with respect to the quantity indicated by VSREF; for other values of
    //MODE, SET1 and SET2 are read, but not saved or used during power flow solu-
    //tions. SET1 = 0.0 and SET2 = 0.0 by default.

    VSREF: integer;
    //Series voltage reference code to indicate the series voltage reference of SET1 and
    //SET2 when MODE is 4, 7 or 8: 0 for sending end voltage, 1 for series current.
    //VSREF = 0 by default.

    //An Interline Power Flow Controller (IPFC) is modeled by using two consecutively numbered series
    //FACTS devices. The first of this pair must be assigned as the IPFC "master" device by setting its
    //control mode to 5 or 7, and the second must be assigned as its companion IPFC "slave" device by
    //setting its control mode to 6 or 8. In an IPFC, both devices have a series element but no shunt ele-
    //ment. Therefore, both devices typically have SHMX set to zero, and VSET of both devices is
    //ignored. Conditions at the "master" device define the active power exchange between the two
    //devices.

    //Figure 4-2 shows the PSS/E FACTS control device model with its various setpoints and limits.

    //Each FACTS sending end bus must be a type 1 or 2 bus, and each terminal end bus must be a type
    //1 bus. Refer to Section 4.8.5 for other topological restrictions and for details on the handling of
    //FACTS devices during the power flow solution activities.

    //Further details on FACTS device modeling in power flow solutions are given in Sections 4.8.5 and
    //4.8.7.

    //FACTS device data input is terminated with a record specifying a FACTS device number of zero.


    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);

  end;


  TRaw_Impedancia = class(TActorBiBarra)
    Nombre: string[8];
    z:      NComplex;
    Smax:   NReal;
    Imax:   NReal;
    constructor Create_Init(sala: TSalaFlucar; xNombre: string;
      xNod1, xNod2: integer; xZ: NComplex; xImax: NReal);
    procedure cargue; override;
  end;

  TRaw_Shunt = class(TRaw_Impedancia)
    constructor LoadFromText(sala: TSalaFlucar; var f: textfile);
  end;


procedure leer_barras_raw(sala: TSalaFlucar; var f: textfile);

implementation

constructor TRaw_FixedShunt.LoadFromText(sala: TSalaFlucar; var f: textfile);
var
  r: string;

begin
  inherited Create(sala );
  //if RAW_VER < 32 then raise Exception.Create('Llamada inválida d TRaw_shunt.LoadFromText, RAW_VER: '+IntToStr( RAW_VER  ) );
  //inherited Create;
  readln(f, r);
  I := nextint(r);
  if I <> 0 then
  begin
    ID     := NextPalSinEspacio(r);
    STATUS := nextint(r);
    GL     := nextfloat(r);
    BL     := nextfloat(r);
  end;
end;

procedure TRaw_FixedShunt.cargue;
var
  k: integer;
  y: NComplex;
begin
  if conectada  and  ( self.STATUS > 0 ) then
  begin
    k := Barra_I.jcol;
    y := numc(self.GL / SBASE, -1/self.BL / SBASE )^;
    MatrizAdmitancias.Pon(k, k, y);

    TRaw_Bus( barra_I ).IDE   := 2;
    barra_I.TIPO:=  3;

    TRaw_Bus( barra_I ).QL    := BL;


  end;
end;


constructor TRaw_Impedancia.Create_Init(sala: TSalaFlucar; xNombre: string;
  xNod1, xNod2: integer; xZ: NComplex; xImax: NReal);

begin
  inherited Create(sala);

  Nombre := Copy(xNombre, 1, 8);
  I  := xNod1;
  J  := xNod2;
  Z      := xZ;
  Imax   := xImax;
end;


constructor TRaw_Shunt.LoadFromText(sala: TSalaFlucar; var f: textfile);
var
  r:      string;
  I:      integer;
  ID:     string;  // 2CHAR máx
  STATUS: integer; // O|1
  GL, BL: NReal;   // Pot Activa y Reactiva.

begin
  inherited Create( sala );

  if RAW_VER < 32 then
    raise Exception.Create('Llamada inválida d TRaw_shunt.LoadFromText, RAW_VER: ' +
      IntToStr(RAW_VER));

  readln(f, r);
  I := nextint(r);
  if I <> 0 then
  begin
    ID     := nextpal(r);
    STATUS := nextInt(r);
    GL     := nextfloat(r);
    BL     := nextfloat(r);

    inherited Create_init(sala, ID, I, 0, numc(GL, BL)^, 1e20);
  end;
end;


procedure TRaw_Impedancia.cargue;
begin
  if Barra_I.conectada and Barra_J.Conectada   then
    MatrizAdmitancias.ponY(Barra_I.jcol, Barra_J.jcol, invc( z )^);
end;



constructor TRaw_CaseIdentification.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r, g: string;
  rescod, temp: integer;

begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  ic    := nextint(r);
  sbase := nextfloat(r);
  g     := nextpal(r);
  Val(g, temp, rescod);
  if rescod = 0 then
  begin
    RAW_VER := temp;
  end
  else
  begin
    RAW_VER := 26;
  end;


  //val( r, RAW_VER, rescod );
  //if rescod <> 0 then

  readln(f, ds1);
  readln(f, ds2);

  sala.SBASE:= sbase;
end;

constructor TRaw_Bus.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create(sala);

  r := '';
  readln(f, r);
  I := nextint(r);

  if I <> 0 then
  begin
    Name  := NextPalSinEspacio(r);
    BASKV := nextfloat(r);
    IDE   := abs(nextint(r));

    if RAW_VER < 32 then
    begin
      GL    := nextfloat(r);
      BL    := nextfloat(r);
      AREA  := nextint(r);
      ZONE  := nextint(r);
      VM    := nextfloat(r);
      VA    := nextfloat(r);
      OWNER := nextint(r);
    end
    else
    begin
      AREA  := nextint(r);
      ZONE  := nextint(r);
      OWNER := nextint(r);
      VM    := nextfloat(r);
      VA    := nextfloat(r);

      GL := 0;
      BL := 0;

    end;
  end;
end;



procedure leer_barras_raw(sala: TSalaFlucar; var f: textfile);
var
  barra: TRaw_Bus;

  i: integer;
begin
  barra := TRaw_bus.loadfromtext(sala, f);

  while barra.I <> 0 do
  begin
    //Inc(NBARRAS);
    //writeln(barra.Name);
    case barra.IDE of
      // Load Bus
      1:  Barra.TIPO := 2;
      // Generation or voltage regulator or fixed MVAR
      2:  Barra.TIPO := 3;
      // Swing Bus
      3:  Barra.TIPO := 1;
      // Isolated Bus
      4:  Barra.TIPO := 4
    else
      raise Exception.Create( 'leer_barras_raw; tipo IDE desconocido:'+IntToStr( barra.IDE ));
    end;
    sala.TodasLasBarras.Add(barra);
    sala.actores.add( barra );
    barra := TRaw_bus.loadfromtext(sala, f);
  end;
  barra.Free;
  writeln;
  writeln('ESTO es el fin de las BARRAS ', sala.barras.Count, ' barras completas ',
    sala.TodasLasBarras.Count);
end;


procedure TRaw_Bus.cargue;
var
  k: integer;
  //y: NComplex;
begin

  if not conectada then exit;


  k := jcol;

  //y := numc(self.BL / Sbase, self.GL / Sbase)^;
  //MatAdmitancias.Pon(k, k, y);
  self.PL := self.PL + self.GL;
  self.QL := self.QL + self.BL;

  if self.IDE = 1 then
  begin
    self.VM := self.VM;
    self.VA := self.VA;
  end;

end;


procedure TRaw_Load.cargue;
begin
  if conectada and (STATUS > 0 ) then
  begin
     TRaw_Bus(Barra_I).PL := TRaw_Bus(Barra_I).PL - self.PL;
     TRaw_Bus(Barra_I).QL := TRaw_Bus(Barra_I).QL - self.QL;
  end;
end;

procedure TRaw_Generator.cargue;
begin
  if conectada and (self.STAT > 0) then
  begin
    TRaw_Bus(Barra_I).QMAX:=TRaw_Bus(Barra_I).QMAX +self.QT +TRaw_Bus(Barra_I).QL;
    TRaw_Bus(Barra_I).QMIN:=TRaw_Bus(Barra_I).QMIN +self.QB +TRaw_Bus(Barra_I).QL;

    TRaw_Bus(Barra_I).PL := TRaw_Bus(Barra_I).PL + self.PG;
    TRaw_Bus(Barra_I).QL := TRaw_Bus(Barra_I).QL + self.QG;
    TRaw_Bus(Barra_I).VM:=self.VS;
    TRaw_Bus(Barra_I).QINIT:=self.QG;

  end;
end;

procedure TRaw_Branch.cargue;
var

  n: NComplex;

  modulo: NReal;
  B1, B2,j:    integer;
  Y10, Z12, Y20, Y, Z: NComplex;

begin
  if conectada and (self.ST > 0) then
  begin
    Z12    := numc(self.RR, self.X)^;
    modulo := mod1(z12);
    B1     := Barra_I.jcol;
    B2     := Barra_J.jcol;


    if modulo > 1.01E-4 then
    begin
      if self.RATIO = 0 then
      begin


        Y10 := numc(0, self.B / 2)^;
        Z12 := numc(self.RR, self.X)^;
        Y20 := numc(0, self.B / 2)^;
        MatrizAdmitancias.PonCuadripolo(B1, B2, 0, Y10, Z12, Y20);

        Y := numc(self.GI, self.BI)^;
        MatrizAdmitancias.PonY(B1, 0, Y);

        Y := numc(self.GJ, self.BJ)^;
        MatrizAdmitancias.PonY(B2, 0, Y);
        Y:=MatrizAdmitancias.e(B1,B2);
        Y:=MatrizAdmitancias.e(B1,B1);
        Y:=MatrizAdmitancias.e(B2,B2);
      end
      else
      begin
        z := numc(self.RR, self.X)^;
        Y := invc( z )^;

        n := numc_rofi(self.RATIO, DegToRad( self.ANGLE ) )^; //???????? será el desfasaje del trafo?????
        MatrizAdmitancias.PonTrafoZcc1(B1,B2, Y, 1);//n.r );
        Y := numc(self.GI, self.BI)^;
        MatrizAdmitancias.PonY(B1, 0, Y);
        Y := numc(self.GJ, self.BJ)^;
        MatrizAdmitancias.PonY(B2, 0, Y);

      end;
    end
    else
        begin

        end;

  end;
end;



procedure TRaw_TransformerAdjust.cargue;
var
  B1, B2,i,j: integer;
  Y,YB1, z,YMenos:   NComplex;
  n:      NComplex;
begin
  if conectada and ( STAT > 0 ) then
  begin
    if STAT = 1 then
    begin
      if self.K <> 0 then
        Exception.Create(
          'TRaw_TransformerAdjust.cargue_MY ... Trafo3Bobinados sin implementar ...; name: '
          + Name);
      B1 := self.Barra_I.jcol;
      B2 := self.Barra_J.jcol;
      z  := numc( self.R1_2, self.X1_2 )^;
      if self.COD1=1 then
        n:=numc_rofi( 1, 0 )^
      else
        n  := numc_rofi( self.WINDV1, degToRad( self.ANG1 ) )^;
      Y:=invc(z)^;
      YMenos:=prc(-1/2,Y)^;



      if n.r=1 then
         begin
             MatrizAdmitancias.PonCuadripolo(B1, B2, 0, complex_NULO, z, complex_NULO);
         end
      else
        begin
                 MatrizAdmitancias.PonTrafoZcc1(B1, B2,Y,n.r);
         end;
             YB1 := prc(1/n.r,numc(self.MAG1, self.MAG2)^)^;

             MatrizAdmitancias.PonY(B1, 0, YB1);

    end
    else
      raise Exception.Create(
        'TRaw_TransformerAdjust.Preprarar_paso ... STAT > 1  .. sin implementar ; name: '
        +
        Name);
  end;
end;

procedure TRaw_TwoTerminal_DCLine.cargue;
begin
  raise Exception.Create('TRaw_TwoTerminal_DCLine.cargue_MY ... FALTA IMPLEMENTAR'
    );
  if  not conectada then exit;


end;



constructor TRaw_Load.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    I := nextint(r);
  finally
  end;

  if I <> 0 then
  begin
    ID     := NextPalSinEspacio(r);
    STATUS := nextint(r);
    AREA   := nextint(r);
    ZONE   := nextint(r);
    PL     := nextfloat(r);
    QL     := nextfloat(r);
    IP     := nextfloat(r);
    IQ     := nextfloat(r);
    YP     := nextfloat(r);
    YQ     := nextfloat(r);
    OWNER  := nextint(r);

    if RAW_VER >= 32 then
      SCALE := nextint(r);
    if PL <> 0 then
       QsobreP:=QL/PL
    else
       QsobreP:=0;

    factorZona:=1;

  end;
end;


constructor TRaw_Generator.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    I := nextint(r);
  finally
  end;

  if I <> 0 then
  begin
    ID    := NextPalSinEspacio(r);
    PG    := nextfloat(r);
    QG    := nextfloat(r);
    QT    := nextfloat(r);
    QB    := nextfloat(r);
    VS    := nextfloat(r);
    IREG  := nextint(r);
    MBASE := nextfloat(r);
    ZR    := nextfloat(r);
    ZX    := nextfloat(r);
    RT    := nextfloat(r);
    XT    := nextfloat(r);
    GTAP  := nextfloat(r);
    STAT  := nextint(r);
    RMPCT := nextfloat(r);
    PT    := nextfloat(r);
    PB    := nextfloat(r);

    O_[1] := nextint(r);
    F_[1] := nextfloat(r);

    if (RAW_VER >= 32) and (Length(r) >= 1) then
    begin
      WMOD := nextint(r);
             (*
             0: NO WINDMACHINE
             1: WindMachine con límites de reactiva especificada por QT y QB
             2: WindMachine con límites de reactiva iguales y de magnitudes opuestas, determinados por la potencia ACTIVA y el WPF
             3: WindMachine con límites de reactiva fijos. Si WPF > 0 entonces la reactiva de la máquina tiene el mismo signo que la activa.
             Si WPF < 0 entonces la reactiva tiene signo contrario a la activa.
             *)
      WPF  := nextfloat(r);
      // WindPowerFactor. POr defecto 1. Determina los límites de reactiva según WMOD = 2 o 3.

    end
    else
    begin
      WMOD := 0;
      WPF  := 1;
    end;
  end;

end;


constructor TRaw_Branch.LoadFromtext( sala: TSalaFlucar; var f: Text);
var
  r:   string;
  TEMP, modulo: double;
  Z12: NComplex;
begin
  inherited Create(sala);
  r := '';
  readln(f, r);
  try
    I := nextint(r);
  finally
  end;

  if I <> 0 then
  begin
    J   := abs(nextint(r));
    CKT := NextPalSinEspacio(r);

    RR    := nextfloat(r);
    X     := nextfloat(r);
    B     := nextfloat(r);
    RATEA := nextfloat(r);
    RATEB := nextfloat(r);
    RATEC := nextfloat(r);

    if RAW_VER < 32 then
    begin
      // en la RAW_VER_26 leo el RATIO para ver si es un trafo.
      TEMP := nextfloat(r);
      if TEMP > 0.002 then
      begin
        RATIO := TEMP;
        ANGLE := nextfloat(r);
        GI    := nextfloat(r);
      end
      else
      begin
        RATIO := 0;
        ANGLE := 0;
        GI    := TEMP;
        // OJO ESTO ES UNA MANGANETA ..IMPONE. GI  = TEMP si no es un trafo
        // PERO OJO si GI > 0.002 se confunde y cree que es un trafo.
      end;
      BI := nextfloat(r);
    end
    else
    begin  //esto es para la version 32
      GI := nextfloat(r);
      BI := nextfloat(r);
    end;

    GJ := nextfloat(r);
    BJ := nextfloat(r);
    ST := nextint(r);
    if RAW_VER >= 32 then
    begin
      MET := nextint(r);
    end
    else
      MET := 1;

    LEN   := nextfloat(r);
    O_[1] := nextint(r);
    F_[1] := nextfloat(r);



    Z12    := numc(self.RR, self.X)^;
    modulo := mod1(z12);

  end;

end;


constructor TRaw_TransformerAdjust.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    I := nextint(r);
  finally
  end;

  if I <> 0 then
    if RAW_VER = 26 then
    begin
      J     := abs(nextint(r));
      CKT   := NextPalSinEspacio(r);
      ICONT := nextint(r);
      RMA   := nextfloat(r);
      RMI   := nextfloat(r);
      VMA   := nextfloat(r);
      VMI   := nextfloat(r);
      STEP  := nextfloat(r);
      TABLE := nextint(r);
      CNTRL := nextint(r);
      CR    := nextfloat(r);
      CX    := nextfloat(r);
      COD1  := 1;
      STAT  := 1;
    end
    else
    begin     //leo los datos de la version 32
      J := abs(nextint(r));
      K := abs(nextint(r));
      if K = 0 then
      begin  // leo los datos para 2 devanados
        CKT    := NextPalSinEspacio(r);
        CW     := nextint(r);
        CZ     := nextint(r);
        CM     := nextint(r);
        MAG1   := nextfloat(r);
        MAG2   := nextfloat(r);
        NMETR  := nextint(r);
        Name   := NextPalSinEspacio(r);
        STAT   := nextint(r);
        Oi_[1] := nextint(r);
        Fi_[1] := nextfloat(r);
        // leo la proxima linea
        readln(f, r);
        R1_2     := nextfloat(r);
        X1_2     := nextfloat(r);
        SBASE1_2 := nextfloat(r);
        // leo la proxima linea
        readln(f, r);
        WINDV1 := nextfloat(r);
        NOMV1  := nextfloat(r);
        ANG1   := nextfloat(r);
        RATA1  := nextfloat(r);
        RATB1  := nextfloat(r);
        RATC1  := nextfloat(r);
        COD1   := nextint(r);
        CONT1  := nextint(r);
        RMA1   := nextfloat(r);
        RMI1   := nextfloat(r);
        VMA1   := nextfloat(r);
        VMI1   := nextfloat(r);
        NTP1   := nextint(r);
        TAB1   := nextint(r);
        CR1    := nextfloat(r);
        CX1    := nextfloat(r);
        // leo la proxima linea
        readln(f, r);
        WINDV2 := nextfloat(r);
        NOMV2  := nextfloat(r);
        CNTRL  :=COD1;
      end
      else
      begin
        CKT    := NextPalSinEspacio(r);
        CW     := nextint(r);
        CZ     := nextint(r);
        CM     := nextint(r);
        MAG1   := nextfloat(r);
        MAG2   := nextfloat(r);
        NMETR  := nextint(r);
        Name   := NextPalSinEspacio(r);
        STAT   := nextint(r);
        Oi_[1] := nextint(r);
        Fi_[1] := nextfloat(r);
        // leo la proxima linea
        readln(f, r);
        R1_2     := nextfloat(r);
        X1_2     := nextfloat(r);
        SBASE1_2 := nextfloat(r);
        // leo la proxima linea
        readln(f, r);
        WINDV1 := nextfloat(r);
        NOMV1  := nextfloat(r);
        ANG1   := nextfloat(r);
        RATA1  := nextfloat(r);
        RATB1  := nextfloat(r);
        RATC1  := nextfloat(r);
        COD1   := nextint(r);
        CONT1  := nextint(r);
        RMA1   := nextfloat(r);
        RMI1   := nextfloat(r);
        VMA1   := nextfloat(r);
        VMI1   := nextfloat(r);
        NTP1   := nextint(r);
        TAB1   := nextint(r);
        CR1    := nextfloat(r);
        CX1    := nextfloat(r);
        // leo la proxima linea
        readln(f, r);
        WINDV2 := nextfloat(r);
        NOMV2  := nextfloat(r);
      end;
    end;

end;


constructor TRaw_AreaInterchange.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    I := nextint(r);
  finally
  end;

  if I <> 0 then
  begin
    ISW    := nextint(r);
    PDES   := nextfloat(r);
    PTOL   := nextfloat(r);
    ARNAME := NextPalSinEspacio(r);

  end;

end;



constructor TRaw_TwoTerminal_DCLine.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r, g, fin: string;
  rescod, temp, k1: integer;

begin
  inherited Create( sala );
  r := '';
  readln(f, r);

  k1  := length(r);
  fin := copy(r, 1, 1);
  r   := copy(r, 2, k1 - 1);
  g   := NextPal(r);
  Val(g, temp, rescod);
  if rescod = 0 then
  begin
    I    := temp;
    Name := g;
  end
  else
  begin
    I    := 0;
    Name := '0';
  end;

  if I <> 0 then
  begin
    raise Exception.Create('TRaw_TwoTerminal_DCLine. (FALTA IMPLEMENTAR)' );
    //completar
  g:=NextPalSinEspacio(r);

    readln(f, r);
    readln(f, r);
  end;

end;

constructor TRaw_SwitcheShunt.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
  j: integer;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  I := nextint(r);
  if I <> 0 then
  begin
    MODSW  := nextint(r);
    if RAW_VER = 32 then
    begin
      ADJM := nextint(r);
      STAT := nextint(r);
    end
    else
    begin
      ADJM := 0;
      STAT := 1;
    end;
    VSWHI := nextfloat(r);
    VSWLO := nextfloat(r);
    SWREM := nextint(r);
    if RAW_VER = 32 then
    begin
      RMPCT  := nextfloat(r);
      RMIDNT := NextPalsinespacio(r);
    end
    else
    begin
      RMPCT  := 100;
      RMIDNT := '';
    end;
    BINIT := nextfloat(r);
    j     := 1;
    QINIT := BINIT;
    QMIN  := 0;
    QMAX  := 0;
    while r <> '' do
    begin
      Ni_[j] := nextint(r);
      Bi_[j] := nextfloat(r);
      Inc(j);
      if Bi_[j] < 0 then
        QMIN := QMIN + Bi_[j] * Ni_[j]
      else
        QMAX := QMAX + Bi_[j] * Ni_[j];
    end;
  end;
end;

procedure TRaw_SwitcheShunt.cargue;

begin
  if  not conectada then exit;
  
  //writeln(self.MODSW < 1);

  if self.STAT > 0 then
  begin
    if self.MODSW < 1 then
    begin
      TRaw_Bus( barra_I ).QINIT := QINIT;
      TRaw_Bus( barra_I ).QMAX  := QINIT;
      TRaw_Bus( barra_I ).QMIN  := QINIT;
    end
    else
    begin
      TRaw_Bus( barra_I ).IDE   := 2;
      barra_I.TIPO:=  3;
      
      TRaw_Bus( barra_I ).QINIT:= QINIT;
      TRaw_Bus( barra_I ).QMAX  := QMAX;
      TRaw_Bus( barra_I ).QMIN  := QMIN;
      TRaw_Bus( barra_I ).QL    := QINIT;
    end;
  end;
end;


constructor TRaw_TransformerImpedanceCorrectionTables.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    I := nextint(r);
  finally
  end;

  if I <> 0 then
  begin
    raise Exception.Create( 'TRaw_TransformerImpedanceCorrectionTables. (FALTA IMPLEMENTAR)' );
    //completar
  end;

end;

constructor TRaw_MultiTerminal_DCLine.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    I := nextint(r);
  finally
  end;

  if I <> 0 then
  begin
    //completar
    raise Exception.Create( 'TRaw_MultiTerminal_DCLine. (FALTA IMPLEMENTAR)');
  end;

end;

constructor TRaw_MultiSectionLineGrouping.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    I := nextint(r);
  finally
  end;

  if I <> 0 then
  begin
    //completar
    //raise Exception.Create( 'TRaw_MultiSectionLineGrouping.. (FALTA IMPLEMENTAR)');
  end;

end;


constructor TRaw_Zone.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    I := nextint(r);
  finally
  end;

  if I <> 0 then
  begin
    ZONAME := NextPalSinEspacio(r);
  end;

end;


constructor TRaw_InterAreaTransfer.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    ARFROM := nextint(r);
  finally
  end;

  if ARFROM <> 0 then
  begin
    //completar
    //raise Exception.Create( 'TRaw_InterAreaTransfer. (FALTA IMPLEMENTAR)' );
  end;

end;


constructor TRaw_Owner.LoadFromtext( sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    I := nextint(r);
  finally
  end;

  if I <> 0 then
  begin
    OWNAME := NextPalSinEspacio(r);
  end;

end;


constructor TRaw_Facts.LoadFromtext(sala: TSalaFlucar; var f: Text);
var
  r: string;
begin
  inherited Create( sala );
  r := '';
  readln(f, r);
  try
    N := nextint(r);
  finally
  end;

  if N <> 0 then
  begin
    //completar
    raise Exception.Create( 'TRaw_Facts. (FALTA IMPLEMENTAR) ' );
  end;

end;


procedure TRaw_Branch.Calculo_potencias(var S12, S21, Sconsumida, I: NComplex);
var
  I1, I2, I12, I21, V1, V2, Y13, Y12, Y21,Z12, I0, Y23,pq,tempo,res: NComplex;
  n, t,n2: NReal;
  inodo, jnodo,knodo,nodo_extremo:integer;
begin
       Y13:=numc(0,self.B/2)^;
       Z12:=numc(self.RR,self.X)^;
       Y12:=invc(Z12)^;
       Y23:=numc(0,self.B/2)^;
       n:= self.RATIO;
       if n<>0 then
         t:=n;
       inodo:=TRaw_Bus(Barra_I).jcol;
       jnodo:=TRaw_Bus(Barra_J).jcol;
       V1 := numc_rofi(TRaw_Bus(Barra_I).VM,  DegtoRad(TRaw_Bus(Barra_I).VA ))^;
       V2 := numc_rofi(TRaw_Bus(Barra_J).VM,  DegtoRad(TRaw_Bus(Barra_J).VA ))^;
  res:= complex_NULO;
  // corriente por la rama si no es un regulador
    if  (not(Sala.nodos_regulados.Find(TRaw_Bus(Sala.Barras[(inodo-1)]).I) > -1) or not (Sala.nodos_reguladores.find(TRaw_Bus(Sala.Barras[(inodo-1)]).I) > -1)) then
    begin
                I12:= pc(rc(V1, V2)^,invc(Z12)^)^;{(V1-V2)/Z12}
                I1:=pc(V1,Y13)^;
		I12:=sc(I12,I1)^;
		S12:=pc(V1,cc(I12)^)^;
		I21:= pc(rc(V2, V1)^,invc(Z12)^)^;{(V1-V2)/Z12}
		I2:=pc(V2,Y23)^;
		I21:=sc(I21,I2)^;
		S21:=pc(V2,cc(I21)^)^;
    end;
  // corriente por la rama si el nodo inicio es regulado
    if (Sala.nodos_regulados.Find(TRaw_Bus(Sala.Barras[(inodo-1)]).I) > -1) and (Sala.nodos_reguladores.Find(TRaw_Bus(Sala.Barras[(jnodo-1)]).I) > -1) then
      begin
        I12:=sc(prc(1/(t*t),pc(V1,Y12)^)^,prc(-1/(t),pc(V2,Y12)^)^)^;
        I21:=sc(pc(V2,Y12)^,prc(-1/(t),pc(V1,Y12)^)^)^;
        S12:=pc(V1,I12)^;
        S21:=pc(V2,I21)^;
      end;
  // corriente por la rama si el nodo es regulador
   if (Sala.nodos_reguladores.Find(TRaw_Bus(Sala.Barras[(inodo-1)]).I) > -1) and (Sala.nodos_regulados.Find(TRaw_Bus(Sala.Barras[(jnodo-1)]).I) > -1) then
      begin
        I12:=cc(sc(prc(1/(t*t),pc(V1,Y12)^)^,prc(-1/(t),pc(V2,Y12)^)^)^)^;
        I21:=cc(sc(pc(V2,Y12)^,prc(-1/(t),pc(V1,Y12)^)^)^)^;
        S12:=pc(V1,I12)^;
        S21:=pc(V2,I21)^;
      end;

   Sconsumida:=sc(S12,S21)^; {C lculo de la potencia consumida
			en el cuadripolo}
   if mod1(I12)>mod1(I21) then I:=I12 else I:=I21;
end;

procedure TRaw_TransformerAdjust.Calculo_potencias(var S12, S21, Sconsumida, I: NComplex);
var
  I1, I2, I12, I21, V1, V2, Y13, Y12, Y21,Z12, I0, Y23,pq,tempo,res: NComplex;
  n, t,n2: NReal;
  inodo, jnodo,knodo,nodo_extremo:integer;
begin
       Y13:=numc(0,0)^;
       Z12:=numc(self.R1_2,self.X1_2)^;
       Y12:=invc(Z12)^;
       Y23:=numc(0,0)^;
       n:= self.WINDV1;
       if n<>0 then
         t:=n;
       inodo:=TRaw_Bus(Barra_I).jcol;
       jnodo:=TRaw_Bus(Barra_J).jcol;
       V1 := numc_rofi(TRaw_Bus(Barra_I).VM,  DegtoRad(TRaw_Bus(Barra_I).VA ))^;
       V2 := numc_rofi(TRaw_Bus(Barra_J).VM,  DegtoRad(TRaw_Bus(Barra_J).VA ))^;
  res:= complex_NULO;
  // corriente por la rama si no es un regulador
    if  (not(Sala.nodos_regulados.Find(TRaw_Bus(Sala.Barras[(inodo-1)]).I) > -1) or not (Sala.nodos_reguladores.find(TRaw_Bus(Sala.Barras[(inodo-1)]).I) > -1)) then
    begin
      Y13:=prc((1-t)/(t*t),invc(Z12)^)^;
      Y12:=prc(1/t,invc(Z12)^)^;
      Y23:=prc((t-1)/t,invc(Z12)^)^;

      I12:= pc(rc(V1, V2)^,Y12)^;{(V1-V2)/Z12}
      I1:=pc(V1,Y13)^;
      I12:=sc(I12,I1)^;
      S12:=pc(V1,cc(I12)^)^;
      I21:= pc(rc(V2, V1)^,Y12)^;{(V1-V2)/Z12}
      I2:=pc(V2,Y23)^;
      I21:=sc(I21,I2)^;
      S21:=pc(V2,cc(I21)^)^;
    end;
  // corriente por la rama si el nodo inicio es regulado
    if (Sala.nodos_regulados.Find(TRaw_Bus(Sala.Barras[(inodo-1)]).I) > -1) and (Sala.nodos_reguladores.Find(TRaw_Bus(Sala.Barras[(jnodo-1)]).I) > -1) then
      begin
        I12:=sc(prc(1/(t*t),pc(V1,Y12)^)^,prc(-1/(t),pc(V2,Y12)^)^)^;
        I21:=sc(pc(V2,Y12)^,prc(-1/(t),pc(V1,Y12)^)^)^;
        S12:=pc(V1,I12)^;
        S21:=pc(V2,I21)^;
      end;
  // corriente por la rama si el nodo es regulador
   if (Sala.nodos_reguladores.Find(TRaw_Bus(Sala.Barras[(inodo-1)]).I) > -1) and (Sala.nodos_regulados.Find(TRaw_Bus(Sala.Barras[(jnodo-1)]).I) > -1) then
      begin
        I12:=cc(sc(prc(1/(t*t),pc(V1,Y12)^)^,prc(-1/(t),pc(V2,Y12)^)^)^)^;
        I21:=cc(sc(pc(V2,Y12)^,prc(-1/(t),pc(V1,Y12)^)^)^)^;
        S12:=pc(V1,I12)^;
        S21:=pc(V2,I21)^;
      end;

   Sconsumida:=sc(S12,S21)^; {C lculo de la potencia consumida
			en el cuadripolo}
   if mod1(I12)>mod1(I21) then I:=I12 else I:=I21;
end;
//Hasta aca van todos los constructores




end.

