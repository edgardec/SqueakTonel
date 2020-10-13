"
ServiceAction are executable objects in various contexts.
They can be displayed as buttons or menu items or bounded to keyboard shortcuts.

ServiceActions are defined in methods in an instance of a ServiceProvider class (in the 'services' method category), using the following template:

serviceIdentifierAndMethodName
	^ ServiceAction
		text: 'Menu item text'
		button: 'Button text'
		description: 'Longer text that appears in help balloons'
		action: [:r | ""Code block fetching data from the requestor instance, r, that is passed to the block""]
		
or, alternatively:

serviceIdentifierAndMethodName
	^ ServiceAction
		text: 'Menu item text'
		button: 'Button text'
		description: 'Longer text that appears in help balloons'
		action: [:r | ""Code block fetching data from the requestor instance, r, that is passed to the block""]
		condition: [:r | ""second block returning true if the service can be used at the time being, false otherwise. Data can still be fetched from the requestor instance""]
		
The method name in which the service is defined becomes its identifier. To build the hierarchy of services and to assign them to shortcuts, you will need to type this names in the relevant fields of the Services Browser.
		
Services are arranged in a hierarchy. and bound to keyboard shortcuts using the ServicesBrowser.

"
Class {
	#name : #ServiceAction,
	#superclass : #Object,
	#instVars : [
		'condition',
		'action',
		'requestor',
		'label',
		'shortLabel',
		'description',
		'id',
		'provider',
		'enabled'
	],
	#category : #'Services-Base'
}

