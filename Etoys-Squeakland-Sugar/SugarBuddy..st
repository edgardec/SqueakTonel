Class {
	#name : #SugarBuddy,
	#superclass : #Object,
	#instVars : [
		'key',
		'nick',
		'border',
		'fill',
		'ip'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #'instance creation' }
SugarBuddy class >> fromDictionary: aDict [
	| buddyClass |
	buddyClass := SugarBuddy.
	(aDict at: 'owner' ifAbsent: []) == true
		ifTrue: [
			buddyClass := SugarBuddyOwner.
			Utilities authorName: (aDict at: 'nick' ifAbsent: ['missing nick']) utf8ToSqueak composeAccents].

	^buddyClass
		key: (aDict at: 'key' ifAbsent: ['missing key'])
		nick: (aDict at: 'nick' ifAbsent: ['missing nick']) utf8ToSqueak composeAccents
		colors: (aDict at: 'color' ifAbsent: ['missing color']) 
		ip: (aDict at: 'ip4-address' ifAbsent: ['missing address'])

]

{ #category : #'instance creation' }
SugarBuddy class >> fromMesh [
	| menu item |
	menu := MenuMorph new.
	(SugarLauncher current buddies sorted: [:a :b | a nick < b nick]) do: [:each |
		each isOwner ifFalse: [
		menu add: each nick target: each selector: #openBadge.
		item := menu items last.
		item icon: (each xoFormExtent: (item height + 5) asPoint background: menu color)]].
	menu popUpInWorld

]

{ #category : #'instance creation' }
SugarBuddy class >> key: keyString nick: nickString border: borderColor fill: fillColor ip: ipString [
	"SugarBuddy key: '1234' nick: 'nick' border: Color green fill: Color yellow ip: '1.2.3.4'"
	^self new setKey: keyString nick: nickString border: borderColor fill: fillColor ip: ipString
]

{ #category : #'instance creation' }
SugarBuddy class >> key: keyString nick: nickString colors: colorString ip: ipString [
	"SugarBuddy key: '1234' nick: 'nick' colors: '#ff0000,#ffff00' ip: '1.2.3.4'"
	| colors |
	colors := (colorString findTokens: '#,') collect: [:c | Color fromString: c].
	colors size = 2 ifFalse: [colors := {Color black. Color white}].
	^self key: keyString nick: nickString border: colors first fill: colors second ip: ipString

]

{ #category : #'instance creation' }
SugarBuddy class >> owner [
	^SugarLauncher current ownerBuddy
]

{ #category : #accessing }
SugarBuddy >> border [
	^border

]

{ #category : #accessing }
SugarBuddy >> colors [
	^border asHTMLColor, ',', fill asHTMLColor
]

{ #category : #accessing }
SugarBuddy >> fill [
	^fill
]

{ #category : #accessing }
SugarBuddy >> ip [
	^ip
]

{ #category : #testing }
SugarBuddy >> isOwner [
	^false
]

{ #category : #accessing }
SugarBuddy >> key [
	^key
]

{ #category : #actions }
SugarBuddy >> makeBadge [
	| badge font ext |
	badge := NebraskaSenderMorph new
		userName: nick 
		userPicture: (self xoFormExtent: 61@53 background: Color veryVeryLightGray) 
		userEmail: 'who@where.net' 
		userIPAddress: ip;
		color: Color veryVeryLightGray;
		borderColor: Color gray.
	badge setProperty: #buddy toValue: self.
	#( tellAFriend emailAddress  startTelemorphic "startAudioChat" startNebraskaClient ipAddress checkOnAFriend )
		do: [:ea | badge hideField: ea].
	font := Preferences standardEToysFont.
	ext := (font widthOf: $m) + 2 @ font height.
	badge allMorphsDo: [:m |
		(m respondsTo: #font:) ifTrue: [m font: font].
		(m class == SimpleButtonMorph) ifTrue: [m extent: ext]].
	^ badge.
]

{ #category : #accessing }
SugarBuddy >> nick [
	^nick
]

{ #category : #actions }
SugarBuddy >> openBadge [

	^ self makeBadge openInHand.

]

{ #category : #printing }
SugarBuddy >> printOn: aStream [
	aStream
		print: self class;
		nextPut: $(;
		print: nick;
		nextPut: $)
]

{ #category : #'initialize-release' }
SugarBuddy >> setKey: keyString nick: nickString border: borderColor fill: fillColor ip: ipString [

	key := keyString.
	nick := nickString.
	border := borderColor.
	fill := fillColor.
	ip := ipString
]

{ #category : #private }
SugarBuddy >> xoFormExtent: aPoint background: aColor [

	| xo form |
	form := Form extent: aPoint depth: 16.
	form fillColor: aColor.
	xo := OLPCSupport xoCharacterWithHeight: aPoint y insideColor: fill outsideColor: border.
	form getCanvas translateBy: (aPoint // 2) - xo center during: [:c | c fullDrawMorph: xo].
	^form

]
