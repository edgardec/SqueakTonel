Class {
	#name : #ProjectLauncher,
	#superclass : #AbstractLauncher,
	#instVars : [
		'showSplash',
		'splashURL',
		'whichFlaps',
		'eToyAuthentificationServer'
	],
	#classVars : [
		'SplashMorph'
	],
	#category : #'System-Download'
}

{ #category : #accessing }
ProjectLauncher class >> splashMorph [
	^SplashMorph
]

{ #category : #accessing }
ProjectLauncher class >> splashMorph: aMorph [
	SplashMorph := aMorph.
]

{ #category : #'eToy login' }
ProjectLauncher >> cancelLogin [
	"This is fine - we just proceed here. Later we may do something utterly different ;-)"
	^self proceedWithLogin
]

{ #category : #'eToy login' }
ProjectLauncher >> doEtoyLogin [
	"Pop up the eToy login if we have a server that provides us with a known user list"

	"Find us a server who could do eToy authentification for us"
	eToyAuthentificationServer := 
		(ServerDirectory localProjectDirectories, ServerDirectory servers values)
			detect:[:any| any hasEToyUserList]
			ifNone:[nil].
	eToyAuthentificationServer "no server provides user information"
		ifNil:[^self startUpAfterLogin].
	self prepareForLogin.
	(Smalltalk at: #EtoyLoginMorph ifAbsent:[^self cancelLogin])
			loginAndDo:[:userName| self loginAs: userName]
			ifCanceled:[self cancelLogin].

]

{ #category : #running }
ProjectLauncher >> hideSplashMorph [
	SplashMorph ifNil:[^self].
	self showSplash
		ifFalse: [^self].
	SplashMorph delete.
	Project current world submorphs do:[:m| m visible: true]. "show all"

]

{ #category : #initialization }
ProjectLauncher >> initialize [
	super initialize.
	showSplash := true
]

{ #category : #running }
ProjectLauncher >> installProjectFrom: loader [
	self showSplashMorph.
	[[[
		loader installProject
	] on: ProjectViewOpenNotification
	  do:[:ex| ex resume: false] "no project view in plugin launcher"
	] on: ProgressInitiationException "no 'reading aStream' nonsense"
	  do:[:ex| ex sendNotificationsTo: [ :min :max :curr |]]
	] on: ProjectEntryNotification "hide splash morph when entering project"
       do:[:ex| self hideSplashMorph. ex pass].
]

{ #category : #'eToy login' }
ProjectLauncher >> loginAs: userName [
	"Assuming that we have a valid user url; read its contents and see if the user is really there."
	| actualName userList |
	eToyAuthentificationServer ifNil:[
		self proceedWithLogin.
		^true].
	userList := eToyAuthentificationServer eToyUserList.
	userList ifNil:[
		self inform:
'Sorry, I cannot find the user list.
(this may be due to a network problem)
Please hit Cancel if you wish to use Squeak.' translated.
		^false].
	"case insensitive search"
	actualName  := userList detect:[:any| any sameAs: userName] ifNone:[nil].
	actualName isNil ifTrue:[
		self inform: 'Unknown user: ' translated ,userName.
		^false].
	Utilities authorName: actualName.
	eToyAuthentificationServer eToyUserName: actualName.
	self proceedWithLogin.
	^true
]

{ #category : #'eToy login' }
ProjectLauncher >> prepareForLogin [
	"Prepare for login - e.g., hide everything so only the login morph is visible."
	| world |
	world := Project current world.
	world submorphsDo:[:m| 
		m isLocked ifFalse:[m hide]]. "hide all those guys"
	world displayWorldSafely.

]

{ #category : #'eToy login' }
ProjectLauncher >> proceedWithLogin [
	eToyAuthentificationServer := nil.
	Project current world submorphsDo:[:m| m show].
	WorldState addDeferredUIMessage: [self startUpAfterLogin].
]

{ #category : #initialization }
ProjectLauncher >> setupFlaps [
	"Only called when the image has been launched in a browser.  If I am requested to show etoy flaps, then remove any pre-existing shared flaps and put up the supplies flap only.  if I am requested to show all flaps, then if flaps already exist, use them as is, else set up to show the default set of standard flaps."

	((whichFlaps = 'etoy')
		or: [Preferences eToyFriendly])
		ifTrue:
			[Flaps addAndEnableEToyFlaps].
	whichFlaps = 'all'
		ifTrue: [Flaps sharedFlapsAllowed
				ifFalse: [Flaps enableGlobalFlaps]]
]

{ #category : #initialization }
ProjectLauncher >> setupFromParameters [
	(self includesParameter: 'showSplash')
		ifTrue: [showSplash := (self parameterAt: 'showSplash') asUppercase = 'TRUE'].
	(self includesParameter: 'flaps')
		ifTrue: [whichFlaps := (self parameterAt: 'flaps')].

]

{ #category : #private }
ProjectLauncher >> showSplash [
	^showSplash
]

{ #category : #running }
ProjectLauncher >> showSplashMorph [
	| world |
	SplashMorph ifNil:[^self].
	self showSplash
		ifFalse: [^self].
	world := Project current world.
	world submorphs do:[:m| m visible: false]. "hide all"
	world addMorphCentered: SplashMorph.
	world displayWorldSafely.
]

{ #category : #running }
ProjectLauncher >> startUp [

	Preferences eToyLoginEnabled
		ifTrue: [self doEtoyLogin]
		ifFalse:[self startUpAfterLogin].
]

{ #category : #running }
ProjectLauncher >> startUpAfterLogin [
	| scriptName loader isUrl |
	self setupFlaps.
	Preferences readDocumentAtStartup
		ifTrue: [scriptName := Smalltalk documentPath
						ifNil: [''].
			scriptName := scriptName convertFromSystemString.
			scriptName isEmpty
				ifFalse: ["figure out if script name is a URL by itself"
					isUrl := (scriptName asLowercase beginsWith: 'http://')
								or: [(scriptName asLowercase beginsWith: 'file://')
										or: [scriptName asLowercase beginsWith: 'ftp://']].
					isUrl
						ifFalse: [| encodedPath pathTokens |
							"Allow for ../dir/scriptName arguments"
							pathTokens := scriptName splitBy: FileDirectory slash.
							pathTokens := pathTokens
										collect: [:s | s encodeForHTTP].
							encodedPath := pathTokens
										reduce: [:acc :each | acc , FileDirectory slash , each].
							scriptName := (FileDirectory default uri resolveRelativeURI: encodedPath) asString]]]
		ifFalse: [scriptName := ''].
	scriptName isEmptyOrNil
		ifTrue: [^ Preferences eToyFriendly
				ifTrue: [self currentWorld addGlobalFlaps]].
	loader := CodeLoader new.
	loader
		loadSourceFiles: (Array with: scriptName).
	(scriptName asLowercase endsWith: '.pr')
		ifTrue: [self installProjectFrom: loader]
		ifFalse: [loader installSourceFiles]
]
