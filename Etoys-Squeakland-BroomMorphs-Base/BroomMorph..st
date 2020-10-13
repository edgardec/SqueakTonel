"
This is a Morph (actually a family of Morphs) that do alignment of other morphs.

BroomMorphs become: an object of one of their subclasses when dragged far enough.

Drag a BroomMorph in some direction and it becomes a broom that can align the Morphs it touches.

This idea is borrowed from the GEF framework (http://gef.tigris.org)

If you want to pick up a BroomMorph, you can use the Shift key.

Hitting the ESC key will re-position all moved Morphs to their original position.

BroomMorph newTransient will give you a BroomMorph that will delete itself on mouse up.

unmoved	the set of Morphs that I won't move
moved		the set of Morphs that I might move
start		my first hotspot
span		how wide to make (each half of) my bar initially
width		the width of the main lines
hotspot		my active position
lastHotspot	my last active position
drawBroomIcon	true if I look like a broom while idle (false=look like a +)
transient	if true, then I delete myself on mouse-up

"
Class {
	#name : #BroomMorph,
	#superclass : #Morph,
	#instVars : [
		'centered',
		'drawBroomIcon',
		'filter',
		'hotspot',
		'lastHotspot',
		'moved',
		'span',
		'start',
		'transient',
		'unmoved',
		'width'
	],
	#classVars : [
		'BroomIcon'
	],
	#category : #'Etoys-Squeakland-BroomMorphs-Base'
}

