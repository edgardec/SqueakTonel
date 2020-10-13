"
Differs from superclass by redirecting all queries to a preference provider that defines its preference via a class-side preference method marked with a pragma.  For example, evaluate
	self systemNavigation browseAllCallsOn: #preference:categoryList:description:type:

Each preference method getter can be accompanied by a setter that assigns to the preference whose value the getter answers.  If the getter is of the form
	^SomeGlobalOrClassVar ifNil: [...]
then the framework is smart enough to figure out the SomeGlobalOrClassVar from the getter and no setter method is required.
"
Class {
	#name : #PragmaPreference,
	#superclass : #Preference,
	#instVars : [
		'provider',
		'getter',
		'setter'
	],
	#category : #'System-Preferences'
}

{ #category : #converting }
PragmaPreference >> asPreference [
	| preference |
	preference := Preference new.
	preference
		name: name
		defaultValue: defaultValue
		helpString: helpString
		localToProject: self localToProject
		categoryList: categoryList
		changeInformee: changeInformee
		changeSelector:  changeSelector
		type: type.
	preference rawValue: self preferenceValue.
	^preference
]

{ #category : #value }
PragmaPreference >> attemptToSetValueFromGetter: aValue [
	"Attempt to set the value of the preference from the getter method, answering if the attempt was successful.
	 Do so by seeing if the method is of the form
		^ClassVar ifNil: [...]
	 by analysing its bytecode, and if so, extracting the class (or global) var and setting its value."
	| getterMethod getterBytecodes getterBytecodeNames
	  constant comparison branchTuple distance followingpc
	  classVar |
	getterMethod := provider class compiledMethodAt: getter ifAbsent: [^false].
	getterBytecodes := getterMethod abstractBytecodeMessagesAndPCs.
	getterBytecodeNames := getterBytecodes collect: [:tuple| tuple first selector].
	((getterBytecodeNames beginsWith: #(pushLiteralVariable: doDup #pushConstant: send:super:numArgs: jump:if:))
	 and: [getterBytecodeNames last == #methodReturnTop
	 and: [(constant := getterBytecodes third first) arguments first == nil
	 and: [(comparison := getterBytecodes fourth first) arguments first == #==
	 and: [branchTuple := getterBytecodes fifth.
			followingpc := getterBytecodes sixth last.
			distance := branchTuple first arguments first.
			"i.e. does the branch jump to the return?"
			distance + followingpc = getterBytecodes last second]]]]) ifFalse:
		[^false].
	classVar := getterBytecodes first first arguments first.
	classVar value: aValue.
	^true
]

{ #category : #menu }
PragmaPreference >> codeString [
	"Answer the Smalltalk expressions to get the preference value."

	^ self provider name, ' ', getter
]

{ #category : #accessing }
PragmaPreference >> id [

	^ (self provider name, '>>', getter) asSymbol
]

{ #category : #testing }
PragmaPreference >> isDeprecated [

	^ self isObsolete or: [(provider class lookupSelector: getter) isDeprecated
		or: [(provider class lookupSelector: setter) isDeprecated]]
]

{ #category : #testing }
PragmaPreference >> isObsolete [

	^ ((super isObsolete or: [provider isObsolete]) or: [(provider respondsTo: getter) not]) or: [(provider respondsTo: setter) not]
]

{ #category : #testing }
PragmaPreference >> isPragmaPreference [

	^ true
]

{ #category : #accessing }
PragmaPreference >> localToProject [
	"Pragma preferences are stored and accessed outside the scope of the preference mechanism. Hence, they cannot be project-local."
	
	^ false
]

{ #category : #value }
PragmaPreference >> preferenceValue [
	"Answer the current value of the preference"
	^provider perform: getter
]

{ #category : #value }
PragmaPreference >> preferenceValue: aValue [
	"set the value as indicated, and invoke the change selector if appropriate"
	self preferenceValue = aValue ifFalse:[
		self rawValue: aValue.
		self notifyInformeeOfChange].
]

{ #category : #printing }
PragmaPreference >> printOn: aStream [
	"Print a string decribing the receiver to the given stream"

	super printOn: aStream.
	aStream nextPutAll: name storeString, ' ', self value storeString
]

{ #category : #accessing }
PragmaPreference >> provider [

	^provider
]

{ #category : #initialization }
PragmaPreference >> provider: aClass getter: getterSymbol setter: setterSymbol [
	provider := aClass.
	getter := getterSymbol.
	setter := setterSymbol.

]

{ #category : #value }
PragmaPreference >> rawValue: aValue [
	"set the value as indicated, with no side effects"
	[provider perform: setter with: aValue]
		on: MessageNotUnderstood
		do: [:ex|
			(self attemptToSetValueFromGetter: aValue) ifFalse:
				[ex pass]]
]

{ #category : #initialization }
PragmaPreference >> restoreDefaultValue [
	"Pragma preferences preserve their current value"
]

{ #category : #value }
PragmaPreference >> togglePreferenceValue [
	"Toggle whether the value of the preference. Self must be a boolean preference."
	self preferenceValue: self preferenceValue not.
	self notifyInformeeOfChange
]
