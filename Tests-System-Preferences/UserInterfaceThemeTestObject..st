Class {
	#name : #UserInterfaceThemeTestObject,
	#superclass : #Object,
	#instVars : [
		'testColor',
		'unknownProperty'
	],
	#classVars : [
		'ApplyCounter'
	],
	#category : #'Tests-System-Preferences'
}

{ #category : #'as yet unclassified' }
UserInterfaceThemeTestObject class >> applyCounter [
	^ ApplyCounter
]

{ #category : #'as yet unclassified' }
UserInterfaceThemeTestObject class >> applyUserInterfaceTheme [
	ApplyCounter := (ApplyCounter ifNil: [0]) + 1.
]

{ #category : #benchmark }
UserInterfaceThemeTestObject class >> benchLookup [
	"
	Microsoft Surface Pro 3, Windows 10 v1703, CogVM 201708092224, Squeak 6.0alpha #17398
	  Up to  '280,000 per second. 3.57 microseconds per run.' -- leaves enough room for quirky morphs that keep on drawing themselves based on direct theme lookup.
	
	I think this setup is really heavy. Morphs should not look-up things that often. They can cache. Anyway:
	- link through 3 themes
	- look up superclasses up to ProtoObject (for each theme!)
	
	self benchLookup"
	
	| c t1 t2 t3 m result |
	c := UserInterfaceTheme current.
	m := UserInterfaceThemeTestObject new.
	t1 := UserInterfaceTheme new name: #benchmarkOne.
	t2 := UserInterfaceTheme new name: #benchmarkTwo.
	t3 := UserInterfaceTheme new name: #benchmarkThree.
	
	t3 set: #testColor for: ProtoObject to: Color white.
	t1 link: t2.
	t2 link: t3.
	
	t1 apply.
	
	result := OrderedCollection new.
	
	[
		3 timesRepeat: [
			Smalltalk garbageCollect.
			result add: [m getTestColor] bench].
	] ensure: [c apply].

	result explore.
]

{ #category : #'as yet unclassified' }
UserInterfaceThemeTestObject class >> resetApplyCounter [
	ApplyCounter := 0.
]

{ #category : #preferences }
UserInterfaceThemeTestObject class >> themeProperties [

	^ super themeProperties, {
		{#testColor. 'test'. 'Some test property'}
	}
]

{ #category : #updating }
UserInterfaceThemeTestObject >> applyUserInterfaceTheme [

	self testColor: self userInterfaceTheme testColor.
	self unknownProperty: self userInterfaceTheme unknownProperty.
]

{ #category : #'visual properties' }
UserInterfaceThemeTestObject >> canApplyUserInterfaceTheme [
	^ true
]

{ #category : #updating }
UserInterfaceThemeTestObject >> getTestColor [

	^ self userInterfaceTheme testColor
]

{ #category : #updating }
UserInterfaceThemeTestObject >> getTestColorViaPerform [

	^ self userInterfaceTheme perform: #testColor
]

{ #category : #accessing }
UserInterfaceThemeTestObject >> testColor [

	^ testColor
]

{ #category : #accessing }
UserInterfaceThemeTestObject >> testColor: anObject [

	testColor := anObject
]

{ #category : #accessing }
UserInterfaceThemeTestObject >> unknownProperty [

	^ unknownProperty
]

{ #category : #accessing }
UserInterfaceThemeTestObject >> unknownProperty: anObject [

	unknownProperty := anObject
]
