Class {
	#name : #ISOLanguageDefinition,
	#superclass : #Object,
	#instVars : [
		'iso3',
		'iso2',
		'iso3Alternate',
		'language'
	],
	#classVars : [
		'ISO2Countries',
		'ISO2Table',
		'ISO3Countries',
		'ISO3Table'
	],
	#category : #'System-Localization'
}

{ #category : #private }
ISOLanguageDefinition class >> buildIso3166CodesTables [
	"ISOLanguageDefinition buildIso3166CodesTables"
	| rawdata stream country isoa2 isoa3 unNumeric macName macCode windowsName windowsCode empty table |
	rawdata := self iso3166Codes.
	table := OrderedCollection new: 200. 
	stream := rawdata readStream.
	empty := 160 asCharacter asString.
	[stream atEnd] whileFalse: 
		[country := stream nextLine.
		isoa2 := stream nextLine.
		isoa3 := stream nextLine.
		unNumeric := stream nextLine.
		windowsName := stream nextLine.
		windowsName = empty ifTrue: [windowsName := nil].
		windowsCode := stream nextLine. 
		windowsCode = empty ifTrue: [windowsCode := nil].
		macName := stream nextLine.
		macName = empty ifTrue: [macName := nil].
		macCode := stream nextLine.
		macCode = empty ifTrue: [macCode := nil].
		table add: { country.  isoa2. isoa3.  unNumeric. windowsName.  windowsCode.  macName. macCode. }].
	^table
]

{ #category : #private }
ISOLanguageDefinition class >> extraCountryDefinitions [
	^{
	{'Kids'. 'KIDS'. 'KIDS'.}.
	}
]

{ #category : #private }
ISOLanguageDefinition class >> extraISO3Definitions [

	^self readISOLanguagesFrom: 'jpk		Japanese (Kids)
' readStream
]

{ #category : #private }
ISOLanguageDefinition class >> initISO3LanguageTable [
	"ISOLanguageDefinition initIso3LanguageTable"

	| table |
	table := ISOLanguageDefinition readISOLanguagesFrom: ISOLanguageDefinition isoLanguages readStream.
	table addAll: self extraISO3Definitions.
	^table
]

{ #category : #private }
ISOLanguageDefinition class >> initISOCountries [
	"ISOLanguageDefinition initISOCountries"
	| iso3166Table |
	iso3166Table := ISOLanguageDefinition buildIso3166CodesTables.
	ISO2Countries := Dictionary new.
	ISO3Countries := Dictionary new.
	iso3166Table do: [:entry | 
		ISO2Countries at: (entry at: 2) put: (entry at: 1).
		ISO3Countries at: (entry at: 3) put: (entry at: 1)].
	self extraCountryDefinitions do: [:entry | 
		ISO2Countries at: (entry at: 2) put: (entry at: 1).
		ISO3Countries at: (entry at: 3) put: (entry at: 1)]
]

{ #category : #'class initialization' }
ISOLanguageDefinition class >> initialize [
	"ISOLanguageDefinition initialize"

	ISO3Table := nil.
	ISO2Table := nil
]

{ #category : #private }
ISOLanguageDefinition class >> iso2Countries [
	"ISOLanguageDefinition iso2Countries"
	"ISO2Countries := nil. ISO3Countries := nil"

	ISO2Countries ifNil: [self initISOCountries].
	^ISO2Countries
]

{ #category : #accessing }
ISOLanguageDefinition class >> iso2LanguageDefinition: aString [
	^self iso2LanguageTable at: aString
]

{ #category : #private }
ISOLanguageDefinition class >> iso2LanguageTable [
	"ISOLanguageDefinition iso2LanguageTable"

	ISO2Table ifNotNil: [^ISO2Table].
	ISO2Table := Dictionary new: self iso3LanguageTable basicSize.
	self iso3LanguageTable do: [:entry |
		ISO2Table at: entry iso2 put: entry].
	^ISO2Table
]

{ #category : #private }
ISOLanguageDefinition class >> iso3166Codes [
"http://www.unicode.org/onlinedat/countries.html"

^'­LAND ISLANDS
AX






AFGHANISTAN
AF
AFG
004




ALBANIA
AL
ALB
008
CTRY_ALBANIA
355


ALGERIA
DZ
DZA
012
CTRY_ALGERIA
213
verArabic
16
AMERICAN SAMOA
AS
ASM
016




ANDORRA
AD
AND
020




ANGOLA
AO
AGO
024




ANGUILLA
AI
AIA
660




ANTARCTICA
AQ
ATA
010




ANTIGUA AND BARBUDA
AG
ATG
028




ARGENTINA
AR
ARG
032
CTRY_ARGENTINA
54


ARMENIA
AM
ARM
051
CTRY_ARMENIA
374
verArmenian
84
ARUBA
AW
ABW
533




AUSTRALIA
AU
AUS
036
CTRY_AUSTRALIA
61
verAustralia
15
AUSTRIA
AT
AUT
040
CTRY_AUSTRIA
43
verAustria
92
AZERBAIJAN
AZ
AZE
031
CTRY_AZERBAIJAN
994


BAHAMAS
BS
BHS
044




BAHRAIN
BH
BHR
048
CTRY_BAHRAIN
973


BANGLADESH
BD
BGD
050


verBengali
60
BARBADOS
BB
BRB
052




BELARUS
BY
BLR
112
CTRY_BELARUS
375


BELGIUM
BE
BEL
056
CTRY_BELGIUM
32
verFrBelgium, verFlemish
98
BELIZE
BZ
BLZ
084
CTRY_BELIZE
501


BENIN
BJ
BEN
204




BERMUDA
BM
BMU
060




BHUTAN
BT
BTN
064


verBhutan
83
BOLIVIA
BO
BOL
068
CTRY_BOLIVIA
591


BOSNIA AND HERZEGOVINA
BA
BIH
070




BOTSWANA
BW
BWA
072




BOUVET ISLAND
BV
BVT
074




BRAZIL
BR
BRA
076
CTRY_BRAZIL
55
verBrazil
71
BRITISH INDIAN OCEAN TERRITORY
IO
IOT
086




BRUNEI DARUSSALAM
BN
BRN
096
CTRY_BRUNEI_DARUSSALAM
673


BULGARIA
BG
BGR
100
CTRY_BULGARIA
359
verBulgaria
72
BURKINA FASO
BF
BFA
854




BURUNDI
BI
BDI
108




CAMBODIA
KH
KHM
116




CAMEROON
CM
CMR
120




CANADA
CA
CAN
124
CTRY_CANADA
2
verFrCanada, verEndCanada
82
CAPE VERDE
CV
CPV
132




CAYMAN ISLANDS
KY
CYM
136




CENTRAL AFRICAN REPUBLIC
CF
CAF
140




CHAD
TD
TCD
148




CHILE
CL
CHL
152
CTRY_CHILE
56


CHINA
CN
CHN
156
CTRY_PRCHINA
86
verChina
52
CHRISTMAS ISLAND
CX
CXR
162




COCOS (KEELING) ISLANDS
CC
CCK
166




COLOMBIA
CO
COL
170
CTRY_COLOMBIA
57


COMOROS
KM
COM
174




CONGO
CG
COG
178




CONGO, THE DEMOCRATIC REPUBLIC OF THE
CD






COOK ISLANDS
CK
COK
184




COSTA RICA
CR
CRI
188
CTRY_COSTA_RICA
506


COTE D''IVOIRE
CI
CIV
384




CROATIA (local name: Hrvatska)
HR
HRV
191
CTRY_CROATIA
385
verCroatia, verYugoCroatian
68 (c), 25 (y)
CUBA
CU
CUB
192




CYPRUS
CY
CYP
196


verCyprus
23
CZECH REPUBLIC
CZ
CZE
203
CTRY_CZECH
420
verCzech
56
DENMARK
DK
DNK
208
CTRY_DENMARK
45
verDenmark(da), verFaeroeIsl(fo)
9(da), 47(fo)
DJIBOUTI
DJ
DJI
262




DOMINICA
DM
DMA
212




DOMINICAN REPUBLIC
DO
DOM
214
CTRY_DOMINICAN_REPUBLIC
1


EAST TIMOR
TL
TLS
626




ECUADOR
EC
ECU
218
CTRY_ECUADOR
593


EGYPT
EG
EGY
818
CTRY_EGYPT
20
verArabic
16
EL SALVADOR
SV
SLV
222
CTRY_EL_SALVADOR
503


EQUATORIAL GUINEA
GQ
GNQ
226




ERITREA
ER
ERI
232




ESTONIA
EE
EST
233
CTRY_ESTONIA
372
verEstonia
44
ETHIOPIA
ET
ETH
210




FALKLAND ISLANDS (MALVINAS)
FK
FLK
238




FAROE ISLANDS
FO
FRO
234
CTRY_FAEROE_ISLANDS
298


FIJI
FJ
FJI
242




FINLAND
FI
FIN
246
CTRY_FINLAND
358
verFinland
17
FRANCE
FR
FRA
250
CTRY_FRANCE
33
verFrance
1
FRANCE, METROPOLITAN
FX
FXX
249




FRENCH GUIANA
GF
GUF
254




FRENCH POLYNESIA
PF
PYF
258




FRENCH SOUTHERN TERRITORIES
TF
ATF
260




GABON
GA
GAB
266




GAMBIA
GM
GMB
270




GEORGIA
GE
GEO
268
CTRY_GEORGIA
995
verGeorgian
85
GERMANY
DE
DEU
276
CTRY_GERMANY
49
verGermany
3
GHANA
GH
GHA
288




GIBRALTAR
GI
GIB
292




GREECE
GR
GRC
300
CTRY_GREECE
30
verGreece, verGreecePoly
20, 40
GREENLAND
GL
GRL
304


verGreenland
107
GRENADA
GD
GRD
308




GUADELOUPE
GP
GLP
312




GUAM
GU
GUM
316




GUATEMALA
GT
GTM
320
CTRY_GUATEMALA
502


GUINEA
GN
GIN
324




GUINEA-BISSAU
GW
GNB
624




GUYANA
GY
GUY
328




HAITI
HT
HTI
332




HEARD ISLAND & MCDONALD ISLANDS
HM
HMD
334




HONDURAS
HN
HND
340
CTRY_HONDURAS
504


HONG KONG
HK
HKG
344
CTRY_HONG_KONG
852


HUNGARY
HU
HUN
348
CTRY_HUNGARY
36
verHungary
43
ICELAND
IS
ISL
352
CTRY_ICELAND
354
verIceland
21
INDIA
IN
IND
356
CTRY_INDIA
91
verIndiaHindi(hi)
33
INDONESIA
ID
IDN
360
CTRY_INDONESIA
62


IRAN, ISLAMIC REPUBLIC OF
IR
IRN
364
CTRY_IRAN
981
verIran
48
IRAQ
IQ
IRQ
368
CTRY_IRAQ
964
verArabic
16
IRELAND
IE
IRL
372
CTRY_IRELAND
353
verIreland
50
ISRAEL
IL
ISR
376
CTRY_ISRAEL
972
verIsrael
13
ITALY
IT
ITA
380
CTRY_ITALY
39
verItaly
4
JAMAICA
JM
JAM
388
CTRY_JAMAICA
1


JAPAN
JP
JPN
392
CTRY_JAPAN
81
verJapan
14
JORDAN
JO
JOR
400
CTRY_JORDAN
962


KAZAKHSTAN
KZ
KAZ
398
CTRY_KAZAKSTAN
7


KENYA
KE
KEN
404
CTRY_KENYA
254


KIRIBATI
KI
KIR
296




KOREA, DEMOCRATIC PEOPLE''S REPUBLIC OF
KP
PRK
408


verKorea
51
KOREA, REPUBLIC OF
KR
KOR
410
CTRY_SOUTH_KOREA
82
verKorea

KUWAIT
KW
KWT
414
CTRY_KUWAIT
965


KYRGYZSTAN
KG
KGZ
417
CTRY_KYRGYZSTAN
996


LAO PEOPLE''S DEMOCRATIC REPUBLIC
LA
LAO
418




LATVIA
LV
LVA
428
CTRY_LATVIA
371
verLatvia
45
LEBANON
LB
LBN
422
CTRY_LEBANON
961


LESOTHO
LS
LSO
426




LIBERIA
LR
LBR
430




LIBYAN ARAB JAMAHIRIYA
LY
LBY
434
CTRY_LIBYA
218
verArabic
16
LIECHTENSTEIN
LI
LIE
438
CTRY_LIECHTENSTEIN
41


LITHUANIA
LT
LTU
440
CTRY_LITHUANIA
370
verLithuania
41
LUXEMBOURG
LU
LUX
442
CTRY_LUXEMBOURG
352
verFrBelgiumLux
6
MACAU
MO
MAC
446
CTRY_MACAU
853


MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF
MK
MKD
807
CTRY_MACEDONIA
389
verMacedonian

MADAGASCAR
MG
MDG
450




MALAWI
MW
MWI
454




MALAYSIA
MY
MYS
458
CTRY_MALAYSIA
60


MALDIVES
MV
MDV
462
CTRY_MALDIVES
960


MALI
ML
MLI
466




MALTA
MT
MLT
470


verMalta
22
MARSHALL ISLANDS
MH
MHL
584




MARTINIQUE
MQ
MTQ
474




MAURITANIA
MR
MRT
478




MAURITIUS
MU
MUS
480




MAYOTTE
YT
MYT
175




MEXICO
MX
MEX
484
CTRY_MEXICO
52


MICRONESIA, FEDERATED STATES OF
FM
FSM
583




MOLDOVA, REPUBLIC OF
MD
MDA
498




MONACO
MC
MCO
492
CTRY_MONACO
33


MONGOLIA
MN
MNG
496
CTRY_MONGOLIA
976


MONTSERRAT
MS
MSR
500




MOROCCO
MA
MAR
504
CTRY_MOROCCO
212
verArabic
16
MOZAMBIQUE
MZ
MOZ
508




MYANMAR
MM
MMR
104




NAMIBIA
NA
NAM
516




NAURU
NR
NRU
520




NEPAL
NP
NPL
524


verNepal
106
NETHERLANDS
NL
NLD
528
CTRY_NETHERLANDS
31
verNetherlands
5
NETHERLANDS ANTILLES
AN
ANT
530




NEW CALEDONIA
NC
NCL
540




NEW ZEALAND
NZ
NZL
554
CTRY_NEW_ZEALAND
64


NICARAGUA
NI
NIC
558
CTRY_NICARAGUA
505


NIGER
NE
NER
562




NIGERIA
NG
NGA
566




NIUE
NU
NIU
570




NORFOLK ISLAND
NF
NFK
574




NORTHERN MARIANA ISLANDS
MP
MNP
580




NORWAY
NO
NOR
578
CTRY_NORWAY
47
verNorway
12
OMAN
OM
OMN
512
CTRY_OMAN
968


PAKISTAN
PK
PAK
586
CTRY_PAKISTAN
92
verPakistanUrdu, verPunjabi
34 (U), 95 (P)
PALAU
PW
PLW
585




PANAMA
PA
PAN
591
CTRY_PANAMA
507


PALESTINIAN TERRITORY, OCCUPIED
PS






PAPUA NEW GUINEA
PG
PNG
598




PARAGUAY
PY
PRY
600
CTRY_PARAGUAY
595


PERU
PE
PER
604
CTRY_PERU
51


PHILIPPINES
PH
PHL
608
CTRY_PHILIPPINES
63


PITCAIRN
PN
PCN
612




POLAND
PL
POL
616
CTRY_POLAND
48
verPoland
42
PORTUGAL
PT
PRT
620
CTRY_PORTUGAL
351
verPortugal
10
PUERTO RICO
PR
PRI
630
CTRY_PUERTO_RICO
1


QATAR
QA
QAT
634
CTRY_QATAR
974


REUNION
RE
REU
638




ROMANIA
RO
ROU*
642
CTRY_ROMANIA
40
verRomania
39
RUSSIAN FEDERATION
RU
RUS
643
CTRY_RUSSIA
7
verRussia
49
RWANDA
RW
RWA
646




SAINT KITTS AND NEVIS
KN
KNA
659




SAINT LUCIA
LC
LCA
662




SAINT VINCENT AND THE GRENADINES
VC
VCT
670




SAMOA
WS
WSM
882




SAN MARINO
SM
SMR
674




SAO TOME AND PRINCIPE
ST
STP
678




SAUDI ARABIA
SA
SAU
682
CTRY_SAUDI_ARABIA
966
verArabic
16
SENEGAL
SN
SEN
686




SERBIA AND MONTENEGRO
CS


CTRY_SERBIA
381


SEYCHELLES
SC
SYC
690




SIERRA LEONE
SL
SLE
694




SINGAPORE
SG
SGP
702
CTRY_SINGAPORE
65
verSingapore
100
SLOVAKIA (Slovak Republic)
SK
SVK
703
CTRY_SLOVAK
421
verSlovak
57
SLOVENIA
SI
SVN
705
CTRY_SLOVENIA
386
verSlovenian
66
SOLOMON ISLANDS
SB
SLB
90




SOMALIA
SO
SOM
706




SOUTH AFRICA
ZA
ZAF
710
CTRY_SOUTH_AFRICA
27


SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS
GS






SPAIN
ES
ESP
724
CTRY_SPAIN
34
verSpain
8
SRI LANKA
LK
LKA
144




SAINT HELENA
SH
SHN
654




SAINT PIERRE AND MIQUELON
PM
SPM
666




SUDAN
SD
SDN
736




SURINAME
SR
SUR
740




SVALBARD AND JAN MAYEN ISLANDS
SJ
SJM
744




SWAZILAND
SZ
SWZ
748




SWEDEN
SE
SWE
752
CTRY_SWEDEN
46
verSweden
7
SWITZERLAND
CH
CHE
756
CTRY_SWITZERLAND
41
verFrSwiss(fr), verGrSwiss(de)
18(fr), 19(de)
SYRIAN ARAB REPUBLIC
SY
SYR
760
CTRY_SYRIA
963


TAIWAN, PROVINCE OF CHINA
TW
TWN
158
CTRY_TAIWAN
886
verTaiwan
53
TAJIKISTAN
TJ
TJK
762




TANZANIA, UNITED REPUBLIC OF
TZ
TZA
834




TATARSTAN



CTRY_TATARSTAN
7


THAILAND
TH
THA
764
CTRY_THAILAND
66
verThailand
54
TIMOR-LESTE
TL






TOGO
TG
TGO
768




TOKELAU
TK
TKL
772




TONGA
TO
TON
776


verTonga
88
TRINIDAD AND TOBAGO
TT
TTO
780
CTRY_TRINIDAD_Y_TOBAGO
1


TUNISIA
TN
TUN
788
CTRY_TUNISIA
216
verArabic
16
TURKEY
TR
TUR
792
CTRY_TURKEY
90
verTurkey
24
TURKMENISTAN
TM
TKM
795




TURKS AND CAICOS ISLANDS
TC
TCA
796




TUVALU
TV
TUV
798




UGANDA
UG
UGA
800




UKRAINE
UA
UKR
804
CTRY_UKRAINE
380
verUkraine
62
UNITED ARAB EMIRATES
AE
ARE
784
CTRY_UAE
971


UNITED KINGDOM
GB
GBR
826
CTRY_UNITED_KINGDOM
44
verBritain
2
UNITED STATES
US
USA
840
CTRY_UNITED_STATES
1
verUS
0
UNITED STATES MINOR OUTLYING ISLANDS
UM
UMI
581




URUGUAY
UY
URY
858
CTRY_URUGUAY
598


UZBEKISTAN
UZ
UZB
860
CTRY_UZBEKISTAN
7


VANUATU
VU
VUT
548




VATICAN CITY STATE (HOLY SEE)
VA
VAT
336




VENEZUELA
VE
VEN
862
CTRY_VENEZUELA
58


VIET NAM
VN
VNM
704
CTRY_VIET_NAM
84
verVietnam

VIRGIN ISLANDS (BRITISH)
VG
VGB
92




VIRGIN ISLANDS (U.S.)
VI
VIR
850




WALLIS AND FUTUNA ISLANDS
WF
WLF
876




WESTERN SAHARA
EH
ESH
732




YEMEN
YE
YEM
887
CTRY_YEMEN
967


YUGOSLAVIA
YU
YUG
891




ZAIRE
ZR
ZAR
180




ZAMBIA
ZM
ZMB
894




ZIMBABWE
ZW
ZWE
716
CTRY_ZIMBABWE
263


'
]

{ #category : #private }
ISOLanguageDefinition class >> iso3Countries [
	"ISOLanguageDefinition iso3Countries"
	"ISO2Countries := nil. ISO3Countries := nil"

	ISO3Countries ifNil: [self initISOCountries].
	^ISO3Countries
]

{ #category : #accessing }
ISOLanguageDefinition class >> iso3LanguageDefinition: aString [
	^self iso3LanguageTable at: aString
]

{ #category : #private }
ISOLanguageDefinition class >> iso3LanguageTable [
	"ISOLanguageDefinition iso3LanguageTable"

	^ISO3Table ifNil: [ISO3Table := self initISO3LanguageTable]
]

{ #category : #private }
ISOLanguageDefinition class >> isoLanguages [
	"ISO 639: 3-letter codes"
	^'aar	aa	Afar
abk	ab	Abkhazian
ace		Achinese
ach		Acoli
ada		Adangme
ady		Adyghe; Adygei
afa		Afro-Asiatic languages
afh		Afrihili
afr	af	Afrikaans
ain		Ainu
aka	ak	Akan
akk		Akkadian
alb/sqi	sq	Albanian
ale		Aleut
alg		Algonquian languages
alt		Southern Altai
amh	am	Amharic
ang		English, Old (ca.450-1100)
anp		Angika
apa		Apache languages
ara	ar	Arabic
arc		Official Aramaic (700-300 BCE); Imperial Aramaic (700-300 BCE)
arg	an	Aragonese
arm/hye	hy	Armenian
arn		Mapudungun; Mapuche
arp		Arapaho
art		Artificial languages
arw		Arawak
asm	as	Assamese
ast		Asturian; Bable; Leonese; Asturleonese
ath		Athapascan languages
aus		Australian languages
ava	av	Avaric
ave	ae	Avestan
awa		Awadhi
aym	ay	Aymara
aze	az	Azerbaijani
bad		Banda languages
bai		Bamileke languages
bak	ba	Bashkir
bal		Baluchi
bam	bm	Bambara
ban		Balinese
baq/eus	eu	Basque
bas		Basa
bat		Baltic languages
bej		Beja; Bedawiyet
bel	be	Belarusian
bem		Bemba
ben	bn	Bengali
ber		Berber languages)
bho		Bhojpuri
bih	bh	Bihari
bik		Bikol
bin		Bini; Edo
bis	bi	Bislama
bla		Siksika
bnt		Bantu languages
bos	bs	Bosnian
bra		Braj
bre	br	Breton
btk		Batak languages
bua		Buriat
bug		Buginese
bul	bg	Bulgarian
bur/mya	my	Burmese
byn		Blin; Bilin
cad		Caddo
cai		Central American Indian languages
car		Galibi Carib
cat	ca	Catalan; Valencian
cau		Caucasian languages
ceb		Cebuano
cel		Celtic languages
cha	ch	Chamorro
chb		Chibcha
che	ce	Chechen
chg		Chagatai
chi/zho	zh	Chinese
chk		Chuukese
chm		Mari
chn		Chinook jargon
cho		Choctaw
chp		Chipewyan; Dene Suline
chr		Cherokee
chu	cu	Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic
chv	cv	Chuvash
chy		Cheyenne
cmc		Chamic languages
cop		Coptic
cor	kw	Cornish
cos	co	Corsican
cpe		Creoles and pidgins, English based
cpf		Creoles and pidgins, French-based
cpp		Creoles and pidgins, Portuguese-based
cre	cr	Cree
crh		Crimean Tatar; Crimean Turkish
crp		Creoles and pidgins
csb		Kashubian
cus		Cushitic languages
cze/ces	cs	Czech
dak		Dakota
dan	da	Danish
dar		Dargwa
day		Land Dayak languages
del		Delaware
den		Slave (Athapascan)
dgr		Dogrib
din		Dinka
div	dv	Divehi; Dhivehi; Maldivian
doi		Dogri
dra		Dravidian languages
dsb		Lower Sorbian
dua		Duala
dum		Dutch, Middle (ca.1050-1350)
dut/nld	nl	Dutch; Flemish
dyu		Dyula
dzo	dz	Dzongkha
efi		Efik
egy		Egyptian (Ancient)
eka		Ekajuk
elx		Elamite
eng	en	English
enm		English, Middle (1100-1500)
epo	eo	Esperanto
est	et	Estonian
ewe	ee	Ewe
ewo		Ewondo
fan		Fang
fao	fo	Faroese
fat		Fanti
fij	fj	Fijian
fil		Filipino; Pilipino
fin	fi	Finnish
fiu		Finno-Ugrian languages)
fon		Fon
fre/fra	fr	French
frm		French, Middle (ca.1400-1600)
fro		French, Old (842-ca.1400)
frr		Northern Frisian
frs		Eastern Frisian
fry	fy	Western Frisian
ful	ff	Fulah
fur		Friulian
gaa		Ga
gay		Gayo
gba		Gbaya
gem		Germanic languages
geo/kat	ka	Georgian
ger/deu	de	German
gez		Geez
gil		Gilbertese
gla	gd	Gaelic; Scottish Gaelic
gle	ga	Irish
glg	gl	Galician
glv	gv	Manx
gmh		German, Middle High (ca.1050-1500)
goh		German, Old High (ca.750-1050)
gon		Gondi
gor		Gorontalo
got		Gothic
grb		Grebo
grc		Greek, Ancient (to 1453)
gre/ell	el	Greek, Modern (1453-)
grn	gn	Guarani
gsw		Swiss German; Alemannic; Alsatian
guj	gu	Gujarati
gwi		Gwich''in
hai		Haida
hat	ht	Haitian; Haitian Creole
hau	ha	Hausa
haw		Hawaiian
heb	he	Hebrew
her	hz	Herero
hil		Hiligaynon
him		Himachali
hin	hi	Hindi
hit		Hittite
hmn		Hmong
hmo	ho	Hiri Motu
hrv	hr	Croatian
hsb		Upper Sorbian
hun	hu	Hungarian
hup		Hupa
iba		Iban
ibo	ig	Igbo
ice/isl	is	Icelandic
ido	io	Ido
iii	ii	Sichuan Yi; Nuosu
ijo		Ijo languages
iku	iu	Inuktitut
ile	ie	Interlingue; Occidental
ilo		Iloko
ina	ia	Interlingua (International Auxiliary Language Association)
inc		Indic languages
ind	id	Indonesian
ine		Indo-European languages
inh		Ingush
ipk	ik	Inupiaq
ira		Iranian languages
iro		Iroquoian languages
ita	it	Italian
jav	jv	Javanese
jbo		Lojban
jpn	ja	Japanese
jpr		Judeo-Persian
jrb		Judeo-Arabic
kaa		Kara-Kalpak
kab		Kabyle
kac		Kachin; Jingpho
kal	kl	Kalaallisut; Greenlandic
kam		Kamba
kan	kn	Kannada
kar		Karen languages
kas	ks	Kashmiri
kau	kr	Kanuri
kaw		Kawi
kaz	kk	Kazakh
kbd		Kabardian
kha		Khasi
khi		Khoisan languages
khm	km	Central Khmer
kho		Khotanese; Sakan
kik	ki	Kikuyu; Gikuyu
kin	rw	Kinyarwanda
kir	ky	Kirghiz; Kyrgyz
kmb		Kimbundu
kok		Konkani
kom	kv	Komi
kon	kg	Kongo
kor	ko	Korean
kos		Kosraean
kpe		Kpelle
krc		Karachay-Balkar
krl		Karelian
kro		Kru languages
kru		Kurukh
kua	kj	Kuanyama; Kwanyama
kum		Kumyk
kur	ku	Kurdish
kut		Kutenai
lad		Ladino
lah		Lahnda
lam		Lamba
lao	lo	Lao
lat	la	Latin
lav	lv	Latvian
lez		Lezghian
lim	li	Limburgan; Limburger; Limburgish
lin	ln	Lingala
lit	lt	Lithuanian
lol		Mongo
loz		Lozi
ltz	lb	Luxembourgish; Letzeburgesch
lua		Luba-Lulua
lub	lu	Luba-Katanga
lug	lg	Ganda
lui		Luiseno
lun		Lunda
luo		Luo (Kenya and Tanzania)
lus		Lushai
mac/mkd	mk	Macedonian
mad		Madurese
mag		Magahi
mah	mh	Marshallese
mai		Maithili
mak		Makasar
mal	ml	Malayalam
man		Mandingo
mao/mri	mi	Maori
map		Austronesian languages
mar	mr	Marathi
mas		Masai
may/msa	ms	Malay
mdf		Moksha
mdr		Mandar
men		Mende
mga		Irish, Middle (900-1200)
mic		Mi''kmaq; Micmac
min		Minangkabau
mis		Uncoded languages
mkh		Mon-Khmer languages
mlg	mg	Malagasy
mlt	mt	Maltese
mnc		Manchu
mni		Manipuri
mno		Manobo languages
moh		Mohawk
mon	mn	Mongolian
mos		Mossi
mul		Multiple languages
mun		Munda languages
mus		Creek
mwl		Mirandese
mwr		Marwari
myn		Mayan languages
myv		Erzya
nah		Nahuatl languages
nai		North American Indian languages
nap		Neapolitan
nau	na	Nauru
nav	nv	Navajo; Navaho
nbl	nr	Ndebele, South; South Ndebele
nde	nd	Ndebele, North; North Ndebele
ndo	ng	Ndonga
nds		Low German; Low Saxon; German, Low; Saxon, Low
nep	ne	Nepali
new		Nepal Bhasa; Newari
nia		Nias
nic		Niger-Kordofanian languages
niu		Niuean
nno	nn	Norwegian Nynorsk; Nynorsk, Norwegian
nob	nb	Bokmal, Norwegian; Norwegian Bokmal
nog		Nogai
non		Norse, Old
nor	no	Norwegian
nqo		N''Ko
nso		Pedi; Sepedi; Northern Sotho
nub		Nubian languages
nwc		Classical Newari; Old Newari; Classical Nepal Bhasa
nya	ny	Chichewa; Chewa; Nyanja
nym		Nyamwezi
nyn		Nyankole
nyo		Nyoro
nzi		Nzima
oci	oc	Occitan (post 1500)
oji	oj	Ojibwa
ori	or	Oriya
orm	om	Oromo
osa		Osage
oss	os	Ossetian; Ossetic
ota		Turkish, Ottoman (1500-1928)
oto		Otomian languages
paa		Papuan languages
pag		Pangasinan
pal		Pahlavi
pam		Pampanga; Kapampangan
pan	pa	Panjabi; Punjabi
pap		Papiamento
pau		Palauan
peo		Persian, Old (ca.600-400 B.C.)
per/fas	fa	Persian
phi		Philippine languages)
phn		Phoenician
pli	pi	Pali
pol	pl	Polish
pon		Pohnpeian
por	pt	Portuguese
pra		Prakrit languages
pro		Provencal, Old (to 1500);Occitan, Old (to 1500)
pus	ps	Pushto; Pashto
qaa-qtz		Reserved for local use
que	qu	Quechua
raj		Rajasthani
rap		Rapanui
rar		Rarotongan; Cook Islands Maori
roa		Romance languages
roh	rm	Romansh
rom		Romany
rum/ron	ro	Romanian; Moldavian; Moldovan
run	rn	Rundi
rup		Aromanian; Arumanian; Macedo-Romanian
rus	ru	Russian
sad		Sandawe
sag	sg	Sango
sah		Yakut
sai		South American Indian languages
sal		Salishan languages
sam		Samaritan Aramaic
san	sa	Sanskrit
sas		Sasak
sat		Santali
scn		Sicilian
sco		Scots
sel		Selkup
sem		Semitic languages
sga		Irish, Old (to 900)
sgn		Sign Languages
shn		Shan
sid		Sidamo
sin	si	Sinhala; Sinhalese
sio		Siouan languages
sit		Sino-Tibetan languages
sla		Slavic languages
slo/slk	sk	Slovak
slv	sl	Slovenian
sma		Southern Sami
sme	se	Northern Sami
smi		Sami languages
smj		Lule Sami
smn		Inari Sami
smo	sm	Samoan
sms		Skolt Sami
sna	sn	Shona
snd	sd	Sindhi
snk		Soninke
sog		Sogdian
som	so	Somali
son		Songhai languages
sot	st	Sotho, Southern
spa	es	Spanish; Castilian
srd	sc	Sardinian
srn		Sranan Tongo
srp	sr	Serbian
srr		Serer
ssa		Nilo-Saharan languages
ssw	ss	Swati
suk		Sukuma
sun	su	Sundanese
sus		Susu
sux		Sumerian
swa	sw	Swahili
swe	sv	Swedish
syc		Classical Syriac
syr		Syriac
tah	ty	Tahitian
tai		Tai languages
tam	ta	Tamil
tat	tt	Tatar
tel	te	Telugu
tem		Timne
ter		Tereno
tet		Tetum
tgk	tg	Tajik
tgl	tl	Tagalog
tha	th	Thai
tib/bod	bo	Tibetan
tig		Tigre
tir	ti	Tigrinya
tiv		Tiv
tkl		Tokelau
tlh		Klingon; tlhIngan-Hol
tli		Tlingit
tmh		Tamashek
tog		Tonga (Nyasa)
ton	to	Tonga (Tonga Islands)
tpi		Tok Pisin
tsi		Tsimshian
tsn	tn	Tswana
tso	ts	Tsonga
tuk	tk	Turkmen
tum		Tumbuka
tup		Tupi languages
tur	tr	Turkish
tut		Altaic languages
tvl		Tuvalu
twi	tw	Twi
tyv		Tuvinian
udm		Udmurt
uga		Ugaritic
uig	ug	Uighur; Uyghur
ukr	uk	Ukrainian
umb		Umbundu
und		Undetermined
urd	ur	Urdu
uzb	uz	Uzbek
vai		Vai
ven	ve	Venda
vie	vi	Vietnamese
vol	vo	Volapuk
vot		Votic
wak		Wakashan languages
wal		Wolaitta; Wolaytta
war		Waray
was		Washo
wel/cym	cy	Welsh
wen		Sorbian languages
wln	wa	Walloon
wol	wo	Wolof
xal		Kalmyk; Oirat
xho	xh	Xhosa
yao		Yao
yap		Yapese
yid	yi	Yiddish
yor	yo	Yoruba
ypk		Yupik languages
zap		Zapotec
zbl		Blissymbols; Blissymbolics; Bliss
zen		Zenaga
zha	za	Zhuang; Chuang
znd		Zande languages
zul	zu	Zulu
zun		Zuni
zxx		No linguistic content; Not applicable
zza		Zaza; Dimili; Dimli; Kirdki; Kirmanjki; Zazaki'
]

{ #category : #private }
ISOLanguageDefinition class >> readISOLanguagesFrom: stream [
	"ISOLanguageDefinition readISOLanguagesFrom: ISOLanguageDefinition isoLanguages readStream "
	| languages language code3 index line |
	languages := Dictionary new.
	[stream atEnd
		or: [(line := stream nextLine readStream) atEnd]]
		whileFalse: [
			language := ISOLanguageDefinition new.
			code3 := line upTo: Character tab.
			(index := code3 indexOf: $/) > 0
				ifTrue: [
					language iso3: (code3 copyFrom: 1 to: index-1).
					language iso3Alternate: (code3 copyFrom: index+1 to: code3 size)]
				ifFalse: [language iso3: code3].
			language
				iso2: (line upTo: Character tab);
				language: line upToEnd.
			languages at: language iso3 put: language].
	^languages
]

{ #category : #accessing }
ISOLanguageDefinition >> iso2 [
	^iso2 ifNil: [self iso3]
]

{ #category : #initialize }
ISOLanguageDefinition >> iso2: aString [
	iso2 := aString ifEmpty: [nil] ifNotEmpty: [aString]
]

{ #category : #accessing }
ISOLanguageDefinition >> iso3 [
	^iso3 ifNil: ['']
]

{ #category : #initialize }
ISOLanguageDefinition >> iso3: aString [
	iso3 := aString ifEmpty: [nil] ifNotEmpty: [aString]
]

{ #category : #accessing }
ISOLanguageDefinition >> iso3Alternate [
	^iso3Alternate ifNil: ['']
]

{ #category : #initialize }
ISOLanguageDefinition >> iso3Alternate: aString [
	iso3Alternate := aString ifEmpty: [nil] ifNotEmpty: [aString]
]

{ #category : #accessing }
ISOLanguageDefinition >> language [
	^language
]

{ #category : #initialize }
ISOLanguageDefinition >> language: aString [
	language := aString
]
