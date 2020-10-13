Class {
	#name : #PBClassPreferenceView,
	#superclass : #PBTextPreferenceView,
	#instVars : [
		'styler',
		'completionController'
	],
	#category : #PreferenceBrowser
}

{ #category : #'as yet unclassified' }
PBClassPreferenceView class >> initialize [
	PreferenceViewRegistry ofClassPreferences register: self.
]

{ #category : #'as yet unclassified' }
PBClassPreferenceView class >> unload [
	"Unload order is not guaranteed so guard against failure"
	[PreferenceViewRegistry ofClassPreferences unregister: self] on: Error do:[]
]

{ #category : #styling }
PBClassPreferenceView >> aboutToStyle: styler [
	"For Shout styling support."
	^ true
]

{ #category : #styling }
PBClassPreferenceView >> aboutToStyle: styler requestor: object [
	"For Shout styling support."
	^ true
]

{ #category : #'auto completion' }
PBClassPreferenceView >> completionController [
	"For OCompletion support."
	^ completionController
]

{ #category : #'initialize-release' }
PBClassPreferenceView >> initialize [
	super initialize.
	styler := (Smalltalk classNamed: 'SHTextStylerST80') ifNotNil: [:s | s new].
	completionController := (Smalltalk classNamed: 'OController') ifNotNil: [:oc | oc model: self].
]

{ #category : #'user interface' }
PBClassPreferenceView >> preferenceValue [
	^self preference preferenceValue ifNil: [''] ifNotNil: [:cls | cls name]
]

{ #category : #'user interface' }
PBClassPreferenceView >> preferenceValue: aClassName [

	| newClass |
	newClass := Smalltalk classNamed: aClassName asString withBlanksTrimmed.
	
	"Avoid overwriting the previous setting by mistake unless explicitely stated so."
	(newClass notNil or: [aClassName = 'nil'])
		ifTrue: [self preference preferenceValue: newClass].
	
	^ true
]

{ #category : #'auto completion' }
PBClassPreferenceView >> selectedClassOrMetaClass [
	"For OCompletion support."
	^ nil
]

{ #category : #'user interface' }
PBClassPreferenceView >> textField [

	| field |
	field := PluggableTextMorphPlus
		on: self
		text: #preferenceValue
		accept: #preferenceValue:.
	field
		borderStyle: BorderStyle inset;
		borderWidth: 1;
		hideScrollBarsIndefinitely;
		acceptOnCR: true;
		wrapFlag: false;
		minimumHeight: 0;
		vResizing: #rigid;
		hResizing: #spaceFill;
		height: TextStyle defaultFont height + 6.
	
	styler ifNotNil: [:s | field styler: (s view: field)].
	
	^ field
]
