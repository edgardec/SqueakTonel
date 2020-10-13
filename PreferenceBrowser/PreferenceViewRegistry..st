"
PreferenceViewRegistry is much like the AppRegistry classes.  Its purpose is to allow PreferenceBrowser implementers to register its own views for each kind of preference.
"
Class {
	#name : #PreferenceViewRegistry,
	#superclass : #Object,
	#instVars : [
		'registeredClasses',
		'viewOrder'
	],
	#classInstVars : [
		'registries'
	],
	#category : #PreferenceBrowser
}

{ #category : #accessing }
PreferenceViewRegistry class >> forType: typeName [
	"Answer the preference registry for the given type name"
	^typeName caseOf:{
		[#Boolean]	->	[self ofBooleanPreferences].
		[#Color]	->	[self ofColorPreferences].
		[#Font]		->	[self ofFontPreferences].
		[#Number]	->	[self ofNumericPreferences].
		[#String]	->	[self ofTextPreferences].
		[#Class]	->	[self ofClassPreferences].
		[#Halo]		->	[self ofHaloThemePreferences].
		[#WindowColor]	-> [self registryOf: #windowColorPreferences]
	} otherwise:[self registryOf: typeName].
]

{ #category : #'class initialization' }
PreferenceViewRegistry class >> initialize [
	"Ensure we aren't carrying obsolete references"
	self removeObsolete.
]

{ #category : #'instance creation' }
PreferenceViewRegistry class >> ofBooleanPreferences [
	^(self registryOf: #booleanPreferences)
		viewOrder: 1; 
		yourself.
]

{ #category : #'instance creation' }
PreferenceViewRegistry class >> ofClassPreferences [
	^(self registryOf: #classPreferences)
		viewOrder: 3;
		yourself.
]

{ #category : #'instance creation' }
PreferenceViewRegistry class >> ofColorPreferences [
	^(self registryOf: #colorPreferences)
		viewOrder: 5;
		yourself.
]

{ #category : #'instance creation' }
PreferenceViewRegistry class >> ofFontPreferences [
	^(self registryOf: #fontPreferences)
		viewOrder: 4;
		yourself.
]

{ #category : #'instance creation' }
PreferenceViewRegistry class >> ofHaloThemePreferences [
	^(self registryOf: #haloThemePreferences)
		viewOrder: 2;
		yourself.
]

{ #category : #'instance creation' }
PreferenceViewRegistry class >> ofNumericPreferences [
	^(self registryOf: #numericPreferences)
		viewOrder: 3;
		yourself.
]

{ #category : #'instance creation' }
PreferenceViewRegistry class >> ofTextPreferences [
	^(self registryOf: #textPreferences)
		viewOrder: 3;
		yourself.
]

{ #category : #'instance creation' }
PreferenceViewRegistry class >> registries [
	^registries ifNil: [registries := Dictionary new]
]

{ #category : #'instance creation' }
PreferenceViewRegistry class >> registryOf: aSymbol [
	^self registries at: aSymbol ifAbsentPut: [self new]
]

{ #category : #'class initialization' }
PreferenceViewRegistry class >> removeObsolete [
	"PreferenceViewRegistry removeObsolete"
	"Remove obsolete entries from the registries"
	self registries do:[:viewRegistry|
		viewRegistry registeredClasses copy do:[:rClass|
			rClass isObsolete ifTrue:[viewRegistry unregister: rClass]]].
]

{ #category : #accessing }
PreferenceViewRegistry class >> typeOfRegistry: aRegistry [
	"Answer the type name for a particular view registry"
	^aRegistry caseOf:{
		[self ofBooleanPreferences]	-> [#Boolean].
		[self ofColorPreferences]		-> [#Color].
		[self ofFontPreferences]		-> [#Font].
		[self ofNumericPreferences]	-> [#Number].
		[self ofTextPreferences]		-> [#String].
		[self ofClassPreferences]	-> [#Class].
		[self ofHaloThemePreferences]	-> [#Halo].
		[self registryOf: #windowColorPreferences]	-> [#WindowColor].
	} otherwise:[self registries keyAtIdentityValue: aRegistry ifAbsent:[nil]].
]

{ #category : #'initialize-release' }
PreferenceViewRegistry >> initialize [
	viewOrder := 1.
]

{ #category : #'view registry' }
PreferenceViewRegistry >> register: aProviderClass [
	(self registeredClasses includes: aProviderClass) 
		ifFalse: [self registeredClasses add: aProviderClass].
]

{ #category : #'view registry' }
PreferenceViewRegistry >> registeredClasses [
	^registeredClasses ifNil: [registeredClasses := OrderedCollection new]
]

{ #category : #'view registry' }
PreferenceViewRegistry >> unregister: aProviderClass [
	self registeredClasses remove: aProviderClass ifAbsent: []
]

{ #category : #'view registry' }
PreferenceViewRegistry >> viewClassFor: aPreferencePanel [
	^self registeredClasses 
		detect: [:aViewClass| aViewClass handlesPanel: aPreferencePanel]
		ifNone: [].
]

{ #category : #'view order' }
PreferenceViewRegistry >> viewOrder [
	"answer the order in which the registered views should appear relative to the other views"
	^viewOrder
]

{ #category : #'view order' }
PreferenceViewRegistry >> viewOrder: aNumber [
	viewOrder := aNumber
]