{ #category : #'instance creation' }
ServiceAction class >> id: aSymbol text: aStringOrBlock button: buttonString description: aString action: aBlock [
	^ self id: aSymbol 
		text: aStringOrBlock 
		button: buttonString 
		description: aString 
		action: aBlock 
		condition: [:r | true]
]

{ #category : #'instance creation' }
ServiceAction class >> id: aSymbol text: aStringOrBlock button: buttonString description: aString action: aBlock condition: cBlock [
	^ (self new) 
		id: aSymbol;
		text: aStringOrBlock; 
		buttonLabel: buttonString; 
		description: aString; 
		action: aBlock;
		condition: cBlock;
		yourself
]

{ #category : #'class initialization' }
ServiceAction class >> initialize [
	#(
	(inlineServicesInMenu true 'Inline the services the squeak menus') 
	(useOnlyServicesInMenu false 'Use only services and not regular menu items')
	(useServicesInBrowserButtonBar false 'Use a service-based button bar')) 
		do: [:tr |
				Preferences 
						addPreference: tr first
						categories: #(#services)
						default: tr second
						balloonHelp: tr third] 
	
]

{ #category : #'instance creation' }
ServiceAction class >> text: aStringOrBlock button: buttonString description: aString action: aBlock [
	"use when id can be automatically generated"
	^ self id: nil 
		text: aStringOrBlock 
		button: buttonString 
		description: aString 
		action: aBlock 
		condition: [:r | true]
]

{ #category : #'instance creation' }
ServiceAction class >> text: aStringOrBlock button: buttonString description: aString action: aBlock condition: cBlock [
	"use when id can be generated"
	^ self 
		id: nil 
		text: aStringOrBlock 
		button: buttonString 
		description: aString 
		action: aBlock
		condition: cBlock
]

{ #category : #'instance creation' }
ServiceAction class >> text: textString description: aString action: aBlock [
	"use when id can be generated"
	^ self id: nil text: textString button: textString description: aString action: aBlock
]

{ #category : #accessing }
ServiceAction >> action: aBlock [
	action := aBlock
]

{ #category : #preferences }
ServiceAction >> addPreference: name category: cat selector: sel [
	
	ServicePreferences 
		 addPreference: name
		 categories: {cat asSymbol. self providerCategory}
		 default: ''
		 balloonHelp:self description
		 projectLocal:false
		 changeInformee: self id -> sel
		 changeSelector: #serviceUpdate
		type: #String
]

{ #category : #accessing }
ServiceAction >> buttonLabel [
	^ shortLabel
		ifNil: [self text]
		ifNotNil: [shortLabel ifEmpty: [self text] ifNotEmpty: [shortLabel]]
]

{ #category : #accessing }
ServiceAction >> buttonLabel: anObject [
	shortLabel := anObject
]

{ #category : #accessing }
ServiceAction >> categories [
	^ ServiceRegistry current categories select: [:e | e services includes: self]
]

{ #category : #executing }
ServiceAction >> condExecuteWith: aRequestor [
	self requestor: aRequestor.
	self executeCondition 
			ifTrue: [self execute] 
			ifFalse: [Beeper beep]
]

{ #category : #accessing }
ServiceAction >> condition: aBlock [
	condition := aBlock
]

{ #category : #accessing }
ServiceAction >> description [

	^ description ifNil: [self text] ifNotNil: [description]
]

{ #category : #accessing }
ServiceAction >> description: anObject [
	description := anObject select: [:each | (each = Character cr) not] 
						thenCollect: [:each | each = Character tab ifTrue: [Character space]
															ifFalse: [each]].
]

{ #category : #executing }
ServiceAction >> execute [
	^ action valueWithRequestor: Project current world focusedRequestor
]

{ #category : #executing }
ServiceAction >> executeCondition [
	^ [condition valueWithRequestor: Project current world focusedRequestor]
		on: Error
		do: [false]
]

{ #category : #accessing }
ServiceAction >> id [
	^id
]

{ #category : #accessing }
ServiceAction >> id: aSymbol [
	id := aSymbol
]

{ #category : #'initialize-release' }
ServiceAction >> initialize [
	self
		action: [].
	self
		condition: [true].
	self text: 'no op'.
	self requestor: Requestor new.
	self id: #none.
	enabled := true
]

{ #category : #preferences }
ServiceAction >> insertPreferences [
	ServicePreferences
		addPreference: self id
		categories: (Array with: self providerCategory)
		default: true
		balloonHelp: self description
		projectLocal: false
		changeInformee: self id -> #updateEnable
		changeSelector: #serviceUpdate
		type: #Boolean
]

{ #category : #testing }
ServiceAction >> isCategory [
	^ false
]

{ #category : #testing }
ServiceAction >> isEnabled [
	^ enabled
]

{ #category : #accessing }
ServiceAction >> menuLabel [
	| l sh |
	l := self text.
	l size > 50 ifTrue: [l := (l first: 47), '...'].	
	sh := self shortcut.
	sh := (sh isNil or: [sh isEmpty]) ifTrue: [''] ifFalse: [' (', sh, ')'].
	^ l capitalized, sh
]

{ #category : #accessing }
ServiceAction >> menuLabelNumbered: index [ 
	| shorterLabel shortCut serviceNumberString |
	shorterLabel := self text.
	shorterLabel size > 50 ifTrue: [ shorterLabel := (shorterLabel first: 47) , '...' ].
	shortCut := self shortcut.
	shortCut := (shortCut isNil or: [ shortCut isEmpty ])
		ifTrue: [ String empty ]
		ifFalse: [ ' (' , shortCut , ')' ].
	serviceNumberString := index isZero
		ifTrue: [ String empty ]
		ifFalse: [ index asString , '.' ].
	^ serviceNumberString , shorterLabel , shortCut
]

{ #category : #executing }
ServiceAction >> perform: selector orSendTo: otherTarget [
	^ self perform: selector
]

{ #category : #preferences }
ServiceAction >> preferences [
	^ {ServicePreferences preferenceAt: self shortcutPreference} select: [:e | e notNil]
]

{ #category : #printing }
ServiceAction >> printOn: aStream [ 
	super printOn: aStream.
	aStream
		 space ;
		 nextPutAll: id asString
]

{ #category : #accessing }
ServiceAction >> provider [
	^ provider
		ifNil: [nil]
		ifNotNil: [provider new]
]

{ #category : #accessing }
ServiceAction >> provider: p [
	provider := p
]

{ #category : #preferences }
ServiceAction >> providerCategory [
	^ provider name
]

{ #category : #accessing }
ServiceAction >> requestor [
	^requestor
]

{ #category : #accessing }
ServiceAction >> requestor: anObject [
	requestor := anObject
]

{ #category : #preferences }
ServiceAction >> shortcut [
	^ ServicePreferences valueOfPreference: self shortcutPreference
]

{ #category : #preferences }
ServiceAction >> shortcutPreference [ 
		^ ('Shortcut for ', self id, ':') asSymbol
]

{ #category : #accessing }
ServiceAction >> text [
	^label isBlock ifTrue: [label  value: requestor] ifFalse: [label]
]

{ #category : #accessing }
ServiceAction >> text: aString [
	label := aString
]

{ #category : #preferences }
ServiceAction >> updateEnable [
	enabled := ServicePreferences
				valueOfPreference: self id
				ifAbsent: [true]
]

{ #category : #updating }
ServiceAction >> updateShortcut [
	(self systemNavigation allImplementorsOf: #processService:newShortcut:) 
		do: [:ref | | cls |
			cls := ref actualClass.
			cls isMeta ifTrue: [cls soleInstance processService: self newShortcut: self shortcut]].
	ServiceRegistry ifInteractiveDo: [self provider savePreferencesFor: self]
]
