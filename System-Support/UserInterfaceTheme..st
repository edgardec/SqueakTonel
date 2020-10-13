"
A UserInterfaceTheme is a dictionary of preferred visual properties; colors, borderStyles, borderWidths, fonts, forms, etc. used to color and style the IDE.

Accessing the Theme
To access the proper UserInterfaceTheme instance for an object, send it #userInterfaceTheme.  The default implementation on Object returns an instance of UserInterfaceThemeRequest that provides a lightweight, clean proxy of the actual theme in use by the IDE at the current time. To do anything more sophisticated than basic querying and setting of properties, you must ask the proxy for the actual theme by sending #theme.

Customizing the Theme
We can ask the #userInterfaceTheme for the value of any visual property by name:

	mySystemWindow userInterfaceTheme closeBoxImage

Initially that would answer nil, which causes the legacy code to use whatever default it used so far. To override various visual properties of any kind of object, the #set:for:to: message can be used, for example:

	myUserInterfaceTheme
		set: #closeBoxImage 
		for: SystemWindow
		to: MenuIcons smallCancelIcon

Now the closeBoxImage message will answer the MenuIcons icon instead of nil.

Alternatively, values may be derived based on other values in the theme, as in:

	myUserInterfaceTheme
		set: #color 
		for: FillInTheBlankMorph
		to: { MenuMorph->#color. #twiceDarker }

This makes FillInTheBlankMorph use the same color as a MenuMorph but #twiceDarker, providing a clean way to build coherent sets of colors within a theme. SystemWindow's code can be changed to use the expression above to access elements of the theme.

Upgrading Legacy Code
Following the introduction of this class, various client code all around the system must be modified to access it. This variety of legacy code uses a variety of methods to specify their visual properties:

	1) a hard-coded values.
	2) a values derived from some other value.
	3) providing local storage for a settable value which can be nil.
	4) providing local storage for a settable value which is expected to always have a particular valid value (never nil).

The requirement, for each case, is to let the value be overridden. 

The solution for each of the above should be handled respectively to the above list, as follows:

	1) Check the #userInterfaceTheme, if that property returns nil, use the legacy hard-coded value. (see example: SystemWindow>>#createCloseBox).
	2) Nothing to do -- simply perform the same derivation on the result of (1).
	3) Check the local storage, if present, use it. If nil, then check the #userInterfaceTheme, if it has this property present, use it, else return nil.
	4) Check the #userInterfaceTheme, if the property is not nil, use it, otherwise use the local value.

Tool Support
If a new access to #userInterfaceTheme is added to the code, be sure to add the property and its description to the #themeSettings for that class. See implementors of #themeSettings for examples.
"
Class {
	#name : #UserInterfaceTheme,
	#superclass : #Object,
	#instVars : [
		'properties',
		'name',
		'next',
		'ignoreApply',
		'lastScaleFactor'
	],
	#classVars : [
		'All',
		'Current',
		'Default'
	],
	#category : #'System-Support'
}

