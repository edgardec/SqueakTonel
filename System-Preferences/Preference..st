"
Represents a true/false flag that is under user control and which can be interrogated by a call to Preferences
	viewRegistry		the registry of the classes responsible for building my view
	name 				a symbol, the formal name of the preference.
	value				a boolean, the current value
	defaultValue		the default value of the preference
	helpString 			string or text, constituting the help message
	localToProject		boolean, whether each project holds its own version
	categoryList			list of categories under which to offer this
	changeInformee 	whom, if anyone, to inform if the value changes:
	changeSelector 		what selector to send to the changeInformee when the value changes
"
Class {
	#name : #Preference,
	#superclass : #Object,
	#instVars : [
		'name',
		'value',
		'defaultValue',
		'helpString',
		'localToProject',
		'categoryList',
		'changeInformee',
		'changeSelector',
		'type'
	],
	#category : #'System-Preferences'
}

{ #category : #'browsing support' }
Preference class >> isChangeSelector: aLiteral [
	^Preferences isChangeSelector: aLiteral
]

{ #category : #converting }
Preference >> asPreference [
	^self
]

{ #category : #menu }
Preference >> categoryList [
	"Answer the categoryList"

	^ categoryList
]

{ #category : #initialization }
Preference >> categoryList: aList [
	"Set the receiver's categoryList"

	categoryList := aList
]

{ #category : #'change notification' }
Preference >> changeInformee: informee changeSelector: aSelector [
	"Set the changeInformee and changeSelector as specified"

	changeInformee := informee.
	changeSelector := aSelector
]

{ #category : #accessing }
Preference >> changeSelector [
	^changeSelector
]

{ #category : #menu }
Preference >> codeString [
	"Answer the Smalltalk expressions to get the preference value."

	^ 'Preferences valueOfFlag: #', self name
]

{ #category : #menu }
Preference >> copyCode [
	"Copy the code for the given preference to the clipboard"

	Clipboard clipboardText: self codeString.
]

{ #category : #menu }
Preference >> copyName [
	"Copy the name of the given preference to the clipboard"

	Clipboard clipboardText: name asString asText
]

{ #category : #value }
Preference >> defaultValue [
	"Answer this preference's defaultValue"

	^ defaultValue
]

{ #category : #value }
Preference >> defaultValue: aValue [
	"Set the receiver's defaultValue"

	defaultValue := aValue.
]

{ #category : #menu }
Preference >> helpString [
	"Answer the help string provided for the receiver"

	^ helpString ifNil: ['no help available' translatedNoop]
]

{ #category : #accessing }
Preference >> id [

	^ self name asSymbol
]

{ #category : #testing }
Preference >> isDeprecated [
	
	^ self isObsolete
]

{ #category : #testing }
Preference >> isObsolete [
	^(changeInformee class isObsolete or:[changeInformee isBehavior and:[changeInformee isObsolete]])
]

{ #category : #testing }
Preference >> isPragmaPreference [

	^ false
]

{ #category : #'local to project' }
Preference >> isProjectLocalString [
	"Answer a string representing whether sym is a project-local preference or not"

	| aStr |
	aStr :=  'each project has its own setting'.
	^ self localToProject
		ifTrue:
			['<yes>', aStr]
		ifFalse:
			['<no>', aStr]
]

{ #category : #'local to project' }
Preference >> localToProject [
	"Answer whether this preference is project-local"

	^ localToProject
]

{ #category : #menu }
Preference >> name [
	"Answer this preference's name"

	^ name
]

{ #category : #initialization }
Preference >> name: aName defaultValue: aValue helpString: aString localToProject: projectBoolean categoryList: aList changeInformee: informee changeSelector:  aChangeSelector type: aType [
	"Initialize the preference from the given values.  There is an extra tolerence here for the symbols #true, #false, and #nil, which are interpreted, when appropriate, as meaning true, false, and nil"

	name := aName asSymbol.
	value := defaultValue := aValue
								caseOf: {
									[#true] -> [true].
									[#false] -> [false] }
								otherwise:
									[aValue].
	helpString := aString.
	localToProject := projectBoolean == true or: [projectBoolean = #true].
	type := aType.
	categoryList := aList
						ifNil: [OrderedCollection with: #unclassified]
						ifNotNil: [aList collect: [:elem | elem asSymbol]].

	changeInformee := (informee == nil or: [informee == #nil]) ifFalse:
							[(informee isSymbol)
								ifTrue: [Smalltalk at: informee]
								ifFalse: [informee]].
	changeSelector  := aChangeSelector
]

{ #category : #'change notification' }
Preference >> notifyInformeeOfChange [
	"If there is a changeInformee, notify her that I have changed value"
	
	<hasLiteralTest: #isChangeSelector:>
	"To find this method as sender of all changeSelectors"

	changeInformee ifNotNil: [changeInformee perform: changeSelector]
]

{ #category : #value }
Preference >> preferenceValue [
	"Answer the current value of the preference"

	^ value
]

{ #category : #value }
Preference >> preferenceValue: aValue [
	"set the value as indicated, and invoke the change selector if appropriate"

	| oldValue |
	oldValue := value.
	value := aValue.
	oldValue ~~ value ifTrue:
		[self notifyInformeeOfChange]
]

{ #category : #debugging }
Preference >> printOn: aStream [
	"Print a string decribing the receiver to the given stream"

	super printOn: aStream.
	aStream nextPutAll: name storeString, ' ', value storeString
]

{ #category : #value }
Preference >> provider [
	"Compatibility with pragma preferences"
	^nil
]

{ #category : #value }
Preference >> rawValue: aValue [
	"set the value as indicated, with no side effects"

	value := aValue
]

{ #category : #menu }
Preference >> readableName [
	"Split camel-case preferences into a readable string with spaces."
	
	| result |
	result := (self name includes: Character space)
		ifTrue: [self name asString copy]
		ifFalse: [self name findFeatures joinSeparatedBy: ' '].
	
	"Ensure first letter is uppercase"
	result at: 1 put: (result at: 1) asUppercase.
	
	^ result
]

{ #category : #value }
Preference >> restoreDefaultValue [
	"restore the default value to the preference"

	value := defaultValue
]

{ #category : #value }
Preference >> togglePreferenceValue [
	"Toggle whether the value of the preference. Self must be a boolean preference."
	value := value not.
	self notifyInformeeOfChange
]

{ #category : #'local to project' }
Preference >> toggleProjectLocalness [
	"Toggle whether the preference should be held project-by-project or globally"

	localToProject := localToProject not.
]

{ #category : #accessing }
Preference >> type [
	"The type of this preference. One of #Boolean, #Color, #String, #Font, #Number etc."
	^type
]

{ #category : #accessing }
Preference >> type: preferenceType [
	"The type of this preference. One of #Boolean, #Color, #String, #Font, #Number etc."
	type := preferenceType
]
