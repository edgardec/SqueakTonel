Class {
	#name : #PreferencesTest,
	#superclass : #TestCase,
	#instVars : [
		'sut'
	],
	#category : #'Tests-System-Preferences'
}

{ #category : #running }
PreferencesTest >> setUp [

	super setUp.
	sut := PreferencesTestPreferences.
]

{ #category : #running }
PreferencesTest >> tearDown [

	sut allPreferences do: [:pref | sut removePreference: pref id].
	sut class organization removeEmptyCategories.
	
	super tearDown.
]

{ #category : #tests }
PreferencesTest >> test01Empty [

	self assert: sut dictionaryOfPreferences isEmpty.
]

{ #category : #tests }
PreferencesTest >> test02AddSetRemovePreference [

	self assert: (sut valueOfPreference: #foo ifAbsent: []) isNil.
	self assert: (sut respondsTo: #foo) not. "auto-generated accessor"

	sut addPreference: #foo category: #bar default: false.
	self assert: (sut valueOfPreference: #foo ifAbsent: []) = false.
	self assert: (sut perform: #foo) = false.

	sut setPreference: #foo toValue: true.
	self assert: (sut valueOfPreference: #foo ifAbsent: []) = true.
	self assert: (sut perform: #foo) = true.

	sut removePreference: #foo.
	self assert: (sut valueOfPreference: #foo ifAbsent: []) isNil.
	self assert: (sut respondsTo: #foo) not.
]

{ #category : #tests }
PreferencesTest >> test03Type [

	sut addPreference: #foo default: true.
	self assert: (sut preferenceAt: #foo) type == #Boolean.

	sut addPreference: #foo default: 123.
	self assert: (sut preferenceAt: #foo) type == #Number.

	sut addPreference: #foo default: 'Hello, World'.
	self assert: (sut preferenceAt: #foo) type == #String.

	sut addPreference: #foo default: Color red.
	self assert: (sut preferenceAt: #foo) type == #Color.

	sut addPreference: #foo default: 1@5.
	self assert: (sut preferenceAt: #foo) type == #Object.

]

{ #category : #tests }
PreferencesTest >> test04TypeNoUpdate [

	sut addPreference: #foo default: true.
	sut setPreference: #foo toValue: 123.

	self assert: (sut preferenceAt: #foo) type == #Boolean.
]

{ #category : #tests }
PreferencesTest >> test05AutoAdd [

	| pref |
	self assert: (sut valueOfPreference: #foo ifAbsent: []) isNil.
	pref := sut setPreference: #foo toValue: 123.

	self assert: pref preferenceValue = 123.
]

{ #category : #tests }
PreferencesTest >> test06Flags [
	"Flags are boolean preferences."
	
	self assert: (sut valueOfFlag: #isHappy) == false. "Not known but false for default."
	
	sut setFlag: #isHappy toValue: true.
	self assert: (sut valueOfFlag: #isHappy) == true.
	self assert: (sut perform: #isHappy) == true.
	
	sut disable: #useIt.
	self assert: (sut valueOfFlag: #useIt) == false.
	self assert: (sut perform: #useIt) == false.
	
	sut enable: #useIt.
	self assert: (sut valueOfFlag: #useIt) == true.
	self assert: (sut perform: #useIt) == true.
	
	sut toggle: #useIt.
	self assert: (sut valueOfFlag: #useIt) == false.	
]

{ #category : #tests }
PreferencesTest >> test07UnknownPreference [

	self assert: (sut valueOfPreference: #notKnown) isNil.
	self assert: (sut valueOfPreference: #notKnown ifAbsent: [#default]) = #default.
]

{ #category : #tests }
PreferencesTest >> test08DNUFallback [

	sut setPreference: #foo toValue: 123.
	sut class removeSelectorSilently: #foo.

	self assert: (sut perform: #foo) = 123.
	self should: [sut perform: #'_unlikelyAndUnknownSelector'] raise: MessageNotUnderstood.
]

{ #category : #tests }
PreferencesTest >> test09AddSetRemovePragmaPreference [

	| id pref |
	id := PreferencesTestExample name, '>>', #textPref.
	pref := sut addPragmaPreference: (PreferencesTestExample class >> #textPref) pragmas first.

	self assert: id equals: pref id.
	self assert: (sut preferenceAt: pref id) == pref.

	"Reset the preference explicitely."
	PreferencesTestExample textPref: ''.
	self assert: '' equals: PreferencesTestExample textPref.	
	
	sut setPreference: pref id toValue: 'foo'.
	self assert: 'foo' equals: (sut valueOfPreference: pref id).
	self assert: 'foo' equals: PreferencesTestExample textPref.
	
	sut removePreference: pref id.
	self assert: (sut preferenceAt: pref id ifAbsent: []) isNil.
]

{ #category : #tests }
PreferencesTest >> test10Unclassified [

	| pref |
	pref := sut addPreference: #foobar default: 123.
	self assert: sut unclassifiedCategory equals: pref categoryList first.
]

{ #category : #tests }
PreferencesTest >> test11CategoryList [

	sut addPreference: #foo category: #blubb default: 123.
	self assert: #(blubb) equals: (sut categoryListOfPreference: #foo). 
]

{ #category : #tests }
PreferencesTest >> test12HardCodedPreference [

	self assert: (sut respondsTo: #someStaticFoo) not.
	sut compileAccessorForPreferenceNamed: #someStaticFoo value: 42.
	self assert: 42 equals: (sut perform: #someStaticFoo).
	self assert: (sut valueOfPreference: #someStaticFoo ifAbsent: []) isNil.

	"Hard-coded preferences have their value only in the source code. We must leave them in the same package."
	self deny: ((sut class organization categoryOfElement: #someStaticFoo) beginsWith: '*').

	sut class removeSelectorSilently: #someStaticFoo.
]