{ #category : #tools }
UserInterfaceTheme class >> allThemeProperties [
	"Answer an Array of 3-element Arrays.  Each inner Array holds the information needed to present a theme editor tool; the property name, category, and description."

	"self allThemeProperties"

	^ Array streamContents: [:stream |
		self allThemePropertiesDo: [:cls :prop |
			stream nextPut: {cls}, prop]]
]

{ #category : #tools }
UserInterfaceTheme class >> allThemePropertiesDo: block [
	"Iterate over all classes that provide theme properties."
	
	Smalltalk allClassesDo: [:eachClass |
		(eachClass respondsTo: #themeProperties) ifTrue: [
			eachClass themeProperties do: [:eachProperty |
				block cull: eachClass cull: eachProperty]]].
]

{ #category : #accessing }
UserInterfaceTheme class >> allThemes [

	^ All ifNil: [All := IdentitySet new]
]

{ #category : #tools }
UserInterfaceTheme class >> categories [
	"self categories"
	
	^ Set new in: [:result |
		self allThemePropertiesDo: [:cls :prop | result add: prop second].
		result]
]

{ #category : #'initialize-release' }
UserInterfaceTheme class >> cleanUp: aggressive [

	aggressive ifTrue: [
		All := nil.
		SqueakTheme
			create;
			createDuller.
		SolarizedTheme
			createDark;
			createLight.
		MonokaiTheme createDark.
		CommunityTheme createDark.
		TrimTheme create].
]

{ #category : #'initialize-release' }
UserInterfaceTheme class >> cleanUpAndReset [
	"Rebuild all themes and re-apply the current one by name."
	
	| nameToReset |
	nameToReset := UserInterfaceTheme current name.
	self cleanUp: true.
	(self named: nameToReset) apply.
]

{ #category : #private }
UserInterfaceTheme class >> clientClasses [

	^ IdentitySet new in: [:result |
		self allThemePropertiesDo: [:cls :prop | result add: cls].
		result]
]

{ #category : #private }
UserInterfaceTheme class >> clientClassesToReapply [
	"All client classes plus their unique subclasses."
	
	^ IdentitySet new in: [:result |
		self clientClasses do: [:cc |
			cc withAllSubclassesDo: [:sc |
				result add: sc]].
		result]
]

{ #category : #accessing }
UserInterfaceTheme class >> current [

	^ Current ifNil: [Current := Default]
]

{ #category : #accessing }
UserInterfaceTheme class >> current: aUserInterfaceTheme [
	"Replace the current system theme with aUserInterfaceTheme."

	Current := aUserInterfaceTheme.
	"Notify?"
]

{ #category : #accessing }
UserInterfaceTheme class >> default [
	^ Default ifNil: [Default := self new
		name: 'Autogenerated Default';
		yourself]
]

{ #category : #accessing }
UserInterfaceTheme class >> default: aUserInterfaceTheme [

	Default := aUserInterfaceTheme.
]

{ #category : #'initialize-release' }
UserInterfaceTheme class >> initialize [
	
	self reset.
]

{ #category : #'initialize-release' }
UserInterfaceTheme class >> named: aString [

	^ self allThemes
		detect: [:ea | ea name = aString]
		ifNone: [self new
			name: aString;
			register]
]

{ #category : #tools }
UserInterfaceTheme class >> propertiesForCategory: categoryName [

	^ self allThemeProperties select: [:each | each third = categoryName]
]

{ #category : #tools }
UserInterfaceTheme class >> propertiesForClass: aClass [

	^ self allThemeProperties select: [:each | each first == aClass]
]

{ #category : #'initialize-release' }
UserInterfaceTheme class >> reset [
	self default apply.
]

{ #category : #actions }
UserInterfaceTheme >> apply [
	"Apply this theme to all affected objects. Let classes decide on how to iterate and call their instances."

	ignoreApply == true ifTrue: [^ self].

	UserInterfaceTheme current: self.

	self fixFontsAndScaleAround: [

		self class clientClassesToReapply in: [:cc |
			cc do: [:eachClass | eachClass applyUserInterfaceTheme].
			Cursor wait showWhile: [
				SystemNavigation default allObjectsDo: [:o |
					((cc includes: o class)
						and: [o canApplyUserInterfaceTheme])
							ifTrue: [o applyUserInterfaceTheme]]]].
	]. "fix fonts"
			
	Project current restoreDisplay.
]

{ #category : #actions }
UserInterfaceTheme >> applyAfter: block [

	ignoreApply := true.
	lastScaleFactor := RealEstateAgent scaleFactor.
	^ block ensure: [ignoreApply := false. self apply]
]

{ #category : #actions }
UserInterfaceTheme >> applyTo: someObjects [
	"Apply this theme to the given objects. Useful if you have to re-theme a specific set of objects. Restore the current theme after that."
	
	UserInterfaceTheme current in: [:priorTheme |
		[
			UserInterfaceTheme current: self.

			someObjects
				select: [:ea | ea canApplyUserInterfaceTheme]
				thenDo: [:ea | ea applyUserInterfaceTheme].

			Project current restoreDisplay.
		] ensure: [UserInterfaceTheme current: priorTheme]].
]

{ #category : #private }
UserInterfaceTheme >> atomicUpdate: aBlock [
	"Like our Preferences >> #atomicUpdatePreference"
	[
		| original copy returnValue |
		original := properties.
		copy := properties copy.
		returnValue := aBlock value: copy.
		original == properties ifTrue: [
			properties := copy.
			^ returnValue]
	] repeat
]

{ #category : #building }
UserInterfaceTheme >> clear: propertySymbol [
	
	^ self
		set: propertySymbol
		to: nil
]

{ #category : #building }
UserInterfaceTheme >> clear: propertySymbol for: aClass [
	"No longer override the default visual property specified by propertySymbol for any kinds of aClass.  Use the default."
	^ self
		set: propertySymbol
		for: aClass
		to: nil
]

{ #category : #building }
UserInterfaceTheme >> derive: propertySymbol for: aClassOrSymbol from: anotherClassOrSymbol [

	^ self
		derive: propertySymbol
		for: aClassOrSymbol
		from: anotherClassOrSymbol
		at: propertySymbol

]

{ #category : #building }
UserInterfaceTheme >> derive: propertySymbol for: aClassOrSymbol from: anotherClassOrSymbol at: anotherPropertySymbol [
	"Derive this property from another property."
	
	self
		set: propertySymbol
		for: aClassOrSymbol
		to: (MessageSend
			receiver: self
			selector: #get:for:
			arguments: {anotherPropertySymbol. anotherClassOrSymbol}).
]

{ #category : #building }
UserInterfaceTheme >> derive: propertySymbol for: aClassOrSymbol from: anotherClassOrSymbol at: anotherPropertySymbol do: block [
	
	self
		set: propertySymbol
		for: aClassOrSymbol
		to: (MessageSend
			receiver: self
			selector: #get:for:do:
			arguments: {anotherPropertySymbol. anotherClassOrSymbol. block}).
]

{ #category : #building }
UserInterfaceTheme >> derive: propertySymbol for: aClassOrSymbol from: anotherClassOrSymbol do: block [

	^ self
		derive: propertySymbol
		for: aClassOrSymbol
		from: anotherClassOrSymbol
		at: propertySymbol
		do: block
]

{ #category : #private }
UserInterfaceTheme >> fixFontsAndScaleAround: block [
	"Due to the current situation with fonts and the real-estate manager, this is a small workaround to support theme switching with largely different font sizes."

	lastScaleFactor ifNil: [lastScaleFactor := RealEstateAgent scaleFactor].

	"Due to the current font situation, update TextConstants."
	[	ignoreApply := true.
		(self get: #standardSystemFont) ifNotNil: [:font | Preferences setSystemFontTo: font].
		(self get: #standardFixedFont) ifNotNil: [:font | Preferences setFixedFontTo: font].
		RealEstateAgent applyUserInterfaceTheme. "Reset cached scale factor now. Sigh."
	] ensure: [ignoreApply := false].

	"Apply theme etc."
	block value.

	"Due to the current real-estate manager situation, resize all windows. Works only for Morphic projects."
	(RealEstateAgent scaleFactor - lastScaleFactor) abs > 0.1 ifTrue: [
		Project current isMorphic ifTrue: [
			| scale |
			scale := RealEstateAgent scaleFactor / lastScaleFactor.
			Project current world submorphs
				select: [:ea | ea isSystemWindow]
				thenDo: [:ea |
					ea extent: (ea extent * scale).
					ea layoutChanged.
					ea setFramesForLabelArea]]].

	lastScaleFactor := nil.
]

{ #category : #private }
UserInterfaceTheme >> get: keyObject [ 
	"keyObject is intended to be an Association. We have two lookup strategies: 1) along the superclass chain *of the client*, 2) via a linked theme. Evaluate the result because there can be message sends stored or blocks."
	
	| k |
	properties
		at: keyObject
		ifPresent: [:prop | ^ prop value].
	
	keyObject isVariableBinding "simple key objects"
		ifFalse: [^ self getViaLink: keyObject].
	
	k := keyObject key.
	(self getViaSuperclasses: keyObject)
		ifNotNil: [:prop | ^ prop].
		
	keyObject key: k. "restore"
	^ self getViaLink: keyObject
]

{ #category : #private }
UserInterfaceTheme >> get: propertySymbol for: scope [
	"For convenience. Does support access to non-class keys."
	
	| aClass |
	aClass := (scope isNil or: [scope isBehavior])
		ifTrue: [scope]
		ifFalse: [Smalltalk classNamed: scope].

	aClass ifNotNil: [^ self get: aClass -> propertySymbol].
		
	properties
		at: scope -> propertySymbol
		ifPresent: [:prop | ^ prop value].
		
	^ self getViaLink: scope -> propertySymbol
]

{ #category : #private }
UserInterfaceTheme >> get: propertySymbol for: scope do: block [

	^ block cull: (self get: propertySymbol for: scope)
]

{ #category : #private }
UserInterfaceTheme >> getViaLink: keyObject [ 
	"keyObject is intended to be an Association.
	If there is a linked theme, see if it has the relevant property available"
	
	^ next ifNotNil: [next get: keyObject]
]

{ #category : #private }
UserInterfaceTheme >> getViaSuperclasses: keyObject [ 
	"keyObject is intended to be an Association.
	Find the superclass of the key of the keyObject (which will initially be the client's class) and make a new keyObject using that and the original message name, then try searching for that."
		
	"We know we're the only referencer of keyObject.  Update it rather than create new ones, for performance reasons."
	keyObject key: keyObject key superclass.

	keyObject key ifNil: [^ nil].
	
	properties
		at: keyObject
		ifPresent: [:prop | ^ prop value].
	
	^ self getViaSuperclasses: keyObject
]

{ #category : #initialization }
UserInterfaceTheme >> initialize [
	super initialize.
	name := 'unnamed'.
	properties := Dictionary new.
]

{ #category : #building }
UserInterfaceTheme >> link: aUserInterfaceTheme [
	"When accessing properties by name, if a property is not specified in the receiver, give aUserInterfaceTheme a chance to provide it."
	next := aUserInterfaceTheme
]

{ #category : #building }
UserInterfaceTheme >> merge: aUserInterfaceTheme [ 
	"Merge aUserInterfaceTheme into my properties.  Same as #link:, except merges all the properties of aUserInterfaceTheme into the  receiver"
	self
		merge: aUserInterfaceTheme
		overwrite: false
]

{ #category : #building }
UserInterfaceTheme >> merge: aUserInterfaceTheme overwrite: aBoolean [ 
	"Merge aUserInterfaceTheme into my properties. Only overwrite properties if it sais so."
	
	self
		 validateCanMerge: aUserInterfaceTheme ;
		 preMerge: aUserInterfaceTheme.

	self atomicUpdate: [:props |
		aUserInterfaceTheme properties keysAndValuesDo: [:key :value |
			(aBoolean or: [(props includesKey: key) not])
				ifTrue: [ | mergedValue |
					mergedValue := value copy.
					"Update receiver when deriving properties."
					mergedValue isMessageSend ifTrue: [mergedValue receiver: self].
					props at: key put: mergedValue.
					]]].
]

{ #category : #accessing }
UserInterfaceTheme >> name [
	^ name
]

{ #category : #accessing }
UserInterfaceTheme >> name: aString [ 
	name := aString
]

{ #category : #accessing }
UserInterfaceTheme >> next [
	"The next theme to look for properties when I don't contain a particular property."
	^ next
]

{ #category : #copying }
UserInterfaceTheme >> postCopy [
	"Keep same name and linked next."
	super postCopy.
	properties := properties copy.
]

{ #category : #private }
UserInterfaceTheme >> preMerge: aUserInterfaceTheme [ 
	name := name , ' + ' , aUserInterfaceTheme name.
	next ifNil: [ next := aUserInterfaceTheme next ]
]

{ #category : #printing }
UserInterfaceTheme >> printOn: aStream [
	super printOn: aStream.
	aStream space; print: name
]

{ #category : #private }
UserInterfaceTheme >> properties [
	^ properties
]

{ #category : #initialization }
UserInterfaceTheme >> register [
	self class allThemes add: self.
]

{ #category : #building }
UserInterfaceTheme >> set: propertySymbol for: aClassOrSymbol to: valueObject [
	"Where aClass asks its userInterfaceTheme for propertySymbol, provide valueObject."
	
	| aClass |
	aClass := aClassOrSymbol isBehavior ifTrue: [aClassOrSymbol] ifFalse: [Smalltalk classNamed: aClassOrSymbol].
	aClass ifNil: [^ self].
	^ self atomicUpdate:
		[ : props | | key |
		key := aClass -> propertySymbol.
		valueObject
			ifNil:
				[ props
					removeKey: key
					ifAbsent: [ "already cleared, don't error" ] ]
			ifNotNil:
				[ props
					at: key
					put: valueObject ] ]
]

{ #category : #building }
UserInterfaceTheme >> set: propertySymbol to: valueObject [
	"For convenience."
	
	^ self atomicUpdate:
		[ : props |
		valueObject
			ifNil:
				[ props
					removeKey: propertySymbol
					ifAbsent: [ "already cleared, don't error" ] ]
			ifNotNil:
				[ props
					at: propertySymbol
					put: valueObject ] ]
]

{ #category : #initialization }
UserInterfaceTheme >> unregister [
	self class allThemes remove: self ifAbsent: [].
]

{ #category : #accessing }
UserInterfaceTheme >> unsetProperties [
	"Answer the property keys which are unset."
]

{ #category : #private }
UserInterfaceTheme >> validateCanMerge: aUserInterfaceTheme [ 
	(next notNil and:
		[ aUserInterfaceTheme next notNil and: [ next ~= aUserInterfaceTheme next ] ]) ifTrue: [ self error: 'Links to different themes.  Cannot merge.' ]
]
