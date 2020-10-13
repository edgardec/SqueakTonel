"
I support the navigation of the system. I act as a facade but as I could require some state
or different way of navigating the system all my behavior are on the instance side.


For example if you want to look at all methods you have written or changed in the current image do

SystemNavigation new browseAllSelect: [ :method |
       method fileIndex > 1 ""only look at changes file""
       and: [ method timeStamp beginsWith: 'your-initials-here' ] ].


"
Class {
	#name : #SystemNavigation,
	#superclass : #Object,
	#instVars : [
		'browserClass',
		'hierarchyBrowserClass',
		'environment'
	],
	#classVars : [
		'Authors',
		'AuthorsInverted',
		'Default'
	],
	#category : #'System-Support'
}

{ #category : #accessing }
SystemNavigation class >> authors [

	^ Authors ifNil: [self initializeAuthors. Authors]
]

{ #category : #accessing }
SystemNavigation class >> authorsInverted [

	^ AuthorsInverted ifNil: [self initializeAuthors. AuthorsInverted]
]

{ #category : #'class initialization' }
SystemNavigation class >> cleanUp: aggressive [

	aggressive ifTrue: [Authors := nil. AuthorsInverted := nil].
]

{ #category : #accessing }
SystemNavigation class >> default [
	
	^Default ifNil: [ Default := self new ]
]

{ #category : #'error handling' }
SystemNavigation class >> doesNotUnderstand: aMessage [
	(self includesSelector: aMessage selector) ifTrue:
		[^self default perform: aMessage selector withArguments: aMessage arguments].
	^super doesNotUnderstand: aMessage
]

{ #category : #accessing }
SystemNavigation class >> for: anEnvironment [
	^ self basicNew initializeWithEnvironment: anEnvironment.
]

{ #category : #'class initialization' }
SystemNavigation class >> initialize [

	self initializeAuthors.
]

{ #category : #'class initialization' }
SystemNavigation class >> initializeAuthors [
	"self initializeAuthors"
	
	| s currentName currentAbbrv |
	Authors := Dictionary new.
	s := self privateAuthorsRaw readStream.
	
	[s atEnd] whileFalse: [
		"Read author name"
		currentName := String streamContents: [:as |
			[s peek ~= $#] whileTrue: [as nextPut: s next]].
		Authors at: currentName put: Set new.
		"Read abbreviations"
		s next. "skip $#"
		currentAbbrv := ''.
		[s atEnd not and: [s peek ~= $!]] whileTrue: [
			s peek = $# ifTrue: [
				(Authors at: currentName) add: currentAbbrv.
				currentAbbrv := ''.
				s next. "skip $#"].
			currentAbbrv := currentAbbrv, s next asString. "slow..."
			].
		currentAbbrv ifNotEmpty: [(Authors at: currentName) add: currentAbbrv].
		s next. "skip $!"
	].

	"Fill inverted index for authors."
	AuthorsInverted := Dictionary new.
	Authors keysAndValuesDo: [:fullName :abbreviations |
		abbreviations do: [:abbrv |
			(AuthorsInverted
				at: abbrv asLowercase
				ifAbsentPut: [Set new]) add: fullName]].
]

{ #category : #'class initialization' }
SystemNavigation class >> privateAuthorsRaw [
	"SystemNavigation initializeAuthors"
	^ 'Aaron Reichow#ajr!Abigail Sanchez#as!Adam Engel#ASE!Adam King#ajk!Adam Sádovský#Adrin!Adam Spitz#ads!Adam Wespiser#wespiser!Adrian Lienhard#AL#al!Adrien Sebbane#AS!Aibek Musaev#AM!Aik-Siong Koh#askoh!Alain Fischer#AFi!Alain Plantec#apl!Alain Rastoul#alr!Alan Capewell#arc!Alan Hodson#TX!Alan Curtis Kay#ack!Alan Lovejoy#chronos!Alan Reider#alnr!Alberto#AlFe!Alejandro Aguirre#pato!Alejandro Fernandez#casco!Alejandro Gonzalez#ag!Alejandro Magistrello#asm!Alejandro Reimondo#afr!Alessandro Warth#aw!Alexander Diemand#XLD!Alexander Lazarevic#laza!Alexander Martinov#AM!Alexandre Bergel#ab!Alexandre Jasmin#alexj!Alexis Olivier#AO!Allen Evans#ae!Alphacode#alpha!Americo Damasceno#adamascj!Amir Nanda Gorkhali#Amir!Andreas Kuckartz#ak!Andreas Petermann#ap!Andreas Raab#ar!Andreas Wiedebruch#sanwb!Andres Coratella#ac!Andres Otaduy#aoy!Andres Valloud#SqR!Andrew Berg#acb!Andrew C. Greenberg#acg!Andrew Capon#ACapon!Andrew Gaylard#apg!Andrew Lawson#adl!Andrew P. Black#apb!Andrew Tween#amt!Andy Gelme#andyg!Andy Milburn#am!Andy Tween#tween!Angel Aberbach#aberbacha!Angela E. Taylor#trxckster!Anoulak Kictiraz#AK!Anthony Giaccone#ajg!Anthony Hannan#ajh!Antonio Moreno#am!Antony Blakey#ASB!Aoki Atsushi#aoJun!Arian Treffer#ArTr!Arnaud Jean Baptiste#JBA!Arndt Jenssen#AJ!Art Collings#amc!Arthur Vanderbilt#aav!Arto Bendiken#arto!Arturo Frappé#afm!Ashok Mahajan#ashok!Attila Magyar#zero!Avi Bryant#avi!Aye Aye Khine#AAK!Baard Ove Kopperud#BOK!Bakki Kudva#bk!Balázs Kósi#kb!Barrie Jehu#jbj!Barry Bridgens#bjb!Bas Kok#bkok!Bastian Steinert#bs!Bedrich Hovorka#bh3!Ben Coman#btc!Ben Goetter#bdg!Ben Huxham#BHux!Ben Matasar#ben!Ben Schroeder#bvs!Benjamin Pollack#bmp!Benoît St-Jean#BSTJ!Bernd Eckardt#be!Bernd Oldenbuettel#beo!Bernhard Pieber#bp!Bert Freudenberg#bf!Bijan Parsia#BJP!Bill Dargel#wod!Bill Holloway#bat#wjh!Bill Nadvornik#wcn!Bill Schwab#wks!Bill Smith#WFS!Binh Le#binhle2#BL!Blaine Buxton#btb!Bob Arning#RAA!Bob Cowdery#RAC!Bob Hartwig#bh!Bob Houston#rkh!Bob Irving#bi!Bolot Kerimbaev#bolot!Boris Gaertner#bg!Boris Shingarov#bgs!Bracken Spencer#bra!Brenda Larcom#BEL!Brent Pinkney#brp!Brent Vukmer#bkv!Brian Brown#rbb!Brian Byrne#bpb!Brian Keefer#bmk!Brian Murphy-Dye#bmd!Brian T. Rice#btr!Brian Tabone#hybridmachine!Bruce Badger#BB!Bruce Cichowlas#bwc!Bruce Haugland#BAH!Bruce Prior#bgp!Bruno Luca#let!Bryce Kampjes#wbk!Burella Juan M.#bjm!C. David Shaffer#cds!CalmoSoft#Calmo!Carl Gruden#cgg!Carl Gundel#ceg!Carl Watts#cgw!Carlos Crosetti#ccrosetti!Carlos Morales Socorro#cmorsoc!Casey Ransberger#cbr!Catherine Pratoff#CP!Cédrick Béler#cb!Cees de Groot#CdG#cdg!Cesare Marilungo#cm!Chad Nantais#cen!Chao-Kuo Lin#ckl!Charles Hixson#cdh!Chinedu Charles#!Chris Becker#chb!Chris Burkert#chbu!Chris Cunningham#cbc!Chris Cunnington#CC#chc!Chris De Vaney#CdV!Chris Dickerson#erilidon!Chris Kermiet#ChrisK!Chris Muller#cmm!Chris Norton#ccn!Chris Patrick Schreiner#cps!Chris Patti#cap!Chris Reuter#cr!Chris Wade-Evans#CJWE!Christian Flach#cmfcmf!Christoph Budzinski#CHB!Christoph Lamprecht#chl!Christoph Thiede#ct!Chuck Valois#cbv#ceevee!Chucky Ellison#cme!Claes-Fredrik Mannby#cf!Clarence Westberg#crw!Claus Gittinger#cg!Claus Kick#CK!Clément Béra#cb!Clifford Goldberg#cig!Cocodrilo Astronauta#cocodriloastronauta!Colin Curtin#cc!Colin Putney#cwp!Colm Sean Murdoch O Cinneide#csmk!Connie Louise#clt!Connie Tebbe#connielouise#mst303!Conrad Pöpke#cop!Cornelis Pols#jayanta!Cory Redfern#CR!Costel Vrinceanu#cv#cxv!Craig Latta#crl!Cristhiano E. C. De Souza#cecs!Dafina Zoteva#dafy!Damien Cassou#dc!Damien Pollet#dp!Dan Ingalls#di!Dan Moniz#dnm!Dan Norton#dhn!Dana Gheorghe#DG!Danie Roux#djr!Daniel Altman#DEA!Daniel Poon#danp!Daniel Sancho Ehlert#dse!Daniel Vainsencher#dvf!Daniel Weigel#dewb#dweigel!Danil Osipchuk#dao!Danilo Gulamhussene#dg!Darius Bacon#djb!Darius Clarke#dgc!Dary Lalden#DJA!Dave Faught#daf!Dave Goehrig#djg!Dave Mason#dvm!Dave Mclure#dav0!Dave Newman#DaN!Dave Raftery#dgr!Dave Raymer#dlr#draymer!David Barroco#DaveBar!David Belding#autonomad#tzaddi!David Brown#ddb!David Corking#dcorking!David Dykstal#dwd!David Farber#dvd!David Harris#dph!David J. Pennell#djp!David Mitchell#david-mitchell#dmm!David N. Smith#dns!David Pollak#dpp!David Salamon#dss!David "Dave" T. Lewis#dtl!David Tibbe#dt!David Treffler#canadans!David Ungar#dmu!David Weil#adw!David Wildasin#dtw!Debora Nascimento#debby!Delbert Murphy#drm!Denis Kudriashov#dik!Dennis Lee Hanchar#smartsphere!Dennis Schetinin#chaetal!Derek Brans#djb!Derek Hadlington#djh!Derek O''Connell#doc!Derrell Piper#ddp!Dick Combeer#DC!Diego Fernandez#DF!Diego Gomez Deck#dgd!Diego Park#drp!Diogenes Moreira#DAM!Dipti Ranjan Nayak#nayak!Dmitry Golubovsky#dmg!Domianna Caruso#DJC!Dominic Letz#dl!Dominique Dutoit#dd!Don Sawtelle#DS!Doug Rollwitz#dbr!Doug Way#dew!Douglas Brebner#db!Douglas McPherson#djm!Duane Maxwell#dsm!Duane Thomas Williams#dtw!Dwight Hughes#dwh!Dwight Mcdowell#dowaito!E. Glen Paling#egp!Eddie Cottongim#efc!Edgar J. De Cleene#edc!Edwin Cutright#EdnaC!Eiichiro Ito#e-itoh!Elena Sebe#gambitside!Eliot Miranda#eem!Elod Kironsky#ke!Emery Gant#eg!Emilio Oca#efo!Emmanuel A. Escol#winky!Enno Schwass#Enno!Enrico Bertini#eb!Enrico Spinielli#espin!Eric Euerlings#EE!Eric Fournier#emf!Eric Hochmeister#eh!Eric Hudson#ejh!Eric Merritt#EBM!Eric Rodriguez Guevara#ERG#erg!Eric Scharff#eds!Erik Greenwald#erik!Erik Hinterbichler#erikh!Ernest Micklei#emm!Esteban A. Maringolo#eam!Esteban Lorenzano#EL!Estrella Demar#!Etienne Delacroix#eti!Evan Dembskey#EJD!Fabio Niephaus#fn#FabN!Fadi Mansour#Redeemer!Faried Nawaz#fn!Federico G. Stilman#fgs!Felix Franz#ff!Felix Lange#fl!Felix Munk#FM!Fernando Soteras#fersoteras#fest!Filipe Cabecinhas#FilCab#FilipeCabecinhas!Florian Greese#FlorianGreese#pikapika!Francisco Pancho Garau#fg!Francois Stephany#fs#FS!Frank Barnes#FB#gandermight!Frank Caggiano#fc!Frank Kresin#fjk!Frank Mueller#mue!Frank Sergeant#fcs!Frank Shearar#fbs!Frank Winkler#FWr!Franz Brummer#fb!Franziska Krueger#fk!Frederik Cheeseman#Xantheon!Frederik De Bleser#fdb!Frederik Vandendriessche#FVDD!Fredrik Andersson#el_diego!G. R. Thushar#grt!Gabriel Senno#gsenno!Gale Pedowitz#gep!Gary Chambers#gvc!Gary Fisher#gf!Gen Suzuki#gen!Geoff Reedy#ger!Georg Gollmann#go!George Olive#gao!Gerald Leeb#LEG#leg!Gerald Zincke#gzi!Gerardo Richarte#gera#r++!German Morales#gm!Germán S. Arduino#gsa!Gerry Cornish#gjc!Gian Holland#gmh!Gilles Reubi#gr!Giovanni Corriga#gc!Giovanni Giorgi#gg!Giridharan#giridharan!Giuseppe Luigi Punzi#glp!Glenn G. Burnside III#ggb!Gopibrindha#gopi!Göran Krampe#gh#gk!Görge Albrecht#gal!Graham Mcleod#GMc!Greg Hand#handy!Greg Harrold#ggh!Greg Lewin#GL!Greg Trasuk#gmt!Gregor Gabrysiak#RogerG!Gregor Mcnish#igm!Grit Schuster#gs!Guillermo Polito#GAP!Gustavo Rafael Pistoia#grp!Guy Hillyer#gkh!Hank Wilde#HFW!Hannes Hirzel#hjh!Hans Baveco#jmb!Hans Kleinwort#HK!Hans Schippers#HS!Hans-Martin Mosner#hmm!Harald Gliebe#hagl!Harshvardhan#hvg!Hashim Katalog#Kapashor!Helge Horch#hh!Henrik Ekenberg#heg!Henrik Gedenryd#hg!Henrique Manela#hm!Henry Strickland#strick#YAK!Herbert König#hk!Herbert Vojèík#hsk!Hern Tylim#hpt!Hernan Galante#HJG!Hernan Parra#HP!Hernán Tylim#hpt!Hernan Wilkinson#HAW!Hiromu-Papa#hp!Hiroshi Saito#gann!Holger Schuh#holgersolger!Houssam Fakih#Geanoubi!Howard J. Oh#hjo!Hung Le#hmle!Ian Piumarta#ikp!Ian Prince#ijp!Ian Trudel#it!Iede Snoek#IS!Igor Stasenko#sig!Ikem Nzeribe#ION!Ingo Hohmann#iho!Ingo Jaeckel#ij!Innocent Victor#nkala!Ioan Gartner#Sharphawk!Ivo Eduardo Seben De Azevedo#ivoesa!Ivo Roessling#ir!Ivor Dt Cook#Ivor Cook!J. Duijndam#dnmjca!Jack Keel#jhk!Jae Yoon Kim#projayjay!Jahidul Alam#Jahid!Jaime Silvela#jsm!Jakob Reschke#jr!James Foster#JGF!James Roberts#jr!Jamie Jones#JJ!Jamie McNeil#!Jan B. Krejci#jbk!Jan Barger#jb!Jan Fietz#jaf!Jan Van De Sandt#jvds!Jang Yun Jae#janggoon!Janko Mivsek#mivsek!Jaroslav Havlin#jerri!Jason Burke#jbb!Jason Dicioccio#jmd!Jason Dufair#jkd!Jason L. Smith#jls!Jason McVay#jlm!Jason Ostberg#Jason!Jason Rogers#jlr!Jason Shoemaker#jts!Jason Steffler#jrs!Jason Varner#!Jason Williams#jdw!Javier Diaz-Reinoso#jdr!Javier Musa#jam!Jay Carlson#nop!Jay Fearn#JBF!Jean J. Escoto#jje!Jeangalineau#JG!Jecel Assumpcao Jr#jecel!Jeff Gonis#jmg!Jeff Pierce#jsp!Jeff Sparkes#!Jeffrey Feldman#jbf!Jeffrey Foreman#jdf!Jeffrey Haun#JAH!Jeffrey T. Read#jtr!Jens Lincke#jl!Jens Moenig#jens!Jens Pall Hafsteinsson#jp!Jens Quade#jq!Jeremy Johnstone#jstone!Jeremy Shute#shute!Jeroen Van Hilst#jvh!Jerome Peace#wiz!Jerry Archibald#jla!Jerry Bryson#JerryB!Jerry Stokes#js!Jesse Welton#JW!Jessy Kuriakose#akhsa!Jesus Alvarez#ja#jalvarez#jmalvarez!Jigar H. Doshi#jdoshi2#jhd#jhdoshi!Jim Bender#jcb!Jim Benson#jlb!Jim Buckeye#JR!Jim Freeman#jmf!Jim Greer#jbg!Jimmie Houchin#jlh!Jivko Jeliazkov#jivko_jeliazkov!Joan Barrull#joan!Jochen Riekhof#jfr!Joel Uzi Eden#jue!Joern Eyrich#je!Joey Hagedorn#JAH!Joey White#jw!Johannes Dyck#jfd!John Bailey#jbailey652000!John D''Ausilio#jld!John David Miller#jdm!John Dougan#jrd!John Ewart#jwe!John Ferrier#jtf!John G. Gardner#JGG!John M. McIntosh#JMM#jmm!John M. Stephens, Jr.#jms!John Macchia#JL!John Magnifico#JM!John Maloney#jhm#jm!John Maxwell#jmax!John McKeon#jmck!John Pfersich#jgp!John Pierce#jrp!John Sarkela#jws#reThink!John Tobler#jet!John-Reed Maffeo#jrm!Jon Hylands#jon!Jonas Beckman#jobe!Jonathan Brezin#jpb!Jonathan D''Andries#jd!Jonathan Wright#jdw!Jonty Lochner#jlthedoes!Jorge Campos#jmc!Jörn Eyrich#je!Jose Antonio Romero#HPCPRO!José L. Redrejo Rodríguez#jlrr!Jose L. Salmeron#jlsalsil!Josef Hajas#jhajas#nax!Joseph M. Paquette#jmp!Joseph Pelrine#jp!Joseph Terry#knowself!Joshua Fein#JTF!Joshua Gargus#jcg!Joshua Marker#jlm!Juan Daugherty#jdaugherty!Juan Manuel Vuletich#jmv!Judith Chatelain#jchatelain!Julian Fitzell#jf!Julien Bourdon#jb#jbo!Julio Salcido#!K. K. "Subbu" Subramaniam#kks!Kakiya Isao#kakiya!Kamil Kukura#kamk!Kang Jin-oh#KJO!Karel Zelnicek#__Karel__#KZ!Karl Ramberg#kfr!Karsten Droste#kd!Karsten Wolf#kw!Kazuhiro Abe#ka!Kazuki Minamitani#minami!Kees Kremer#kk!Keith Hodges#kph!Keith Lazuka#kl!Keithhall#keithhall513!Kejing Zhang#novachang!Kellie Miller#jkm!Ken Boucher#bons!Ken Causey#KLC#klc!Ken Dickey#KenD#KenD1!Ken G. Brown#kgb!Ken Happel#kmh!Ken Treis#kdt!Kenneth Johnsen#KEJ!Kevin Fisher#kgf!Kevin J. Woolley#kjw!Kevin Kelley#klk!Kim Yong-Cheon#gal2!Kirill Jdanov#jdanov!Klaus D. Witzel#kwl!Konstantin Käfer#kkx!Korienek Gene#eneg!Kosuke Chan#kc!Krishna Sankar#ks!Kristin Kaster Lamberty#kk!Kta Shwele#kta#nantaw!Kumar Salman#kumar!Kun Puparussanon#kp!Kundan Dhumal#kundan_11!Kurt Thams#ktt!Lady Sophea#az5!Lantz Rowland#zL!Larry Gadallah#ldg!Larry Pruitt#ldp!Lars Dornheim#eldeh!Lars Nilsson#ltn!Lars Wassermann#lars#lw!Laura Perez Cerrato#lpc!Laurence Rozier#!Laurent Siksous#lss!Ld Landis#ldlandis!Leandro Caniglia#LC!Lee Salzman#lrs!Lee Yu Hsun#swps567!Legrand#LGDEKI!Leo Burd#lb!Leon Smith#LS!Leonid Golender#lgol27!Levente Uzonyi#ul!Lex Spoon#ls!Liangbing#Liangbing!Logan Roguevax#lxr!Lois Lherbier#LL!Lorenzo Schiavina#lrs!Lothar Schenk#los!Lu Yunhai#luyunhai!Luca Bruno#let!Luciano Dell''Olivo#LD-Y1951!Luciano Esteban Notarfrancesco#len!Luciano Notarfrancesco#len!Luigi Panzeri#LPM!Luis Araujo#LA!Luis Valente#LV!Lukas Petrlik#lp!Lukas Renggli#lr!Luke Gorrie#lg!Lushi#YYL!Lyndon Tremblay#huma!Magnus Kling#makl!Mahajan Ashok#ashokmahajan!Mahamud#encore!Malcolm Yadack#vmy!Manuel Trujillo#MTA!Manuel Wellmann#MaWell#MW!Marcel Taeumel#mt!Marcel Weiher#mpw!Marcelo Pereira Barbosa#mpbarbosa!Marco Monteiro#masm!Marco Paga#mpa!Marco Schmidt#MS!Marcus Denker#md!Marcus Kemper#mtk!Marek Mor#MMOR!Mariano Abel Coca#nekron!Mariano Martinez Peck#MMP!Mark A. Schwenk#mas!Mark Brady#mby!Mark Guzdial#mjg!Mark McCahill#mpm!Mark Pirogovsky#markp!Mark Schwenk#mas!Mark Warren#MAW!Markus Fritsche#maf#MFritsche!Markus Gaelli#mga!Markus Gälli#mga!Martin Beck#mb!Martin Holst Swende#mhs!Martin Hruby#mhaf!Martin Kuball#maku!Martin McClure#mrm!Martin Peschke#MP!Martin Ruskov#MR!Martin von Löwis#mvl!Martin Wirblat#mw!Masashi Umezawa#mu!Masato Sumi#sumim!Matej Kosik#mk!Mats Nygren#mn!Matt Kennedy#mck!Matthew Fulmer#mtf!Matthew S. Hamrick#msh!Matti J. Kärki#MJK!Maurice Rabb#m3r!Maurizio Boriani#mdb!Mauro Gardenal#MG!Max Leske#MaxLeske!Maximialiano Taborda#mx!Maximo#mpc!Mayuresh Kathe#MAK!McSee#mc!Merik Voswinkel#mav#mv!Michael Cole#mc!Michael Davies#MAD!Michael Dunn#mrd020!Michael E. Burke#MEBurke!Michael Haupt#mha!Michael Hewner#MPH!Michael J. Forster#MJF!Michael Klein#msk!Michael Maloney#amm!Michael Naunton#mmn!Michael Nedzelsky#MichaelNedzelsky!Michael Parker#kmp!Michael Perscheid#micper!Michael Pfurtscheller#mpf!Michaël Piel#mp!Michael Pruemm#mip!Michael Rueger#mir!Michael Toth#MT181!Michael Van Der Gulik#mvdg!Michal Kostal#!Michal Skrivanek#!Michal Starke#mist!Michal Wallace#mjw!Michal Wendrowski#michal!Miguel Angel Castro#mac!Miguel Cobá#mcm!Mikael Kindborg#miki#mikki!Mikael Langer#ml!Mike Janger#mjj!Mike Kaden#m2k!Mike Roberts#mjr!Mike Rutenberg#mdr!Mike Sersen#Tre!Mike Thomas#mjt!Milan Vavra#mva!Milan Zimmermann#mz!Min Htut Khaung#minhtutkhaung!Mirek Hancl#mh!Mirko Kiefer#MirkoK!Miron Brezuleanu#MB!Mohsen Vakilian#mv!Murphy Stein#mms!Naala Brewer#nb!Naheed Misbah#naheed!NameSpaces#maf!Nancy Brito#doubles!Nathaniel Reyes#nreyes!Ned Konz#nk!Nevin Pratt#nop!Nico Rehwaldt#NRe!Nicolás Cañibano#Cani!Nicolas Cellier#nice!Nicolas Petton#np!Nik Boyd#nik!Niko Schwarz#nes!Nikolay Suslov#sn!Nils-Olof Biderholt#nobi!Nishihara Satoshi#nsh!Norbert Hartl#noha!Norberto Manzanos#nm!Norman Nunley#ndn!Noury Bouraqadi#nbo#noury!Oddbjorn Aasen#obion!Olaf Buwen#obu!Oleg Korsak#kamaz!Pablo Iaría#pi#PI!Pablo J. E. Rodriguez#pjer!Paola Zugno#pazu#pz!Paolo Bernardi#pber!Paragkamat#kamatp!Pascal Vollmer#pv!Patrick C. Castle#pcc!Patrick Chénais#pch!Patrick Collison#pc!Patrick Defrance#pdf!Patrick Rein#pre!Patty Gadegast#pg!Paul Baumann#!Paul Horth#Phorth!Paul Jensen#psj!Paul L. Fries#plf!Paul McDonough#pnm!Paul Saitta#PBS!Paul Steffen#rabit!Paul W. Mitchell#pwm!Paul Ward#PW!Pavel Krivanek#pk!Pavel Tkachenko#p4s!Pedro Morte Rolo#pmr!Peter Armianov#peshe!Peter Ernicke#per!Peter H. Meadows#phm!Peter Hechler#phec!Peter Olsen#pcolsen!Peter Osburg#PO!Peter Schuller#ps!Peter Willliam Lount#pwl!Petr Fischer#pf!Petr Polasek#PP!Phil B.#pb!Phil Hargett#PH!Philip E. Evans#pevans!Philipp Engelhard#pe!Philipp Tessenow#phite!Philippe Back#pba#pbk!Pierce Ng#pn!Piero Sartini#PS!Prashanth Hebbar#hebbarp!Rabih Nassrallah#laiqui!Radoslav Hodnicak#rh!Radoslav Hodnicak#rh!Radovan Cervenka#RCE!Rafa Komtur#refek!Ragnar Hojland Espinosa#RHE!Rainer Keller#rke!Rajeev Lochan#rajeev#rajiv!Ralf Thalau#rt!Ralph Johnson#rej!Ralph P. Boland#rpb!Ram Krishnan#rkris!Ramiro Diaz Trepat#rdt!Ramon Leon#rjl!Randal L. Schwartz#rls!Randall S. Bohn#rsb!Ranjan Bagchi#RjB!Ray Leyva#rlm!Raymond Asselin#rga!Reinier van Loon#RvL!Renaud Lenne#RL!Rex Morikawa#rxm!Ricardo J. Ferreira#rjf!Ricardo Moran#Richo!Richard A. Harmon#RAH!Richard Frost#ref!Richard Karpinski#rhk!Richard Manning#rsm!Richard Staehli#rstaehli!Rick Hedin#rmh!Rick McGeer#rm!Ridvan Yildirim#ridvan!Rik Fischer Smoody#Rik!Rob Miller#Miller2040!Rob Vens#RWV!Robert "Bruce" Carleton#rbc!Robert B. Livingston#rbl!Robert Hawley#RJH!Robert Hirschfeld#rhi!Robert Krahn#rkrk!Robert P. Jarvis#rpj!Robert Rübner#ror!Robert Withers#rww#rwwj!Roberto Amorim#rfa!Robin Joi Green#RJG!Robin Summers#grs!Rodney Polkinghorne#resp!Roel Wuyts#rw!Roger Verheyden#rv#rver!Roger Vossler#rav!Roland Bertuli#rb!Roland Rutkowski#rolando!Romain Robbes#rr!Roman Hubacek#bobr123!Romolo pranzetti#rp!Ron Teitelbaum#RON#Ron!Ron Welch#rpw!Ronald Cummings#ronald!Ronaldo M. Ferraz#rmf!Ruben Bakker#bar!Rúben Cabaço#rc!Rudi Angela#AREA!Russ Shotts#ras!Russell Allen#rca!Russell D. Steen#rds!Russell Penney#rop!Russell Smithers#!Ryan Bell#kofno!Ryan Macnak#ryan!Sam Adams#ssa!Sam S. Adams#ssa!Samir Saidani#sam!Samuel Henry#sjh!Samuel Tardieu#st!Samuel Tesla#sjt!Santosh Kumar Choure#!Sascha Baldt#saba!Savra Osoule#DKS!Schnulli Pups#sp!Scott Wallace#sw!Sean DeNigris#spd!Sean Glazier#sag!Sean Hayden#swh!Sean P. Denigris#spd!Sean Ross#sdr!Sebastian Fleissner#SeF!Sebastian G#gonisebas!Sebastian Wain#swain!Serge Stinckwich#zz!Sergei Zhuravlev#zerg!Seung Bum Kim#picxenk!Shahul Hameed#j shahul hameed!Shane Roberts#srsr!Shaun Johnson#SJ!Shawn Macintyre#sdm!Shawn Murphy#sfm!Shikatsu Laythe#Shikatsu!Shuky Chen#SC!Silvan Graf#sg!Simon Dobson#sd!Simon Fielding#sf!Simon Guest#sjg!Simon Holland#SimonHolland!Simon Houlbrooke#nomis!Simon Michael#sm!Soehnke Mundt#soehnkemundt!Srikantha Herath#SH!Stefan Barthel#sb!Stefan Berger#stb!Stefan Matthias Aust#md#sma!Stefan Udo Hanenberg#sha!Stefan Welebny#stw!Steinmann Ruedi#rst!Stephan B. Wessels#sbw!Stephan Rudlof#sr!Stéphane Ducasse#SD#sd!Stéphane Rollandin#spfa!Stephane Schitter#stefs!Stephanie Hamburg#MUTTLYSTEPHANIE!Stephen Smith#sst!Stephen Travis Pope#stp!Stephen Vincent Pair#svp!Steve Davies#sld!Steve Elkins#sge!Steve Fuller#snf!Steve Gilbert#slg!Steve Hunter#skh!Steve Knight#knighty!Steve Mccusker#smcc!Steve Messamore#slm!Steve Sanderson#sms!Steve Wart#swart!Steve Wessels#!Steven Darcy#SMD!Steven Greenberg#greenbes!Steven Rodriguez#optionshiftk!Steven Swerling#sps!Sudheendra Hangal#hangal!Sungjin Chun#chunsj!Suzuki Tetsuya#tetsuya!Syed Abid#taxman!Syed Masoodahmad#masden56!Sylvia Sharma#sharma!Symon Chalk#symonc!Takashi Yamamiya#tak!Tansel Ersavas#mte#MTE!Tarek Demiati#TD!Ted Bracht#TB#TB1!Ted Kaehler#tk!Terry Jenkins#TCJ!Thierry Reignier#TREG!Thijs Janssen#TJ!Thomas Bernitt#tber!Thomas Fröb#thf!Thomas Hemme#Namamazu!Thomas J Keller#TJK!Thomas Kowark#tk!Thomas M. Breuel#tmb!Thomas Mahler#ThMa!Thomas Stambaugh#tms!Thomas Zimmermann#TZ!Tim Cuthbertson#tec!Tim Felgentreff#tfel!Tim Johnson#tcj!Tim Lewis#TimLewis!Tim Olson#tao!Tim Rowledge#TPR#tpr!Timm Knape#tik!Timothy Falconer#teefal!Timothy M#tty!Timothy Retz#tgr!Tobias Isenberg#ti!Tobias Pape#topa!Todd Blanchard#tb!Tom Beckmann#tobe!Tom Counsell#tamc!Tom Dailey#td!Tom Koenig#tlk!Tom Plick#tap!Tom Rushworth#tbr!Tommy Thorn#tt!Tomohiro Oda#TO!Tony Garnock-Jones#tonyg!Tony Zampogna#zamp!Torge Husfeldt#th!Torsten Bergmann#tbn#TBN!Torsten Sadowski#ts!Travis Kay#tkay#tlk!Trygve Reenskaug#TRee!Tyler Coumbes#mtc!Tzaddi Beltaine#tsb!Udo Schneider#udos!Vaidotas Didžbalis#vd!Vassili Bykov#vb!Vernon Marsden#vmars!Vijay Mathew Pandyalakal#vmp!Vladimir Janousek#vj!Volker Bäcker#volker!Wally Cash#wac!Walter Wilhelm#ww!Ward Cunningham#ward!Wayne Braun#wb!Wayne D. Elias#wdelias!Webb Mcdonald#wxm!Wilkes Joiner#dwj!Willem van Asperen#wva!William Hess#WFH!William Hidden#whidden!Wolfgang Eder#edw!Wolfgang Helbig#whg!Woon Yeo#!Wuilmer Olaya Bardales#wob!Yagendra Dutt Tripathi#yd!Yang Ha Nguyen#yhm!Yann Monclair#YM!Yanni Chiu#yj!Yasuji Nakayama#yasuji!Yoshiki Ohshima#yo!Yuji Ichikawa#ich!Yunhee Lee#yhl!Yutaka Kamite#yk!Zdenek Novy#Zdenye#ZN!Zeljko Nesic#Poparasan!Zeynep Besen#zeyno'
]

{ #category : #query }
SystemNavigation >> allAccessesTo: instVarName from: aClass [
	"Return a sequence of MethodReferences of all methods of aClass or it's sub/superclass that refer to the instance variable instVarName."
	
	| result |
	result := OrderedCollection new.
	aClass withAllSubAndSuperclassesDo:
		[ :class | 
		(class whichSelectorsAccess: instVarName) do:
			[ :selector |
			result add: (MethodReference class: class selector: selector) ] ].
	^result
]

{ #category : #query }
SystemNavigation >> allBehaviors [

	^Generator on: [ :generator |
		self allBehaviorsDo: [ :each |
			generator yield: each ] ]
]

{ #category : #query }
SystemNavigation >> allBehaviorsDo: aBlock [ 
	"Evaluate the argument, aBlock, for each kind of Behavior in the system 
	(that is, Object and its subclasses and Traits).
	ar 7/15/1999: The code below will not enumerate any obsolete or anonymous
	behaviors for which the following should be executed:

		Smalltalk allObjectsDo:[:obj| obj isBehavior ifTrue:[aBlock value: obj]].

	but what follows is way faster than enumerating all objects."

	self environment allClassesAndTraitsDo: [ :class |
		aBlock value: class.
		class isTrait ifFalse: [ "class of a Trait is Trait, there are no MetaTraits"
			aBlock value: class class ] ]
]

{ #category : #query }
SystemNavigation >> allCallsOn: aLiteral [ 
	"Answer a sorted collection of all the methods that call on aLiteral even deeply embedded in literal array."
	"self default browseAllCallsOn: #open:label:."
	
	^self
		allCallsOn: aLiteral
		fromBehaviors: self allBehaviors
		sorted: true
]

{ #category : #query }
SystemNavigation >> allCallsOn: firstLiteral and: secondLiteral [
	"Answer a sorted collection of all the methods that call on both firstLiteral and secondLiteral."

	| firstList secondList |
	firstList := self allCallsOn: firstLiteral.
	secondList := (self 
		allCallsOn: secondLiteral
		fromBehaviors: (firstList collect: [ :each | each actualClass ] as: IdentitySet)
		sorted: false) asSet.
	firstList removeAllSuchThat: [ :each | (secondList includes: each) not ].
	^firstList
	
]

{ #category : #query }
SystemNavigation >> allCallsOn: firstLiteral and: secondLiteral localToPackage: packageNameOrInfo [
	"Answer a sorted collection of all the methods in the given package that call on both firstLiteral and secondLiteral."
	"self systemNavigation browseAllCallsOn: #not and: #ifTrue: localToPackage: #Compiler"
	| firstList secondList |
	firstList := self allCallsOn: firstLiteral
					fromBehaviors: (self packageInfoFor: packageNameOrInfo) classesAndMetaClasses
					sorted: false.
	secondList := (self 
					allCallsOn: secondLiteral
					fromBehaviors: (firstList collect: [:each | each actualClass] as: IdentitySet)
					sorted: false) asSet.
	firstList removeAllSuchThat: [:each | (secondList includes: each) not].
	^firstList sort
]

{ #category : #query }
SystemNavigation >> allCallsOn: aSymbol from: aBehavior [
	"Answer a sorted collection of all the methods from aBehavior and it's subclasses that call on aSymbol."

	^self allCallsOn: aSymbol fromBehaviors: aBehavior withAllSubclasses sorted: true
]

{ #category : #query }
SystemNavigation >> allCallsOn: aLiteral fromBehaviors: behaviors sorted: sorted [
	"Answer a collection of all the methods implemented by behaviors that call on aLiteral even deeply embedded in literal arrays."
	
	| result canBeSpecial |
	result := OrderedCollection new.
	canBeSpecial := BytecodeEncoder canBeSpecialLiteral: aLiteral.
	behaviors do: [:behavior |
		behavior selectorsAndMethodsDo: [:selector :method |
			(method hasLiteral: aLiteral scanForSpecial: canBeSpecial)
				ifTrue: [result addLast: method methodReference]]].
	sorted ifTrue: [result sort].
	^result
]

{ #category : #query }
SystemNavigation >> allCallsOn: aLiteral fromMethodReferences: methodReferences sorted: sorted [
	"Answer a collection of all the methods implemented by behaviors that call on aLiteral even deeply embedded in literal arrays."
	
	| result canBeSpecial |
	canBeSpecial := BytecodeEncoder canBeSpecialLiteral: aLiteral.
	result := methodReferences select: [:reference |
		reference compiledMethod
			ifNil: [false]
			ifNotNil: [:method | method hasLiteral: aLiteral scanForSpecial: canBeSpecial]].
	sorted ifTrue: [result sort].
	^result
]

{ #category : #query }
SystemNavigation >> allCallsOn: aLiteral localTo: aClass [
	"Answer a sorted collection of MethodReferences for all the methods that call on aLiteral in, above or below the given class."

	^self
		allCallsOn: aLiteral
		fromBehaviors: (Array streamContents: [ :stream |
			aClass theNonMetaClass withAllSuperAndSubclassesDoGently: [ :each |
				stream nextPut: each ].
			aClass theNonMetaClass class withAllSuperAndSubclassesDoGently: [ :each |
				stream nextPut: each ] ])
		sorted: true
]

{ #category : #query }
SystemNavigation >> allCallsOn: aLiteral localToPackage: packageNameOrInfo [
	"Answer a sorted collection of MethodReferences for all the methods that call on aLiteral in the given package."

	| result |
	result := self
				allCallsOn: aLiteral
				fromBehaviors: (self packageInfoFor: packageNameOrInfo) classesAndMetaClasses
				sorted: false.
	result := result, (self
						allCallsOn: aLiteral
						fromMethodReferences: (self packageInfoFor: packageNameOrInfo) extensionMethods
						sorted: false).
	^result sort
]

{ #category : #query }
SystemNavigation >> allCallsOnClass: aBehaviorOrBinding [
	"Answer a sorted collection of all the methods that refer to aBehavior."
	
	| binding thisClass result |
	binding := aBehaviorOrBinding isBehavior
		ifTrue: [self environment bindingOf: aBehaviorOrBinding theNonMetaClass name]
		ifFalse: [aBehaviorOrBinding].
	thisClass := binding value.
	
	result := self 
		allCallsOn: binding
		fromBehaviors: self allBehaviors
		sorted: false.

	self environment allClassesDo: [:otherClass |
		(otherClass sharedPools includes: thisClass) ifTrue: [
			result add: (ClassReference class: otherClass) ] ].
	
	^ result sort
]

{ #category : #query }
SystemNavigation >> allClasses [
	"currently returns all the classes defined in Smalltalk but could be customized 
	for dealing with environments and in such a case would return on really all the classes"

	^ self environment allClasses
]

{ #category : #query }
SystemNavigation >> allClassesAndTraits [
	
	^ self environment allClassesAndTraits

	
]

{ #category : #query }
SystemNavigation >> allClassesAndTraitsMatching: pattern [
	"Given a pattern and an environment, try to find a class or trait using several strategies:
		- EXACT: If there is a class or trait whose name exactly given by pattern, return it.
		- UPPER: If the pattern is upper-case only, find camel-case letters with that sequence.
		- WILD: Try the pattern as-is for regular wild-card search.
		- FEATURE: Split patterns at feature boundaries and insert wild cards between.
		- FUZZY: Split patterns at feature boundaries BUT treat each feature as a full class name.
	If there is only one class or trait in the given environment whose name matches pattern, return it. Otherwise, put up a menu offering the names of all classes that match pattern, and return the class chosen, else nil if nothing chosen.
	
	!! In any case, separator characters in the pattern are ignored."
	
	| toMatch potentialNames names |
	
	"If there's a class or trait named as pattern, then return it."
	(environment classOrTraitNamed: pattern) ifNotNil: [:classOrTrait | ^ {classOrTrait}].

	"Validate pattern."	
	toMatch := pattern copyWithoutAll: Character separators.
	toMatch := toMatch asLowercase copyWithout: $..
	toMatch ifEmpty: [ ^ #() ].

	"Fetch search space."
	names := OrderedCollection new.
	potentialNames := environment classAndTraitNames.

	"Try uppercase-only patterns for patterns such as 'WKD' to find 'WeakIdentityKeyDictionary' etc."
	(pattern allSatisfy: [:char | char isUppercase]) ifTrue: [
		| patternSize |
		patternSize := pattern size.
		potentialNames do: [ :eachName | 
			| lookupIndex characterIndex |
			lookupIndex := 0.
			characterIndex := 1.
			[ (lookupIndex := eachName
					indexOf: (pattern at: characterIndex)
					startingAt: lookupIndex + 1) > 0
				and: [ (characterIndex := characterIndex + 1) <= patternSize ] ] whileTrue.
			lookupIndex > 0 ifTrue: [ names add: eachName ] ] ].
	
	"Try wildcard search for patterns such as 'Weak*Dict*' to find 'WeakIdentityKeyDictionary' etc."
	names ifEmpty: [
		potentialNames do: [ :each | (toMatch match: each) ifTrue: [ names add: each ] ].
		"Try feature-based search for patterns such as 'WeakDict' to find 'WeakIdentityKeyDictionary' etc."
		names ifEmpty: [
			"Insert wildcards before, between, and after features."
			toMatch := '*', ((pattern copyWithoutAll: '.*#') findFeatures joinSeparatedBy: '*'), '*'.
			potentialNames do: [ :each | (toMatch match: each) ifTrue: [ names add: each ] ] ] ].
	
	"Try some fuzzy matching."
	pattern suggestedTypeNames do: [ :each |
		(potentialNames includes: each) ifTrue: [ names add: each ] ].
	
	"Still no match?"
	^ names collect: [ :each | environment classOrTraitNamed: each ]

]

{ #category : #query }
SystemNavigation >> allClassesDo: aBlock [
	"currently returns all the classes defined in Smalltalk but could be customized 
	for dealing with environments and  in such a case would work on really all the classes"

	^ self environment allClassesDo: aBlock

	
]

{ #category : #query }
SystemNavigation >> allClassesImplementing: aSelector [  
	"Answer an collection of all classes that implement the message aSelector."

	| result |
	result := OrderedCollection new.
	self allBehaviorsDo: [ :behavior | 
		(behavior includesSelector: aSelector) ifTrue: [
			result add: behavior ] ].
	^result
]

{ #category : #query }
SystemNavigation >> allGlobalRefs [
	"Answer a set of symbols that may be refs to Global names.  In some sense we should only need the associations, but this will also catch, eg, HTML tag types."

	^ self allGlobalRefsWithout: {{}. {}}
]

{ #category : #query }
SystemNavigation >> allGlobalRefsWithout: classesAndMessagesPair [ 
	"Answer a set of symbols that may be refs to Global names. In some  
	sense we should only need the associations, but this will also catch, eg,  
	HTML tag types. This method computes its result in the absence of  
	specified classes and messages."

	| globalRefs absentClasses absentSelectors |
	globalRefs := IdentitySet new: CompiledMethod instanceCount.
	absentClasses := classesAndMessagesPair first.
	absentSelectors := classesAndMessagesPair second.
	"sd 29/04/03"
	Cursor execute
		showWhile: [self environment allClassesAndTraitsDo:
				[:cls | ((absentClasses includes: cls)
						ifTrue: [{}]
						ifFalse: [{cls. cls class}])
						do: [:cl | (absentSelectors isEmpty
								ifTrue: [cl selectors]
								ifFalse: [cl selectors copyWithoutAll: absentSelectors])
								do: [:sel | "Include all capitalized symbols for good 
									measure"
									(cl compiledMethodAt: sel) allLiteralsDo: [:m |
										((m isSymbol)
												and: [m size > 0
														and: [m first canBeGlobalVarInitial]])
											ifTrue: [globalRefs add: m].
										]]]]].
	^ globalRefs
]

{ #category : #query }
SystemNavigation >> allImplementedMessages [
	"Answer a set of all the messages that are implemented in the system."
	
	^self allImplementedMessagesWithout: #(() ())
]

{ #category : #query }
SystemNavigation >> allImplementedMessagesWithout: behaviorsAndSelectorsPair [ 
	"Answer a set of all the selectors that are implemented in the system, computed in the absence of the supplied behaviors and selectors."
	
	| selectors behaviorsToReject |
	selectors := IdentitySet new.
	behaviorsToReject := behaviorsAndSelectorsPair first asIdentitySet.
	self environment allClassesAndTraitsDo: [ :behavior |
		(behaviorsToReject includes: behavior name) ifFalse: [
			selectors
				addAll: behavior selectors;
				addAll: behavior classSide selectors ] ].
	behaviorsAndSelectorsPair second do: [ :each |
		selectors remove: each ].
	^selectors
]

{ #category : #query }
SystemNavigation >> allImplementorsOf: aSelector [ 
	"Answer a sorted collection of all the methods which are named aSelector."
	
	| result |
	result := OrderedCollection new.
	self allBehaviorsDo: [ :class |
		(class includesSelector: aSelector) ifTrue: [
			result add: (MethodReference class: class selector: aSelector) ] ].
	^result sort
]

{ #category : #query }
SystemNavigation >> allImplementorsOf: aSelector localTo: aClass [ 
	"Answer a sorted collection of all the methods that are named aSelector in, above, or below the given class."
	
	| result |
	result := OrderedCollection new.
	aClass theNonMetaClass withAllSuperAndSubclassesDoGently: [:class |
		(class includesSelector: aSelector) ifTrue: [
			result add: (MethodReference class: class selector: aSelector) ].
		(class class includesSelector: aSelector) ifTrue: [
			result add: (MethodReference class: class class selector: aSelector) ] ].
	^result sort
]

{ #category : #query }
SystemNavigation >> allImplementorsOf: aSelector  localToPackage: packageNameOrInfo [
	"Answer a sorted collection of all the methods named aSelector in the given package."

	| result |
	result := OrderedCollection new.
	(self packageInfoFor: packageNameOrInfo) actualMethodsDo: [ :method |
		method selector = aSelector ifTrue: [
			result add: method methodReference ] ].
	^result sort
]

{ #category : #browse }
SystemNavigation >> allMethodsInCategory: category [ 
	| aCollection |
	aCollection := OrderedCollection new.
	Cursor wait showWhile:
		[self allBehaviorsDo:
			[:x | (x methodsInCategory: category) do:
				[:sel | aCollection add: x name , ' ' , sel]]].
	^aCollection sort
]

{ #category : #query }
SystemNavigation >> allMethodsSelect: aBlock [ 
	"Answer a sorted collection of each method that, when used as the block  
	argument to aBlock, gives a true result."
	
	| result |
	result := OrderedCollection new.
	self allSelectorsAndMethodsDo: [ :behavior :selector :method |
		(aBlock value: method) ifTrue: [
			result add: (MethodReference class: behavior selector: selector) ] ].
	^result sort
]

{ #category : #query }
SystemNavigation >> allMethodsSelect: aBlock localTo: aClass [
	"Answer a SortedCollection of each methodr in, above, or below the given
	 class that, when used as the argument to aBlock, gives a true result."

	| aSet collectInSet |
	aSet := Set new.
	collectInSet := [:class |
		class selectorsAndMethodsDo:
			[:aSelector :aMethod|
			(aBlock value: aMethod) ifTrue:
				[aSet add: (MethodReference class: class selector: aSelector)]]].
	Cursor wait showWhile:
		[aClass theNonMetaClass
			withAllSuperAndSubclassesDoGently: collectInSet.
		aClass theNonMetaClass class
			withAllSuperAndSubclassesDoGently: collectInSet].
	^aSet
]

{ #category : #query }
SystemNavigation >> allMethodsSelect: aBlock localToPackage: packageNameOrInfo [
	"Answer a sorted collection of each method in the given package for which the evaluation of aBlock with the method answers true."

	| result |
	result := OrderedCollection new.
	(self packageInfoFor: packageNameOrInfo) actualMethodsDo: [ :aMethod |
		(aBlock value: aMethod) ifTrue: [
			result add: aMethod methodReference ] ].
	^result sort
]

{ #category : #query }
SystemNavigation >> allMethodsWithSourceString: aString matchCase: caseSensitive [
	"Answer a sorted collection of all the methods that contain, in source code, aString as a substring. Search the class comments also"

	| result |
	result := OrderedCollection new.
	CurrentReadOnlySourceFiles cacheDuring: [
		'Searching all source code...'
			displayProgressFrom: 0 to: Smalltalk classNames size
			during: [ :bar |
				| count previousBehavior |
				count := 0.
				previousBehavior := nil.
				self allSelectorsAndMethodsDo: [ :behavior :selector :method |
					behavior == previousBehavior ifFalse: [
						bar value: (count := count + 1).
						previousBehavior := behavior.
						(behavior organization classComment asString
							includesSubstring: aString
							caseSensitive: caseSensitive) ifTrue: [
								result add: (MethodReference class: behavior selector: #Comment) ] ].
					(method getSource asString
						includesSubstring: aString
						caseSensitive: caseSensitive) ifTrue: [
							result add: (MethodReference class: behavior selector: selector) ] ] ] ].
	^result sort
]

{ #category : #browse }
SystemNavigation >> allMethodsWithString: aString matchCase: caseSensitive [
	"Answer a set of MdethodReferences for all methods that contain string literals with aString as a substring.
	 Make the search case-sensitive or insensitive as dictated by the caseSensitive boolean parameter."

	^self allMethodsSelect:
		[ :method | | selector messages |
		method hasLiteralSuchThat:
			[ :literal |
			 literal isString
			 and: [ (literal includesSubstring: aString caseSensitive: caseSensitive)
			 and: [ literal isSymbol
					ifFalse: [ true ]
					ifTrue:
						[((selector ifNil: [ selector := method selector ]) == literal 
						  or: [ (messages ifNil: [ messages := method messages ]) includes: literal ]) not ] ] ] ] ]
]

{ #category : #query }
SystemNavigation >> allObjects [
	"Answer an Array of all objects in the system.  Fail if
	 there isn't enough memory to instantiate the result."
	<primitive: 178>
	^self primitiveFailed
]

{ #category : #query }
SystemNavigation >> allObjectsDo: aBlock [ 
	"Evaluate the argument, aBlock, for each object in the system, excluding immediates
	 such as SmallInteger and Character."
	self allObjectsOrNil
		ifNotNil: [:allObjects| allObjects do: aBlock]
		ifNil:
			["Fall back on the old single object primitive code.  With closures, this needs
			  to use an end marker (lastObject) since activation of the block will create
			  new contexts and cause an infinite loop.  The lastObject must be created
			  before calling someObject, so that the VM can settle the enumeration (e.g.
			  by flushing new space) as a side effect of  someObject"
			| object lastObject |
			lastObject := Object new.
			object := self someObject.
			[lastObject == object or: [0 == object]] whileFalse:
				[aBlock value: object.
				 object := object nextObject]]
]

{ #category : #query }
SystemNavigation >> allObjectsOrNil [
	"Answer an Array of all objects in the system.  Fail if there isn't
	 enough memory to instantiate the result and answer nil."
	<primitive: 178>
	^nil
]

{ #category : #query }
SystemNavigation >> allObjectsSelect: aBlock [ 
	"Evaluate the argument, aBlock, for each object in the system excluding 
	SmallIntegers. Return a collection af all objects for whom the value is 
	true. "
	^ Array
		streamContents: [:s | self
				allObjectsDo: [:object | (aBlock value: object)
						ifTrue: [s nextPut: object]]]
]

{ #category : #query }
SystemNavigation >> allPrimitiveMethods [
	"Answer a collection of all the methods that are implemented by primitives."

	| result |
	result := OrderedCollection new.
	self allSelectorsAndMethodsDo: [ :behavior :selector :method |
		method primitive ~= 0 ifTrue: [
			result add: (String streamContents: [ :stream |
				stream
					nextPutAll: behavior name;
					space;
					nextPutAll: selector;
					space;
					print: method primitive ]) ] ].
	^result
]

{ #category : #query }
SystemNavigation >> allPrimitiveMethodsInCategories: aList [ 
	"Answer an OrderedCollection of all the methods that are implemented by 
	primitives in the given categories. 1/26/96 sw"
	"SystemNavigation new allPrimitiveMethodsInCategories:  
	#('Collections-Streams' 'Files-Streams' 'Files-Abstract' 'Files-Macintosh')"

	| result categories |
	result := OrderedCollection new.
	categories := aList collect: [ :each | each asSymbol ].
	categories size > 10 ifTrue: [ categories := categories asIdentitySet ].
	self allBehaviorsDo: [ :behavior | 
		(aList includes: behavior category) ifTrue: [
			behavior selectorsAndMethodsDo: [ :selector :method | 
				method primitive ~= 0 ifTrue: [
					result add: (String streamContents: [ :stream |
						stream
							nextPutAll: behavior name;
							space;
							nextPutAll: selector;
							space;
							print: method primitive ]) ] ] ] ].
	^result
]

{ #category : #query }
SystemNavigation >> allReferencesToPool: aPool from: aClass [
	"Answer all the references to variables from aPool"
	| list |
	list := OrderedCollection new.
	aClass withAllSubclassesDo:[:cls|
		cls selectorsAndMethodsDo:[:sel :meth|
			(meth hasLiteralSuchThat: [:lit| lit isVariableBinding and:[(aPool bindingOf: lit key) notNil]]) ifTrue:
				[list add:(MethodReference class: cls selector: sel)]]].
	^list
]

{ #category : #query }
SystemNavigation >> allSelect: aBlock [ 
	"Answer a sorted collection of each method that, when used as the block argument to aBlock, gives a true result."

	| result |
	result := OrderedCollection new.
	self allSelectorsAndMethodsDo: [ :behavior :selector :method |
		(aBlock value: method) ifTrue: [
			result add: behavior name , ' ' , selector ] ].
	^result sort
]

{ #category : #query }
SystemNavigation >> allSelectorsAndMethodsDo: aBlock [ 
	"Evaluate aBlock for all selectors and methods of all behaviors in this image."
	
	self allBehaviorsDo: [ :behavior |
		behavior selectorsAndMethodsDo: [ :selector :method |
			aBlock value: behavior value: selector value: method ] ]
]

{ #category : #query }
SystemNavigation >> allSelectorsWithAnyImplementorsIn: selectorList [ 
	"Answer the subset of the given list which represent method selectors 
	which have at least one implementor in the system."
	| good |
	good := Set new.
	self allBehaviorsDo: [:class | selectorList
				do: [:aSelector | (class includesSelector: aSelector)
						ifTrue: [good add: aSelector]]].
	^good sorted

	" 
	SystemNavigation new selectorsWithAnyImplementorsIn: #( contents 
	contents: nuts)
	"
]

{ #category : #query }
SystemNavigation >> allSentMessages [
	"Answer the set of selectors which are sent somewhere in the system."
	^ self  allSentMessagesWithout: {{}. {}}
]

{ #category : #query }
SystemNavigation >> allSentMessagesWithout: classesAndMessagesPair [ 
	"Answer the set of selectors which are sent somewhere in the system,  
	computed in the absence of the supplied classes and messages."
	| sent absentClasses absentSelectors |
	sent := IdentitySet new: CompiledMethod instanceCount.
	absentClasses := classesAndMessagesPair first.
	absentSelectors := classesAndMessagesPair second.
	"sd 29/04/03"
	Cursor execute showWhile: [
		self environment allClassesAndTraitsDo: [:cls |
			((absentClasses includes: cls)
				ifTrue: [{}]
				ifFalse: [{cls. cls classSide}])
					do: [:each | (absentSelectors isEmpty
						ifTrue: [each selectors]
						ifFalse: [each selectors copyWithoutAll: absentSelectors])
						do: [:sel | "Include all sels, but not if sent by self"
							(each compiledMethodAt: sel) allLiteralsDo: [:m | 
								self flag: #dicuss. "mt: How to distinguish a symbol from a selector?"
								(m isSymbol and: [m size > 0 and: [m first isLowercase]])
									ifTrue: ["might be sent"
										m == sel ifFalse: [sent add: m]].
									]]]]].
	"The following may be sent without being in any literal frame"
	Smalltalk specialSelectorNames do: [:sel | sent add: sel].
	Smalltalk presumedSentMessages	do: [:sel | sent add: sel].
	^ sent.
]

{ #category : #query }
SystemNavigation >> allStoresInto: globalVarName [
	"Answer a collection of method references for all methods in the current environment that assign to the globalVarName. Also supports variables from shared pools."
	"self new allStoresInto: 'ActiveWorld'."

	| result |
	result := OrderedCollection new.
	self allClasses do: [:class |
		(class theNonMetaClass whichMethodsStoreInto: globalVarName) do: [:method |
			result add: method methodReference].
		(class theMetaClass whichMethodsStoreInto: globalVarName) do: [:method |
			result add: method methodReference]].
	^result
]

{ #category : #query }
SystemNavigation >> allStoresInto: varName from: aClass [
	"Answer a collection of method references for all the aClass' methods or any methods of a subclass/superclass that assign to the varName. If aClass is a SharedPool, consider all classes in the current environment that refer to that pool."
	"self new allStoresInto: 'contents' from: Collection."
	"self new allStoresInto: 'DayNames' from: ChronologyConstants."
	
	| result roots |
	result := OrderedCollection new.
	(aClass theNonMetaClass inheritsFrom: SharedPool) ifTrue:
		[roots := self allClasses select: [:class| class sharedPools includes: aClass theNonMetaClass].
		  roots do:
			[:root|
			 root withAllSubclassesDo:
				[:class|
				 (class whichMethodsStoreInto: varName), 
				 (class class whichMethodsStoreInto: varName) do:
					[:eachMethod|
					 result add: eachMethod methodReference]]]].
	aClass withAllSubAndSuperclassesDo:
		[ : class |
		(class theNonMetaClass whichMethodsStoreInto: varName),
		(class theMetaClass whichMethodsStoreInto: varName) do:
			[ : eachMethod |
			result add: eachMethod methodReference ] ].
	^result
]

{ #category : #query }
SystemNavigation >> allUnSentMessages [
	"SystemNavigation new allUnSentMessages"
	"Answer the set of selectors that are implemented by some object in the  
	system but not sent by any."
	^ self allUnSentMessagesWithout: {{}. {}}
]

{ #category : #query }
SystemNavigation >> allUnSentMessagesIn: selectorSet [ 
	"Answer the subset of selectorSet which are not sent anywhere in the 
	system. "
	^ selectorSet copyWithoutAll: self allSentMessages
]

{ #category : #query }
SystemNavigation >> allUnSentMessagesWithout: classesAndMessagesPair [ 
	"Answer the set of selectors that are implemented but not sent, computed  
	in the absence of the supplied classes and messages."
	^ (self  allImplementedMessagesWithout: classesAndMessagesPair)
		copyWithoutAll: (self  allSentMessagesWithout: classesAndMessagesPair)
]

{ #category : #query }
SystemNavigation >> allUnboundMethods [
	"Answer all CompiledMehtods that are not in the class hierarchy"
	"self systemNavigation allUnboundMethods"
	^CompiledMethod allSubInstances select:
		[:m|
		 m methodClass
			ifNil: [true]
			ifNotNil:
				[:mc|
				(mc compiledMethodAt: m selector ifAbsent: []) ~~ m]]
]

{ #category : #query }
SystemNavigation >> allUncommentedMethodsWithInitials: targetInitials [
	"Return a sorted collection with all uncommented methods whose initials (in the
	time-stamp, as logged to disk) match the given initials, in chronological order."

	^CurrentReadOnlySourceFiles cacheDuring: [
		| result |
		result := OrderedCollection new.
		self allSelectorsAndMethodsDo: [ :behavior :selector :method |
			method timeStamp ifNotEmptyDo: [ :timeStamp |
				| initials |
				initials := timeStamp substrings first.
				initials first isDigit ifFalse: [
					(initials = targetInitials and: [ 
						(behavior firstPrecodeCommentFor: selector) isNil ]) ifTrue: [
							result add: (MethodReference
								class: behavior
								selector: selector ) ] ] ] ].
		result ]
]

{ #category : #query }
SystemNavigation >> allUnimplementedCalls [
	"Answer a collection of each message that is sent by an expression in a method but is not implemented by any object in the system."

	| result implementedMessages |
	implementedMessages := self allImplementedMessages.
	result := OrderedCollection new.
	self allSelectorsAndMethodsDo: [ :behavior :selector :method |
		method selectorsDo: [ :each |
			(implementedMessages includes: each) ifFalse: [
					result add: (String streamContents: [ :stream |
						stream
							nextPutAll: behavior name;
							space;
							nextPutAll: selector;
							space;
							nextPutAll: 'calls: ';
							nextPutAll: each ]) ] ] ].
	^result
]

{ #category : #query }
SystemNavigation >> allUnimplementedNonPrimitiveCalls [
	"Answer an collection of each message that is sent by an expression in a method but is not implemented by any object in the system. This list won't include primitive methods."

	| result implementedMessages |
	implementedMessages := self allImplementedMessages.
	result := OrderedCollection new.
	self allSelectorsAndMethodsDo: [ :behavior :selector :method |
		method primitive = 0 ifTrue: [
			method selectorsDo: [ :each |
				(implementedMessages includes: each) ifFalse: [
					result add: (String streamContents: [ :stream |
						stream
							nextPutAll: behavior name;
							space;
							nextPutAll: selector;
							space;
							nextPutAll: 'calls: ';
							nextPutAll: each ]) ] ] ] ].
	^result
]

{ #category : #query }
SystemNavigation >> allUnreferencedClassVariablesOf: aClass [
	"Answer a list of the names of all the receiver's unreferenced class  
	vars, including those defined in superclasses"
	| aList |
	aList := OrderedCollection new.
	aClass withAllSuperclasses
		reverseDo: [:aSuperClass | aSuperClass classVarNames
				do: [:var | (self allCallsOn: (aSuperClass classPool associationAt: var)) isEmpty
						ifTrue: [aList add: var]]].
	^ aList
]

{ #category : #query }
SystemNavigation >> allUnusedClassesWithout: classesAndMessagesPair [ 
	"Enumerates all classes in the system and returns a list of those that are 
	apparently unused. A class is considered in use if it (a) has subclasses  
	or (b) is referred to by some method or (c) has its name in use as a  
	literal."
	"SystemNavigation new unusedClasses"

	| unused |
	unused := self environment classNames asIdentitySet
				copyWithoutAll: (self allGlobalRefsWithout: classesAndMessagesPair).
	^ unused
		reject: [:cName | | cl | 
			cl := self environment at: cName.
			cl subclasses isEmpty not
				or: [cl inheritsFrom: FileDirectory]]
]

{ #category : #browse }
SystemNavigation >> browseAllAccessesTo: instVarName from: aClass [
	"Create and schedule a Message Set browser for all the receiver's methods or any methods of a subclass/superclass that refer to the instance variable name."
	"self new browseAllAccessesTo: 'contents' from: Collection."
	
	^ self 
		browseMessageList: [ (self allAccessesTo: instVarName from: aClass) sort ]
		name: ('Accesses to {1} from {2}' translated format: {instVarName. aClass name})
		autoSelect: instVarName
]

{ #category : #browse }
SystemNavigation >> browseAllCallsOn: aLiteral [ 
	"Create and schedule a message browser on each method that refers to aLiteral."
	"self default browseAllCallsOn: #open:label:."

	^ self headingAndAutoselectForLiteral: aLiteral do: [ :label :autoSelect |
		self
			browseMessageList: [ self allCallsOn: aLiteral ]
			name: label
			autoSelect: autoSelect]
]

{ #category : #browse }
SystemNavigation >> browseAllCallsOn: literal1 and: literal2 [ 
	"Create and schedule a message browser on each method that calls on the two Symbols, literal1 and literal2."
	"self default browseAllCallsOn: #at: and: #at:put:."
	| both autoSelect |
	both := { literal1. literal2}.
	autoSelect := both
					detect: [:ea| ea isSymbol]
					ifNone: [(both
								detect: [:ea| ea isVariableBinding and: [ea key isSymbol]]
								ifNone: []) ifNotNil: [:vb| vb key]].
	^self 
		browseMessageList: [ self allCallsOn: literal1 and: literal2 ]
		name: literal1 printString , ' -and- ' , literal2 printString
		autoSelect: autoSelect
]

{ #category : #browse }
SystemNavigation >> browseAllCallsOn: literal1 and: literal2 localToPackage: packageNameOrInfo [
	"Create and schedule a message browser on each method in the given package that refers to both literal1 and literal2."
	"self default browseAllCallsOn: #open:label: localToPackage: 'Tools'."

	^ self headingAndAutoselectForLiteral: literal1 do: [ :label :autoSelect |
		self
			browseMessageList: [ 
				self 
					allCallsOn: literal1
					and: literal2
					localToPackage: packageNameOrInfo ]
			name: label, ' local to package ', (self packageInfoFor: packageNameOrInfo) name
			autoSelect: autoSelect ]
]

{ #category : #browse }
SystemNavigation >> browseAllCallsOn: aLiteral from: aBehavior [
	"Create and schedule a Message Set browser for all the methods that call on aLiteral within aBehavior."
	"self default browseAllCallsOn: #/ from: Number"

	^self headingAndAutoselectForLiteral: aLiteral do: [ :label :autoSelect |
		self 
			browseMessageList: [ self  allCallsOn: aLiteral from: aBehavior ]
			name: label, ' from ', aBehavior name
			autoSelect: autoSelect ]

	
]

{ #category : #browse }
SystemNavigation >> browseAllCallsOn: aLiteral fromMethodReferences: methodReferences labelled: sourceLabel [
	"Create and schedule a Message Set browser for all the methods that call on aLiteral within methodReferences."

	^self
		headingAndAutoselectForLiteral: aLiteral
		do: [ :label :autoSelect |
			self 
				browseMessageList: [self allCallsOn: aLiteral
										fromMethodReferences: methodReferences
										sorted: true]
				name: label, ' from ', sourceLabel
				autoSelect: autoSelect]
]

{ #category : #browse }
SystemNavigation >> browseAllCallsOn: aLiteral localTo: aBehavior [
	"Create and schedule a message browser on each method in or below the given class that refers to aLiteral."
	"self default browseAllCallsOn: #open:label: localTo: CodeHolder"

	aBehavior ifNil: [ ^self inform: 'No behavior selected.' ].
	^ self headingAndAutoselectForLiteral: aLiteral do: [ :label :autoSelect |
		self
			browseMessageList:  [ self allCallsOn: aLiteral from: aBehavior ]
			name: label, ' local to ', aBehavior name
			autoSelect: autoSelect ]
]

{ #category : #browse }
SystemNavigation >> browseAllCallsOn: aLiteral localToPackage: packageNameOrInfo [
	"Create and schedule a message browser on each method in the given package that refers to aLiteral."
	"self default browseAllCallsOn: #open:label: localToPackage: 'Tools'."

	^ self headingAndAutoselectForLiteral: aLiteral do: [ :label :autoSelect |
		self
			browseMessageList: [ 
				self 
					allCallsOn: aLiteral
					localToPackage: packageNameOrInfo ]
			name: label, ' local to package ', (self packageInfoFor: packageNameOrInfo) name
			autoSelect: autoSelect ]
]

{ #category : #browse }
SystemNavigation >> browseAllCallsOnClass: aBehaviorOrBinding [
	"Create and schedule a message browser on each method that refers to aBehavior."
	"self default browseAllCallsOnClass: Array"
	
	| behaviorName |
	behaviorName := aBehaviorOrBinding isBehavior
		ifTrue: [aBehaviorOrBinding theNonMetaClass name]
		ifFalse: [aBehaviorOrBinding key].
	^ self
		browseMessageList: [ self allCallsOnClass: aBehaviorOrBinding ]
		name: 'Users of ', behaviorName
		autoSelect: behaviorName
]

{ #category : #browse }
SystemNavigation >> browseAllImplementorsOf: selector [ 
	"Create and schedule a message browser on each method that implements 
	the message whose selector is the argument, selector. For example,  
	Smalltalk browseAllImplementorsOf: #at:put:."
	^ self
		browseMessageList: (self allImplementorsOf: selector)
		name: 'Implementors of ' , selector
]

{ #category : #browse }
SystemNavigation >> browseAllImplementorsOf: selector localTo: aClass [ 
	"Create and schedule a message browser on each method in or below the  
	given class  
	that implements the message whose selector is the argument, selector.  
	For example,  
	SystemNavigation new browseAllImplementorsOf: #at:put: localTo:  
	Dictionary."
	aClass
		ifNil: [^ self inform: 'no class selected'].
	^ self
		browseMessageList: ((self allImplementorsOf: selector localTo: aClass)
				collect: [:methRef | methRef actualClass name , ' ' , methRef methodSymbol])
		name: 'Implementors of ' , selector , ' local to ' , aClass name
]

{ #category : #browse }
SystemNavigation >> browseAllImplementorsOf: selector localToPackage: packageNameOrInfo [
	"Create and schedule a message browser on each method in the given package
	that implements the message whose selector is the argument, selector. For example, 
	SystemNavigation new browseAllImplementorsOf: #at:put: localToPackage: 'Collections'."

	^ self browseMessageList: (self
								allImplementorsOf: selector
								localToPackage: packageNameOrInfo)
		name: 'Implementors of ' , selector,
				' local to package ', (self packageInfoFor: packageNameOrInfo) name
]

{ #category : #browse }
SystemNavigation >> browseAllImplementorsOfList: selectorList [
	"Create and schedule a message browser on each method that implements 
	the message whose selector is in the argument selectorList. For example, 
	Smalltalk browseAllImplementorsOf: #(at:put: size).
	1/16/96 sw: defer to the titled version"

	^ self browseAllImplementorsOfList: selectorList title: 'Implementors of all'
]

{ #category : #browse }
SystemNavigation >> browseAllImplementorsOfList: selectorList title: aTitle [ 
	"Create and schedule a message browser on each method that implements the message whose selector is in the argument selectorList."
	"For example, self new browseAllImplementorsOf: #(at:put: size). "
	
	| implementorLists |
	implementorLists := selectorList gather: [:each | 
		self allImplementorsOf: each ].
	implementorLists sort.
	^self browseMessageList: implementorLists name: aTitle
]

{ #category : #browse }
SystemNavigation >> browseAllMethodsInCategory: category [ 
	^self browseMessageList: (self allMethodsInCategory: category)
		name: category
]

{ #category : #browse }
SystemNavigation >> browseAllObjectReferencesTo: anObject except: objectsToExclude ifNone: aBlock [ 
	"Bring up a list inspector on the objects that point to anObject.
	If there are none, then evaluate aBlock on anObject.  "

	| aList shortName |
	aList := Utilities pointersTo: anObject except: objectsToExclude.
	aList size > 0 ifFalse: [^aBlock value: anObject].
	shortName := [(anObject name ifNil: [anObject printString]) contractTo: 20] ifError: ['a ' , anObject class name].
	^ aList inspectWithLabel: 'Objects pointing to ' , shortName
]

{ #category : #browse }
SystemNavigation >> browseAllReferencesToPool: poolOrName from: aClass [
	"Open a message list on all messages referencing the given pool"
	| pool list |
	(poolOrName isString)
		ifTrue:[pool := Smalltalk at: poolOrName asSymbol]
		ifFalse:[pool := poolOrName].
	list := self allReferencesToPool: pool from: aClass.
	^ self
		browseMessageList: list
		name: 'users of ', poolOrName name
]

{ #category : #browse }
SystemNavigation >> browseAllSelect: aBlock [ 
	"Create and schedule a message browser on each method that, when used 
	as the block argument to aBlock gives a true result. For example,  
	SystemNavigation new browseAllSelect: [:method | method numLiterals >  
	10]."
	^ self
		browseMessageList: (self allMethodsSelect: aBlock)
		name: 'selected messages'
]

{ #category : #browse }
SystemNavigation >> browseAllSelect: aBlock localTo: aClass [
	"Create and schedule a message browser on each method in or below the given class
	 that, when used as the block argument to aBlock gives a true result. For example,  
	 SystemNavigation default browseAllSelect: [:m | m numLiterals > 10] localTo: Morph."
	aClass ifNil: [^self inform: 'no class selected'].
	^self
		browseMessageList: (self allMethodsSelect: aBlock localTo: aClass) sorted
		name: 'selected messages local to ', aClass name
]

{ #category : #browse }
SystemNavigation >> browseAllSelect: aBlock localToPackage: packageNameOrInfo [
	"Create and schedule a message browser on each method in the given package
	 that, when used as the block argument to aBlock answers true. For example,  
		(SystemNavigation new
			browseAllSelect: [:method | method scanFor: 138]
			localToPackage: #System.)"
	^self
		browseMessageList: (self allMethodsSelect: aBlock localToPackage: packageNameOrInfo)
		name: 'selected messages local to package ', (self packageInfoFor: packageNameOrInfo) name
]

{ #category : #browse }
SystemNavigation >> browseAllSelect: aBlock name: aName autoSelect: autoSelectString [ 
	"Create and schedule a message browser on each method that, when used 
	as the block argument to aBlock gives a true result. Do not return an  
	#DoIt traces."
	"self new browseAllSelect: [:method | method numLiterals > 10] name:  
	'Methods with more than 10 literals' autoSelect: 'isDigit'"
	^ self
		browseMessageList: [ self allMethodsSelect: aBlock ]
		name: aName
		autoSelect: autoSelectString
]

{ #category : #browse }
SystemNavigation >> browseAllStoresInto: globalVarName [
	"Create and schedule a Message Set browser for all the methods in the current environment that assign to the globalVarName. Also supports variables from shared pools."
	"self new browseAllStoresInto: 'ActiveWorld'."

	^ self
		browseMessageList: (self allStoresInto: globalVarName)
		name: 'Stores into global ' , globalVarName
		autoSelect: globalVarName
]

{ #category : #browse }
SystemNavigation >> browseAllStoresInto: varName from: aClass [
	"Create and schedule a Message Set browser for all the aClass' methods or any methods of a subclass/superclass that assign to the varName. If aClass is a SharedPool, consider all classes in the current environment that refer to that pool."
	"self new browseAllStoresInto: 'contents' from: Collection."
	"self new browseAllStoresInto: 'DayNames' from: ChronologyConstants."
	
	^ self
		browseMessageList: (self allStoresInto: varName from: aClass)
		name: 'Stores into ' , varName
		autoSelect: varName
]

{ #category : #browse }
SystemNavigation >> browseAllUnSentMessages [
	"Create and schedule a message browser on each method whose message is  not sent in any method in the system."
	"self new browseAllUnSentMessages"

	^ self browseAllImplementorsOfList: self allUnSentMessages title: 'Messages implemented but not sent'
]

{ #category : #browse }
SystemNavigation >> browseAllUnimplementedCalls [
	"Create and schedule a message browser on each method that includes a 
	message that is not implemented in any object in the system."

	^self browseMessageList: self allUnimplementedCalls name: 'Unimplemented calls'
]

{ #category : #browse }
SystemNavigation >> browseClass: aBehaviorOrBinding [
	"Browse the class (1) as given, (2) from its meta class, (3) from a class binding, (4) of a global variable as given, (5) of a global variable from its global binding."
	
	| objectOrClass classOrMetaclass targetClass |
	objectOrClass := aBehaviorOrBinding value.
	classOrMetaclass := objectOrClass isBehavior
		ifTrue: [objectOrClass]
		ifFalse: [objectOrClass class].
	targetClass := classOrMetaclass isMeta
			ifTrue: [classOrMetaclass theNonMetaClass]
			ifFalse: [classOrMetaclass].
	^ ToolSet browseClass: targetClass
]

{ #category : #browse }
SystemNavigation >> browseClassCommentsWithString: aString [
	"Smalltalk browseClassCommentsWithString: 'my instances' "
	"Launch a message list browser on all class comments containing aString as a substring."

	| caseSensitive suffix list |

	suffix := (caseSensitive := Sensor shiftPressed)
		ifTrue: [' (case-sensitive)']
		ifFalse: [' (use shift for case-sensitive)'].
	list := Set new.
	Cursor wait showWhile: [
		Smalltalk allClassesDo: [:class | 
			(class organization classComment asString findString: aString 
							startingAt: 1 caseSensitive: caseSensitive) > 0 ifTrue: [
								list add: (
									MethodReference
										class: class
										selector: #Comment
								)
							]
		]
	].
	^ self 
		browseMessageList: list sorted
		name: 'Class comments containing ' , aString printString , suffix
		autoSelect: aString
]

{ #category : #browse }
SystemNavigation >> browseClassesWithNamesContaining: aString caseSensitive: caseSensitive [ 
	"SystemNavigation default browseClassesWithNamesContaining: 'eMorph' caseSensitive: true "
	"Launch a class-list list browser on all classes whose names containg aString as a substring."

	| suffix aList |
	suffix := caseSensitive
				ifTrue: [' (case-sensitive)']
				ifFalse: [' (use shift for case-sensitive)'].
	aList := OrderedCollection new.
	Cursor wait
		showWhile: [Smalltalk
				allClassesDo: [:class | (class name includesSubstring: aString caseSensitive: caseSensitive)
						ifTrue: [aList add: class name]]].
	^ ToolSet openClassListBrowser: aList asSet sorted title: 'Classes whose names contain ' , aString , suffix
]

{ #category : #browse }
SystemNavigation >> browseHierarchy: aBehavior [
	| targetClass |
	targetClass := aBehavior isMeta
				ifTrue: [aBehavior theNonMetaClass]
				ifFalse: [aBehavior ].
	^ ToolSet browseHierarchy: targetClass selector: nil
]

{ #category : #browse }
SystemNavigation >> browseMessageList: messageList name: label [ 
	"Create and schedule a MessageSet browser on messageList."
	^ self   
		browseMessageList: messageList 
		name: label 
		autoSelect: nil
]

{ #category : #browse }
SystemNavigation >> browseMessageList: messageListOrBlock name: labelString autoSelect: autoSelectString [
	"Create and schedule a MessageSet browser on the message list. If messageListOrBlock is a block, then evaluate it to get the message list."

	| messageList title |
	messageList := messageListOrBlock isBlock
		ifTrue: [ Cursor wait showWhile: messageListOrBlock ]
		ifFalse: [ messageListOrBlock ].
	messageList size = 0 ifTrue: [
		^self inform: 'There are no', String cr, labelString ].
	title := messageList size > 1
		ifFalse: [ labelString ]
		ifTrue: [ labelString, ' [', messageList size printString, ']' ].
	^ ToolSet 
		browseMessageSet: messageList 
		name: title 
		autoSelect: autoSelectString
]

{ #category : #browse }
SystemNavigation >> browseMethodsWhoseNamesContain: aString [
	"Launch a tool which shows all methods whose names contain the given string; case-insensitive.
·	1/16/1996 sw, at the dawn of Squeak: this was the classic implementation that provided the underpinning for the 'method names containing it' (cmd-shift-W) feature that has always been in Squeak -- the feature that later inspired the MethodFinder (aka SelectorBrowser).
·	sw 7/27/2001:	Switched to showing a MessageNames tool rather than a message-list browser, if in Morphic."

	^ Smalltalk isMorphic
		ifTrue: [ToolSet browseMessageNames: aString]
		ifFalse: [
			self
				browseAllImplementorsOfList: (Symbol selectorsContaining: aString)
				title: 'Methods whose names contain ''', aString, '''']
]

{ #category : #browse }
SystemNavigation >> browseMethodsWithLiteral: aString [
	"Launch a browser on all methods that contain string literals with aString as a substring. Make the search case-sensitive or insensitive as dictated by the caseSensitive boolean parameter"

	^ self browseAllSelect:
			[:method |
				method hasLiteralSuchThat: [:lit |
					(lit isString and: [lit isSymbol not]) and:
					[lit = aString]]]
		name:  'Methods with string ', aString printString
		autoSelect: aString
]

{ #category : #browse }
SystemNavigation >> browseMethodsWithSourceString: aString [ 
	"SystemNavigation new browseMethodsWithSourceString: 'SourceString'"
	"Launch a browser on all methods whose source code contains aString as 
	a substring."
	| caseSensitive suffix |
	suffix := (caseSensitive := Sensor shiftPressed)
				ifTrue: [' (case-sensitive)']
				ifFalse: [' (use shift for case-sensitive)'].
	^ self
		browseMessageList: (self allMethodsWithSourceString: aString matchCase: caseSensitive)
		name: 'Methods containing ' , aString printString , suffix
		autoSelect: aString
]

{ #category : #browse }
SystemNavigation >> browseMethodsWithString: aString [
	"Launch a browser on all methods that contain string literals with aString as a substring. The search is case-insensitive, unless the shift key is pressed, in which case the search is case-sensitive."

	'string for testing'.
	^ self browseMethodsWithString: aString matchCase: Sensor shiftPressed

	"SystemNavigation new browseMethodsWithString: 'Testing' matchCase: false"
	"SystemNavigation new browseMethodsWithString: 'Testing' matchCase: true"
]

{ #category : #browse }
SystemNavigation >> browseMethodsWithString: aString matchCase: caseSensitive [
	"Launch a browser on all methods that contain string literals with aString as a substring. Make the search case-sensitive or insensitive as dictated by the caseSensitive boolean parameter"

	^ self 
		browseMessageList: (self allMethodsWithString: aString matchCase: caseSensitive)
		name:  'Methods with string ', aString printString, (caseSensitive ifTrue: [' (case-sensitive)'] ifFalse: [' (case-insensitive)'])
		autoSelect: aString
]

{ #category : #browse }
SystemNavigation >> browseMyChanges [
	"Browse only the changes (in the changes file) by the current author."

	"SystemNavigation default browseMyChanges"

	^ self browseAllSelect: [ :method |
       method fileIndex > 1 "only look at changes file"
               and: [ method timeStamp beginsWith: Utilities authorInitials ]]
]

{ #category : #browse }
SystemNavigation >> browseObsoleteMethodReferences [
	"Open a browser on all referenced behaviors that are obsolete"

	"SystemNavigation default browseObsoleteMethodReferences"

	| list |
	list := self obsoleteMethodReferences.
	^ self 
		browseMessageList: list
		name: 'Method referencing obsoletes'
		autoSelect: nil
]

{ #category : #browse }
SystemNavigation >> browseObsoleteReferences [  
	"self new browseObsoleteReferences"

	| references |
	references := OrderedCollection new.
	(LookupKey allSubInstances select:
		[:x | ((x value isKindOf: Behavior) and: ['AnOb*' match: x value name]) or:
		['AnOb*' match: x value class name]]) 
		do: [:x | references addAll: (self allCallsOn: x)].
	^ self  
		browseMessageList: references 
		name: 'References to Obsolete Classes'
]

{ #category : #browse }
SystemNavigation >> browseUncommentedMethodsWithInitials: targetInitials [
	"Browse uncommented methods whose initials (in the time-stamp, as logged to disk) match the given initials.  Present them in chronological order.  CAUTION: It will take several seconds for this to complete."
	"Time millisecondsToRun: [SystemNavigation default browseUncommentedMethodsWithInitials: 'jm']"

	^ self
		browseMessageList: [ self allUncommentedMethodsWithInitials: targetInitials ] 
		name: 'Uncommented methods with initials ', targetInitials
		autoSelect: nil
]

{ #category : #browse }
SystemNavigation >> browseVariableAssignments: aClass [ 
	aClass chooseVarThenDo:
		[ : aVar | self
			browseAllStoresInto: aVar
			from: aClass ]
]

{ #category : #browse }
SystemNavigation >> browseVariableReferences: aClass [
	aClass chooseVarThenDo:
		[ : aVar | (aClass allInstVarNames includes: aVar)
			ifTrue:
				[ self
					browseAllAccessesTo: aVar
					from: aClass ]
			ifFalse: [ self browseAllCallsOn: aVar ] ]
]

{ #category : #ui }
SystemNavigation >> confirmRemovalOf: aSelector on: aClass [ 
	"Determine if it is okay to remove the given selector. Answer 1 if it  
	should be removed, 2 if it should be removed followed by a senders  
	browse, and 3 if it should not be removed."
	| count answer caption allCalls |
	allCalls := self allCallsOn: aSelector.
	(count := allCalls size) = 0
		ifTrue: [^ 1].
	"no senders -- let the removal happen without warning"
	count = 1
		ifTrue: [(allCalls first actualClass == aClass
					and: [allCalls first methodSymbol == aSelector])
				ifTrue: [^ 1]].
	"only sender is itself"
	caption := 'The message "{1}" has {2} sender{3}.' translated format: {aSelector. count. count > 1 ifTrue: ['s'] ifFalse: ['']}.

	answer := UIManager default 
		chooseFrom: #('Remove it'
				'Remove, then browse senders'
				'Don''t remove, but show me those senders'
				'Forget it -- do nothing -- sorry I asked') title: caption.
	answer = 3
		ifTrue: [self
				browseMessageList: allCalls
				name: 'Senders of ' , aSelector
				autoSelect: aSelector keywords first].
	answer = 0
		ifTrue: [answer := 3].
	"If user didn't answer, treat it as cancel"
	^ answer min: 3
]

{ #category : #private }
SystemNavigation >> environment [
	^ environment ifNil: [environment := Smalltalk globals].
]

{ #category : #private }
SystemNavigation >> headingAndAutoselectForLiteral: aLiteral do: binaryBlock [ 
	"Evaluate binaryBlock with either Users of ... or Senders of ... plus the auto-select string for the given literal.  aLiteral can be a Symbol, a VariableBinding or an arbitrary object."
	| autoSelect |
	^ aLiteral isSymbol
		ifTrue:
			[ binaryBlock
				value: 'Senders of ' , aLiteral
				value: aLiteral  ]
		ifFalse:
			[ autoSelect := aLiteral isVariableBinding
				ifTrue: [ aLiteral key ]
				ifFalse: [ aLiteral printString ].
			binaryBlock
				value: 'Users of ' , autoSelect
				value: autoSelect ]
]

{ #category : #query }
SystemNavigation >> hierarchyOfClassesSurrounding: aClass [
	"Answer a list of classes in the hierarchy both above and below the given class"
	"SystemNavigation default hierarchyOfClassesSurrounding: StringHolder"
	
	| list aClassNonMeta isMeta |
	aClass ifNil: [^ OrderedCollection new].
	aClass ifNil: [^ self].
	aClassNonMeta := aClass theNonMetaClass.
	isMeta := aClassNonMeta ~~ aClass.
	list := OrderedCollection new.
	aClass allSuperclasses reverseDo:
		[:cl | list addLast: cl].
	aClassNonMeta allSubclassesWithLevelDo:
		[:cl :level | | theClassOrMeta |
		theClassOrMeta := isMeta ifTrue: [cl class] ifFalse: [cl].
		list addLast: theClassOrMeta]
	 	startingLevel: 0.
	^ list


]

{ #category : #query }
SystemNavigation >> hierarchyOfImplementorsOf: aSelector forClass: aClass [
	"Answer a list of classes in the hierarchy both above and below the given class which implement the given selector."
	"SystemNavigation default hierarchyOfImplementorsOf: #contents forClass: StringHolder"

	^ (self hierarchyOfClassesSurrounding: aClass) select:
		[:cl | cl includesSelector: aSelector]

]

{ #category : #'initialize-release' }
SystemNavigation >> initializeWithEnvironment: anEnvironment [
	self initialize.
	environment := anEnvironment.
]

{ #category : #query }
SystemNavigation >> isThereAnImplementorOf: aSelector [ 
	"Answer true if there is at least one implementor of the selector found  
	in the system, false if there are no implementors"
	"self new isThereAnImplementorOf: #contents.  
	self new isThereAnImplementorOf: #nobodyImplementsThis."
	self 
		allBehaviorsDo: [:class | (class includesSelector: aSelector)
				ifTrue: [^ true]].
	^ false
]

{ #category : #browse }
SystemNavigation >> methodHierarchyBrowserForClass: aClass selector: selectorSymbol [
	"Create and schedule a message set browser on all implementors of the 
	currently selected message selector. Do nothing if no message is selected."
	"SystemNavigation default 
		methodHierarchyBrowserForClass: ParagraphEditor 
		selector: #isControlActive"
	| list aClassNonMeta isMeta tab compiledMethod window |
	aClass ifNil: [^ self].
	aClass isTrait ifTrue: [^ self].
	selectorSymbol ifNil: [^ self].
	aClassNonMeta := aClass theNonMetaClass.
	isMeta := aClassNonMeta ~~ aClass.
	list := OrderedCollection new.
	tab := ''.
	aClass allSuperclasses reverseDo:
		[:cl |
		(cl includesSelector: selectorSymbol) ifTrue:
			[list addLast: (MethodReference new
				setClass: cl
				methodSymbol: selectorSymbol
				stringVersion: tab , cl name, ' ', selectorSymbol)].
		tab := tab , '  '].
	aClassNonMeta allSubclassesWithLevelDo:
		[:cl :level | | theClassOrMeta stab |
		theClassOrMeta := isMeta ifTrue: [cl class] ifFalse: [cl].
		(theClassOrMeta includesSelector: selectorSymbol) ifTrue:
			[stab := ''.  1 to: level do: [:i | stab := stab , '  '].
			list addLast: (MethodReference new
				setClass: theClassOrMeta
				methodSymbol: selectorSymbol
				stringVersion: tab , stab , theClassOrMeta name, ' ', selectorSymbol)]]
	 	startingLevel: 0.
	window := self browseMessageList: list name: 'Inheritance of ' , selectorSymbol.
	window isSystemWindow ifTrue: 
		[ window model
			deselectAll ; 
			yourself.
		compiledMethod := aClass compiledMethodAt: selectorSymbol ifAbsent:[nil].
		compiledMethod ifNotNil: [ window model selectReference: compiledMethod methodReference ] ]
]

{ #category : #query }
SystemNavigation >> methodsWithUnboundGlobals [
	"Get all methods that use undeclared global objects that are not listed in Undeclared. For a clean image the result should be empty."

	"SystemNavigation new methodsWithUnboundGlobals"
	self flag: #environments.
	
	^self allSelect:
		[:m|
		m literals anySatisfy:
			[:l|
			l isVariableBinding
			and: [l key isSymbol "avoid class-side methodClass literals"
			and: [(m methodClass bindingOf: l key)
					ifNil: [(Undeclared associationAt: l key ifAbsent: []) ~~ l]
					ifNotNil: [:b| b ~~ l]]]]]
]

{ #category : #query }
SystemNavigation >> numberOfImplementorsOf: aSelector [ 
	"Answer a count of the implementors of the given selector found in the  
	system"
	"self new numberOfImplementorsOf: #contents.  
	self new numberOfImplementorsOf: #nobodyImplementsThis.  
	self new numberOfimplementorsOf: #numberOfImplementorsOf:."
	| aCount |
	aCount := 0.
	self
		allBehaviorsDo: [:class | (class includesSelector: aSelector)
				ifTrue: [aCount := aCount + 1]].
	^ aCount
]

{ #category : #query }
SystemNavigation >> obsoleteBehaviors [
	"SystemNavigation default obsoleteBehaviors inspect"
	"Find all obsolete behaviors including meta classes"

	| obs |
	obs := OrderedCollection new.
	Smalltalk garbageCollect.
	self 
		allObjectsDo: [:cl | (cl isBehavior
					and: [cl isObsolete])
				ifTrue: [obs add: cl]].
	^ obs asArray
]

{ #category : #query }
SystemNavigation >> obsoleteClasses [   

	"SystemNavigation default obsoleteClasses inspect"
	"NOTE:  Also try inspecting comments below"
	| obs |
	obs := OrderedCollection new.  Smalltalk garbageCollect.
	Metaclass allInstancesDo:
		[:m | | c |
		c := m soleInstance.
		(c ~~ nil and: ['AnOb*' match: c name asString])
			ifTrue: [obs add: c]].
	^ obs asArray

"Likely in a ClassDict or Pool...
(Association allInstances select: [:a | (a value isKindOf: Class) and: ['AnOb*' match: a value name]]) asArray
"
"Obsolete class refs or super pointer in last lit of a method...
| n l found |
SystemNavigation default browseAllSelect:
	[:m | found := false.
	1 to: m numLiterals do:
		[:i | (((l := m literalAt: i) isMemberOf: Association)
				and: [(l value isKindOf: Behavior)
				and: ['AnOb*' match: l value name]])
			ifTrue: [found := true]].
	found]
"
]

{ #category : #query }
SystemNavigation >> obsoleteMethodReferences [
	"SystemNavigation default obsoleteMethodReferences"

	"Open a browser on all referenced behaviors that are obsolete"

	| obsClasses references |
	references := WriteStream on: Array new.
	obsClasses := self obsoleteBehaviors.
	'Scanning for methods referencing obsolete classes' 
		displayProgressFrom: 1
		to: obsClasses size
		during: 
			[:bar | 
			obsClasses keysAndValuesDo: 
					[:index :each | | obsRefs | 
					bar value: index.
					obsRefs := Utilities pointersTo: each except: obsClasses.
					obsRefs do: 
							[:ref | 
							"Figure out if it may be a global"

							(ref isVariableBinding and: [ref key isString	"or Symbol"]) 
								ifTrue: 
									[(Utilities pointersTo: ref) do: 
											[:meth | 
											(meth isKindOf: CompiledMethod) 
												ifTrue: [meth methodReference ifNotNil: [:mref | references nextPut: mref]]]]]]].
	^references contents
]

{ #category : #private }
SystemNavigation >> packageInfoFor: packageInfoOrString [
	^packageInfoOrString isString
		ifTrue: [PackageInfo named: packageInfoOrString]
		ifFalse: [packageInfoOrString]
]

{ #category : #ui }
SystemNavigation >> showMenuOf: selectorCollection withFirstItem: firstItem ifChosenDo: choiceBlock [
	"Show a sorted menu of the given selectors, preceded by firstItem, and all
	abbreviated to 40 characters.  Evaluate choiceBlock if a message is chosen."

	^ self showMenuOf: selectorCollection withFirstItem: firstItem ifChosenDo: choiceBlock withCaption: nil
]

{ #category : #ui }
SystemNavigation >> showMenuOf: selectorCollection withFirstItem: firstItem ifChosenDo: choiceBlock withCaption: aCaption [
	"Show a sorted menu of the given selectors, preceded by firstItem.  Use aCaption as the menu title, if it is not nil.  Evaluate choiceBlock if a message is chosen."

	| index menuLabels sortedList |
	sortedList := selectorCollection sorted.
	menuLabels := Array streamContents: 
		[:strm | strm nextPut: firstItem.
		sortedList do: [:sel | strm nextPut: sel]].
	index := UIManager default chooseFrom: menuLabels lines: #(1).
	index = 1 ifTrue: [choiceBlock value: firstItem].
	index > 1 ifTrue: [choiceBlock value: (sortedList at: index - 1)]
]

{ #category : #browse }
SystemNavigation >> spawnHierarchyForClass: aClass selector: aSelector [
	"Create and schedule a new class hierarchy browser on the requested class/selector."
	"SystemNavigation default spawnHierarchyForClass: SmallInteger selector: #hash"

	(aClass == nil)  ifTrue: [^ self].
	^ ToolSet browseHierarchy: aClass selector: aSelector

]

{ #category : #query }
SystemNavigation >> unimplemented [
	"Answer an collection of each message that is sent by an expression in a method but is not implemented by any object in the system."

	| implemented unimplemented |
	implemented := self allImplementedMessages.
	unimplemented := IdentityDictionary new.
	self allSelectorsAndMethodsDo: [ :behavior :selector :method |
		method selectorsDo: [ :each |
			| entry |
			(implemented includes: each) ifFalse: [
				entry := unimplemented 
					at: each 
					ifPresent: [ :oldEntry |
						oldEntry copyWith: behavior name, '>', selector ]
					ifAbsent: [ 
						{ behavior name, '>', selector } ].
				unimplemented at: each put: entry ] ] ].
	^unimplemented
]

{ #category : #query }
SystemNavigation >> unusedBlocks [
	"Answer all methods that contain a block that is not used (not
	 sent a message, returned, passed as an argument, or assigned)."
	"SystemNavigation new unusedBlocks"
	"SystemNavigation new
		browseMessageList: SystemNavigation new unusedBlocks
		name: 'unused blocks'"

	^self allMethodsSelect:
		[:m| | is |
		is := InstructionStream on: m.
		is scanFor: [:b| b = 143 and: [(m at: is thirdByte * 256 + is fourthByte + is pc + 4) = 135]]]
]