{ #category : #icons }
BroomMorph class >> broomIcon [
	"BroomMorph broomIcon openAsMorph"
	^BroomIcon ifNil: [ BroomIcon := ((ColorForm
	extent: 48@48
	depth: 8
	fromArray: #( 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294965235 2123104255 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294289468 792571391 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4250474910 4268775935 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4281003980 4040445339 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 3558577510 3456013868 3305111551 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4119016581 1223753318 1509949439 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294325096 1601695446 905969663 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294953525 2688143356 2354708479 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967163 1386041086 3779953919 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967294 730230149 4272828159 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4280259150 3556661084 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4284369021 1626460469 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294927207 1420492426 1308622847 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294937190 2120285430 1165885439 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294957119 1936237296 3090939903 4294967295 4294967295 4294967295 1314410239 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 980114393 4199311359 4294967295 4294967295 4294922751 3468260930 1409286143 4294967295 4294967295 4294967295 4294967295 4294967295 1985634676 4278069247 4294967295 4294967295 822072038 4259577561 1764753407 4294967295 4294967295 4294967295 4294967295 4294967295 3629150295 2650507588 4294967295 4294915958 3355115262 4143841013 4272170751 4294967295 4294967295 4294967295 4294967295 4294967295 4294926694 1526660645 2147418111 811775466 4278123248 4110024186 4209802495 4294967295 4294967295 4294967295 4294967295 4294967295 4291518587 1401683663 331415327 2949970174 4142920702 4261016571 4278113279 4294967295 4294967295 4294967295 4294967295 4294967295 4294967126 2521018110 1564595145 4177130745 4177394940 4226481918 3875468850 4294967295 4294967295 4294967295 4294967295 4294967295 4294966641 1818781950 4128018932 4227464691 4260888054 4193844470 4278022746 4294967295 4294967295 4294967295 4294967295 4294967295 4294957251 1082604973 4103079930 4227659000 4260949757 4260625918 4151583689 4294967295 4294967295 4294967295 4294967295 4294967295 4294966523 2254399056 4275306750 4259969533 4126735860 4160027632 1714067961 4294967295 4294967295 4294967295 4294967295 4294967295 3774129236 3427224966 2232244218 4009623029 4143840757 4227709222 1704204739 4294967295 4294967295 4294967295 4294967295 4294967281 3329305219 4274147615 459535614 4261278453 4260753150 4270732152 2132872703 4294967295 4294967295 4294967295 4294967295 4294966951 995344887 3891984632 4244567550 4260690427 4076796361 1799391336 17564460 4294967295 4294967295 4294967295 4294967295 4274153014 2180382453 4261084157 4175822318 4059954686 4277316954 1602381320 643309831 4294967295 4294967295 4294967295 4294967282 2823377603 3942511613 4142661107 4260624381 4261016062 4052699741 2049901056 391839597 4294967295 4294967295 4294967295 4294894196 747109878 4260689915 4210947065 4260953586 4177395136 1851158651 553648145 1599406079 4294967295 4294967295 4294967295 4256715083 3203923193 4177133041 4210883322 4244305914 4244547905 1487161345 330496 2227240959 4294967295 4294967295 4294967295 4280716212 4160615158 4244110584 4261214970 4261280247 4135604607 2017591306 728003705 1908998143 4294967295 4294967295 4294967257 2301731170 4093376766 4277467390 4259968509 3959291337 1415802972 571015178 360829128 4294967295 4294967295 4294967295 4294967254 1790591001 4244501995 4093310961 4160159230 4126914352 2004436244 50331652 659736575 4294967295 4294967295 4294967295 4294967238 1761476611 2144730878 4160683517 4143772670 4203101036 1849950720 34150400 1526726655 4294967295 4294967295 4294967295 4294967245 1806603524 512422141 4177326578 4261346478 1567853403 419430418 27790 2499805183 4294967295 4294967295 4294967295 4294967295 2251944828 416179 4143369424 4142962521 2121937418 218103943 3075177727 4294967295 4294967295 4294967295 4294967295 4294967295 4030225866 2973499918 708410107 3394655628 1595344640 292229396 3218276351 4294967295 4294967295 4294967295 4294967295 3741319167 4292174133 2024384681 2646072943 1099787826 335808768 24831321 1996488703 4294967295 4294967295 4294967295 4294967295 4294967295 4294960585 1731939648 1162880122 2488537608 262165 842649087 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967246 4257768094 2930289509 420675584 173165056 1442840575 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4291847681 17632000 100663398 1027537151 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4290903836 152109071 5575935 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294954239 1392579628 436207615 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295 4294967295)
	offset: 0@0)
	colorsFromArray: #(#(0.0 0.0 0.0) #(0.004 0.004 0.004) #(0.008 0.008 0.008) #(0.012 0.012 0.012) #(0.016 0.016 0.016) #(0.02 0.02 0.02) #(0.023 0.023 0.023) #(0.027 0.027 0.027) #(0.031 0.031 0.031) #(0.035 0.035 0.035) #(0.039 0.039 0.039) #(0.043 0.043 0.043) #(0.047 0.047 0.047) #(0.051 0.051 0.051) #(0.055 0.055 0.055) #(0.059 0.059 0.059) #(0.063 0.063 0.063) #(0.066 0.066 0.066) #(0.07 0.07 0.07) #(0.074 0.074 0.074) #(0.078 0.078 0.078) #(0.082 0.082 0.082) #(0.086 0.086 0.086) #(0.09 0.09 0.09) #(0.094 0.094 0.094) #(0.098 0.098 0.098) #(0.102 0.102 0.102) #(0.106 0.106 0.106) #(0.109 0.109 0.109) #(0.113 0.113 0.113) #(0.117 0.117 0.117) #(0.121 0.121 0.121) #(0.125 0.125 0.125) #(0.129 0.129 0.129) #(0.133 0.133 0.133) #(0.137 0.137 0.137) #(0.141 0.141 0.141) #(0.145 0.145 0.145) #(0.149 0.149 0.149) #(0.152 0.152 0.152) #(0.156 0.156 0.156) #(0.16 0.16 0.16) #(0.164 0.164 0.164) #(0.168 0.168 0.168) #(0.172 0.172 0.172) #(0.176 0.176 0.176) #(0.18 0.18 0.18) #(0.184 0.184 0.184) #(0.188 0.188 0.188) #(0.192 0.192 0.192) #(0.196 0.196 0.196) #(0.199 0.199 0.199) #(0.203 0.203 0.203) #(0.207 0.207 0.207) #(0.211 0.211 0.211) #(0.215 0.215 0.215) #(0.219 0.219 0.219) #(0.223 0.223 0.223) #(0.227 0.227 0.227) #(0.231 0.231 0.231) #(0.235 0.235 0.235) #(0.239 0.239 0.239) #(0.242 0.242 0.242) #(0.246 0.246 0.246) #(0.25 0.25 0.25) #(0.254 0.254 0.254) #(0.258 0.258 0.258) #(0.262 0.262 0.262) #(0.266 0.266 0.266) #(0.27 0.27 0.27) #(0.274 0.274 0.274) #(0.278 0.278 0.278) #(0.282 0.282 0.282) #(0.285 0.285 0.285) #(0.289 0.289 0.289) #(0.293 0.293 0.293) #(0.297 0.297 0.297) #(0.301 0.301 0.301) #(0.305 0.305 0.305) #(0.309 0.309 0.309) #(0.313 0.313 0.313) #(0.317 0.317 0.317) #(0.321 0.321 0.321) #(0.325 0.325 0.325) #(0.328 0.328 0.328) #(0.333 0.333 0.333) #(0.337 0.337 0.337) #(0.341 0.341 0.341) #(0.345 0.345 0.345) #(0.349 0.349 0.349) #(0.353 0.353 0.353) #(0.357 0.357 0.357) #(0.361 0.361 0.361) #(0.365 0.365 0.365) #(0.369 0.369 0.369) #(0.372 0.372 0.372) #(0.376 0.376 0.376) #(0.38 0.38 0.38) #(0.384 0.384 0.384) #(0.388 0.388 0.388) #(0.392 0.392 0.392) #(0.396 0.396 0.396) #(0.4 0.4 0.4) #(0.404 0.404 0.404) #(0.408 0.408 0.408) #(0.412 0.412 0.412) #(0.415 0.415 0.415) #(0.419 0.419 0.419) #(0.423 0.423 0.423) #(0.427 0.427 0.427) #(0.431 0.431 0.431) #(0.435 0.435 0.435) #(0.439 0.439 0.439) #(0.443 0.443 0.443) #(0.447 0.447 0.447) #(0.451 0.451 0.451) #(0.455 0.455 0.455) #(0.458 0.458 0.458) #(0.462 0.462 0.462) #(0.466 0.466 0.466) #(0.47 0.47 0.47) #(0.474 0.474 0.474) #(0.478 0.478 0.478) #(0.482 0.482 0.482) #(0.486 0.486 0.486) #(0.49 0.49 0.49) #(0.494 0.494 0.494) #(0.498 0.498 0.498) #(0.501 0.501 0.501) #(0.505 0.505 0.505) #(0.509 0.509 0.509) #(0.513 0.513 0.513) #(0.517 0.517 0.517) #(0.521 0.521 0.521) #(0.525 0.525 0.525) #(0.529 0.529 0.529) #(0.533 0.533 0.533) #(0.537 0.537 0.537) #(0.541 0.541 0.541) #(0.544 0.544 0.544) #(0.548 0.548 0.548) #(0.552 0.552 0.552) #(0.556 0.556 0.556) #(0.56 0.56 0.56) #(0.564 0.564 0.564) #(0.568 0.568 0.568) #(0.572 0.572 0.572) #(0.576 0.576 0.576) #(0.58 0.58 0.58) #(0.584 0.584 0.584) #(0.587 0.587 0.587) #(0.591 0.591 0.591) #(0.595 0.595 0.595) #(0.599 0.599 0.599) #(0.603 0.603 0.603) #(0.607 0.607 0.607) #(0.611 0.611 0.611) #(0.615 0.615 0.615) #(0.619 0.619 0.619) #(0.623 0.623 0.623) #(0.627 0.627 0.627) #(0.63 0.63 0.63) #(0.634 0.634 0.634) #(0.638 0.638 0.638) #(0.642 0.642 0.642) #(0.646 0.646 0.646) #(0.65 0.65 0.65) #(0.654 0.654 0.654) #(0.658 0.658 0.658) #(0.662 0.662 0.662) #(0.667 0.667 0.667) #(0.671 0.671 0.671) #(0.674 0.674 0.674) #(0.678 0.678 0.678) #(0.682 0.682 0.682) #(0.686 0.686 0.686) #(0.69 0.69 0.69) #(0.694 0.694 0.694) #(0.698 0.698 0.698) #(0.702 0.702 0.702) #(0.706 0.706 0.706) #(0.71 0.71 0.71) #(0.714 0.714 0.714) #(0.717 0.717 0.717) #(0.721 0.721 0.721) #(0.725 0.725 0.725) #(0.729 0.729 0.729) #(0.733 0.733 0.733) #(0.737 0.737 0.737) #(0.741 0.741 0.741) #(0.745 0.745 0.745) #(0.749 0.749 0.749) #(0.753 0.753 0.753) #(0.757 0.757 0.757) #(0.761 0.761 0.761) #(0.764 0.764 0.764) #(0.768 0.768 0.768) #(0.772 0.772 0.772) #(0.776 0.776 0.776) #(0.78 0.78 0.78) #(0.784 0.784 0.784) #(0.788 0.788 0.788) #(0.792 0.792 0.792) #(0.796 0.796 0.796) #(0.8 0.8 0.8) #(0.804 0.804 0.804) #(0.807 0.807 0.807) #(0.811 0.811 0.811) #(0.815 0.815 0.815) #(0.819 0.819 0.819) #(0.823 0.823 0.823) #(0.827 0.827 0.827) #(0.831 0.831 0.831) #(0.835 0.835 0.835) #(0.839 0.839 0.839) #(0.843 0.843 0.843) #(0.847 0.847 0.847) #(0.85 0.85 0.85) #(0.854 0.854 0.854) #(0.858 0.858 0.858) #(0.862 0.862 0.862) #(0.866 0.866 0.866) #(0.87 0.87 0.87) #(0.874 0.874 0.874) #(0.878 0.878 0.878) #(0.882 0.882 0.882) #(0.886 0.886 0.886) #(0.89 0.89 0.89) #(0.893 0.893 0.893) #(0.897 0.897 0.897) #(0.901 0.901 0.901) #(0.905 0.905 0.905) #(0.909 0.909 0.909) #(0.913 0.913 0.913) #(0.917 0.917 0.917) #(0.921 0.921 0.921) #(0.925 0.925 0.925) #(0.929 0.929 0.929) #(0.933 0.933 0.933) #(0.936 0.936 0.936) #(0.94 0.94 0.94) #(0.944 0.944 0.944) #(0.948 0.948 0.948) #(0.952 0.952 0.952) #(0.956 0.956 0.956) #(0.96 0.96 0.96) #(0.964 0.964 0.964) #(0.968 0.968 0.968) #(0.972 0.972 0.972) #(0.976 0.976 0.976) #(0.979 0.979 0.979) #(0.983 0.983 0.983) #(0.987 0.987 0.987) #(0.991 0.991 0.991) #(0.995 0.995 0.995) #( )  )) ]
]

{ #category : #'parts bin' }
BroomMorph class >> descriptionForPartsBin [
	^ self partName: 	'Broom' translatedNoop
		categories:		{'Graphics' translatedNoop}
		documentation:	'A broom to align Morphs with' translatedNoop
]

{ #category : #'instance creation' }
BroomMorph class >> newCentered [
	"return a BroomMorph that will align Morph centers"
	"BroomMorph newCentered openInHand"
	^(self new) centered: true
]

{ #category : #'instance creation' }
BroomMorph class >> newTransient [
	"return a BroomMorph that will delete itself on mouse-up"

	"BroomMorph newTransient openInHand"

	^self new transient: true
]

{ #category : #'instance creation' }
BroomMorph class >> newTransientInHand [

	"return a BroomMorph that will delete itself on mouse-up"

	"BroomMorph newTransientInHand"

	^self newTransient openInHand
]

{ #category : #private }
BroomMorph >> affectedMorphs [
	"Answer all the morphs that I should be moving"
	^ #()
]

{ #category : #private }
BroomMorph >> basicClass [
	^BroomMorph
]

{ #category : #accessing }
BroomMorph >> centered: aBoolean [
	"If aBoolean is true, I align morphs on their H or V centerlines"
	centered := aBoolean.
]

{ #category : #accessing }
BroomMorph >> drawBroomIcon: aBoolean [
	"If aBoolean is true, then I draw a cute broom icon; otherwise I draw a cross"
	drawBroomIcon := aBoolean.
	self changed.
]

{ #category : #drawing }
BroomMorph >> drawOn: aCanvas [
	drawBroomIcon
		ifTrue: [ aCanvas paintImage: self class broomIcon at: self position ]
		ifFalse: [ self drawPlusOn: aCanvas ].

]

{ #category : #drawing }
BroomMorph >> drawPlusOn: aCanvas [
	| halfWidth |
	halfWidth := width + 1 // 2.
	aCanvas line: bounds leftCenter + (halfWidth@0) to: bounds rightCenter + (halfWidth negated@0) width: width color: self color.
	aCanvas line: bounds topCenter + (0@halfWidth) to: bounds bottomCenter + (0@halfWidth negated) width: width color: self color.

]

{ #category : #accessing }
BroomMorph >> filter: aBlock [
	"Set my acceptance filter. aBlock should return true for all Morphs to be moved"
	filter := aBlock
]

{ #category : #'event handling' }
BroomMorph >> handlesKeyboard: evt [
	^true
]

{ #category : #'event handling' }
BroomMorph >> handlesMouseDown: evt [
	^evt shiftPressed not
]

{ #category : #'event handling' }
BroomMorph >> handlesMouseStillDown: evt [
	^true.
]

{ #category : #accessing }
BroomMorph >> hotspot [
	^hotspot
]

{ #category : #private }
BroomMorph >> hotspot: aPoint [
	lastHotspot := hotspot.
	hotspot := aPoint.
	^self center: aPoint
]

{ #category : #initialization }
BroomMorph >> initialize [
	super initialize.
	width := 5.
	span := 100.
	hotspot := self center.
	self reset.
	self color: Color blue muchDarker.
	self setBalloonText: 'Drag me to align other Morphs. Drag with the Shift key to move me without affecting other Morphs. Drag me with the second mouse button to align centers.' translated.
	drawBroomIcon := true.
	transient := false.
	centered := false.

]

{ #category : #'dropping\/grabbing' }
BroomMorph >> justDroppedInto: aMorph event: anEvent [
	super justDroppedInto: aMorph event: anEvent.
	aMorph isPlayfieldLike ifFalse: [ ^self delete ].
	self centered: anEvent hand lastEvent yellowButtonPressed.
	self transient ifFalse: [ ^self ].
		self reset.
		self hotspot: (start := anEvent position).
		anEvent hand newMouseFocus: self.
		anEvent hand newKeyboardFocus: self.
		"Cursor blank show."
]

{ #category : #'event handling' }
BroomMorph >> keyStroke: evt [
	evt keyCharacter ~= Character escape ifTrue: [ ^self ].
	evt hand releaseMouseFocus: self.
	evt hand releaseKeyboardFocus: self.
	Cursor normal show.
	moved keysAndValuesDo: [ :m :b | m bounds: b ].
	transient ifTrue: [ ^self delete ].
	self resetClass.
	self reset.
	self hotspot: start.

]

{ #category : #accessing }
BroomMorph >> lineWidth [
	^width
]

{ #category : #accessing }
BroomMorph >> lineWidth: aNumber [
	width := aNumber.
	self changed
]

{ #category : #'stepping and presenter' }
BroomMorph >> morphIfNecessary: yellowButtonPressed [
	| pt delta threshold cls center |
	center := yellowButtonPressed | centered.
	pt := self center.
	threshold := self width / 2.
	delta := pt - start.
	cls := delta x > threshold
				ifTrue: [center
						ifTrue: [CenterBroomMorphRight]
						ifFalse: [BroomMorphRight]]
				ifFalse: [delta x < threshold negated
						ifTrue: [center
								ifTrue: [CenterBroomMorphLeft]
								ifFalse: [BroomMorphLeft]]
						ifFalse: [delta y > threshold
								ifTrue: [center
										ifTrue: [CenterBroomMorphDown]
										ifFalse: [BroomMorphDown]]
								ifFalse: [delta y < threshold negated
										ifTrue: [center
												ifTrue: [CenterBroomMorphUp]
												ifFalse: [BroomMorphUp]]]]].
	cls
		ifNotNil: [self
				become: (self as: cls).
			self reset.
			self resetFilter.
			unmoved addAll: self affectedMorphs]
]

{ #category : #'event handling' }
BroomMorph >> mouseDown: evt [
	self reset.
	self resetFilter.
	self hotspot: (start := evt position).
	evt hand newMouseFocus: self.
	evt hand newKeyboardFocus: self.
	"Cursor blank show."
]

{ #category : #'event handling' }
BroomMorph >> mouseMove: evt [
	self hotspot: evt position.
	self moveMorphs: evt yellowButtonPressed
]

{ #category : #'event handling' }
BroomMorph >> mouseStillDown: evt [
	self hotspot: evt position.
	self moveMorphs: evt yellowButtonPressed
]

{ #category : #'event handling' }
BroomMorph >> mouseUp: evt [ 
	evt hand releaseMouseFocus: self.
	Cursor normal show.
	self rememberCommand: self undoCommand.
	transient ifTrue: [ ^self delete ].
	self resetClass.
	self reset.
	self hotspot: start.
]

{ #category : #'stepping and presenter' }
BroomMorph >> moveMorphs: yellowButtonPressed [
	"Move all the newly affected morphs and the ones I'm already moving."
	self class == self basicClass
		ifTrue: [^ self morphIfNecessary: yellowButtonPressed ].
	(((self affectedMorphs
		reject: [:m | unmoved includes: m])
		reject: [:m | moved includesKey: m])
		select: filter)
		do: [:m | moved at: m put: m bounds].
	moved
		keysAndValuesDo: [:m :b | self positionMorph: m originalBounds: b]
]

{ #category : #initialization }
BroomMorph >> openCenteredInHand [
	"BroomMorph new openCenteredInHand"
	"NCBroomMorph new openCenteredInHand"
	self centered: true.
	self openInHand.
]

{ #category : #initialization }
BroomMorph >> openTransientCenteredInHand [
	"BroomMorph new openTransientCenteredInHand"
	self transient: true.
	self centered: true.
	self openInHand.
]

{ #category : #initialization }
BroomMorph >> openTransientInHand [
	"BroomMorph new openTransientInHand"
	self transient: true.
	self openInHand.
]

{ #category : #initialization }
BroomMorph >> reset [
	moved := IdentityDictionary new.		"morph -> original bounds"
	unmoved := IdentitySet new.
	self resetExtent.
	filter := nil.

]

{ #category : #initialization }
BroomMorph >> resetClass [
	self become: (self as: self basicClass)
]

{ #category : #initialization }
BroomMorph >> resetExtent [
	super extent: self class broomIcon extent.
	hotspot := lastHotspot := self center.
]

{ #category : #initialization }
BroomMorph >> resetFilter [

	self filter: [ :m | true ].

]

{ #category : #accessing }
BroomMorph >> span [
	^span
]

{ #category : #accessing }
BroomMorph >> span: aNumber [
	span := aNumber.
	self hotspot: self hotspot.
	self changed.
]

{ #category : #accessing }
BroomMorph >> transient [
	^transient
]

{ #category : #accessing }
BroomMorph >> transient: aBoolean [
	"if aBoolean is true, then I delete myself on mouse-up"
	transient := aBoolean
]

{ #category : #undo }
BroomMorph >> undoCommand [
	| cmd args |
	cmd := Command new cmdWording: 'align morphs'.
	args := OrderedCollection new.
	moved keysAndValuesDo: [ :m :b |
		args add: { m. b. m bounds. m owner. m owner morphPreceding: m }
	].
	cmd undoTarget: self selector: #undoMove:redo:args: arguments: { cmd. false. args }.
	^cmd
]

{ #category : #undo }
BroomMorph >> undoMove: cmd redo: redo args: args [
	"morph oldbounds newbounds oldowner oldpredecessor"
	cmd redoTarget: self selector: #undoMove:redo:args: arguments: { cmd. true. args }.
	args do: [ :a | | morph oldbounds newbounds oldowner oldpredecessor |
		morph := a at: 1.
		oldbounds := a at: 2.
		newbounds := a at: 3.
		oldowner := a at: 4.
		oldpredecessor := a at: 5.
		oldowner ifNotNil: [ oldpredecessor ifNil: [ oldowner addMorphFront: morph ]
			ifNotNil: [ oldowner addMorph: morph after: oldpredecessor ]].
		morph bounds: (redo ifTrue: [ newbounds ] ifFalse: [ oldbounds ]).
		(morph isKindOf: SystemWindow) ifTrue: [ morph activate ].
	].
]
