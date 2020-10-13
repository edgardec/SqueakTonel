"
I list all the methods along with their comments in a given class with the methods linked to their definitions.
"
Class {
	#name : #MethodListHelpTopic,
	#superclass : #AbstractHelpTopic,
	#instVars : [
		'theClass'
	],
	#category : #'HelpSystem-Core-Model'
}

{ #category : #'instance creation' }
MethodListHelpTopic class >> forClass: aClass [
	"Create a new method list for a given class or metaclass.
	
		(MethodListHelpTopic forClass: Behavior class) contents edit
	"
	
	^(self new)
		theClass: aClass;
		yourself
]

{ #category : #accessing }
MethodListHelpTopic >> contents [
	^Text new in: [ :sections |
		self theClass selectors sort do: [ :selector |
			sections
				append: (self headingFor: selector inClass: theClass);
				append: Character cr;
				append: ((self theClass commentsAt: selector)
						at: 1
						ifAbsent: [ '-' ]);
				append: Character cr;
				append: Character cr ].
		sections]
]

{ #category : #private }
MethodListHelpTopic >> headingFor: aSelector inClass: aClass [
	| att |
	att := TextLink new classAndMethod: aClass name, '>>', aSelector.
	^(Text fromString: att info) addAttribute: att.
]

{ #category : #accessing }
MethodListHelpTopic >> icon [

	^ HelpIcons iconNamed: #pageIcon
]

{ #category : #accessing }
MethodListHelpTopic >> priority [

	^ -999
]

{ #category : #accessing }
MethodListHelpTopic >> theClass [

	^ theClass
]

{ #category : #accessing }
MethodListHelpTopic >> theClass: aClassOrMetaClass [

	theClass := aClassOrMetaClass.
]

{ #category : #accessing }
MethodListHelpTopic >> title [

	^ self theClass isMeta
		ifTrue: ['Class side']
		ifFalse: ['Instance side']
]
