"
A ClassListBrowser displays the code for an arbitrary list of classes.

ClassListBrowser example1.  ""all classes that have the string 'Pluggable' in their names""
ClassListBrowser example2.  ""all classes whose names start with the letter S""
ClassListBrowser example3.  ""all variable classes""
ClassListBrowser example4.  ""all classes with more than 100 methods""
ClassListBrowser example5.  ""all classes that lack class comments""
ClassListBrowser example6.  ""all classes that have class instance variables""

ClassListBrowser newOnClassesNamed: #(Browser Boolean) label: 'Browser and Boolean!'.
ClassListBrowser newOnAllClasses ""all classes listed alphabetically""

"
Class {
	#name : #ClassListBrowser,
	#superclass : #HierarchyBrowser,
	#instVars : [
		'defaultTitle'
	],
	#category : #'Tools-Browser'
}

{ #category : #'instance creation' }
ClassListBrowser class >> browseClassesSatisfying: classBlock title: aTitle [
	"Put up a ClassListBrowser showing all classes that satisfy the classBlock."

	self newOnClassesNamed:
			(self systemNavigation allClasses select: [:c | (classBlock value: c) == true]
				thenCollect: [:c | c name])
		label: aTitle
]

{ #category : #examples }
ClassListBrowser class >> example1 [
	"Put up a ClassListBrowser that shows all classes that have the string 'Pluggable' in their names"

	self browseClassesSatisfying: [:cl | cl name includesSubstring: 'Pluggable'] title: 'Pluggables'

"ClassListBrowser example1"
	
]

{ #category : #examples }
ClassListBrowser class >> example2 [
	"Put up a ClassListBrowser that shows all classes whose names start with 
	the letter S"

	self newOnClassesNamed: (self systemNavigation allClasses
				collect: [:c | c name]
				thenSelect: [:aName | aName first == $S])
		label: 'All classes starting with S'
	"ClassListBrowser example2"
]

{ #category : #examples }
ClassListBrowser class >> example3 [
	"Put up a ClassListBrowser that shows all Variable classes"

	self browseClassesSatisfying:  [:c | c isVariable] title: 'All Variable classes'

"ClassListBrowser example3"
	
]

{ #category : #examples }
ClassListBrowser class >> example4 [
	"Put up a ClassListBrowser that shows all classes implementing more than 100 methods"

	self browseClassesSatisfying:
		[:c | (c selectors size + c class selectors size) > 100] title: 'Classes with more than 100 methods'

"ClassListBrowser example4"
	
]

{ #category : #examples }
ClassListBrowser class >> example5 [
	"Put up a ClassListBrowser that shows all classes that lack class comments"

	self
		browseClassesSatisfying: 
			[:c | c organization classComment isEmptyOrNil] 
		title: 'Classes lacking class comments'

"ClassListBrowser example5"
	
]

{ #category : #examples }
ClassListBrowser class >> example6 [
	"Put up a ClassListBrowser that shows all classes that have class instance variables"

	self
		browseClassesSatisfying: 
			[:c | c class instVarNames size > 0]
		title:
			'Classes that define class-side instance variables'

"ClassListBrowser example6"
]

{ #category : #'instance creation' }
ClassListBrowser class >> newOnAllClasses [
	"Open a browser on all the classes in the system, listed alphabetically"
	"NB - what meaning does 'all classes' have in an environment that is not the root?
		- what might alphabetic ordering need to do for non-latin languages?"
	"ClassListBrowser newOnAllClasses"
		
	| newBrowser |

	newBrowser := self new.
	^ newBrowser buildAndOpenBrowserLabel: 'All Classes Alphabetically'

]

{ #category : #'instance creation' }
ClassListBrowser class >> newOnClassesNamed: aListOfClassNames label: aString [
	"Open a browser on all the classes in the list, set the label to aString since we may need to specify to the user what the list includes"
	"ClassListBrowser newOnClassesNamed: #(Browser Boolean) label: 'Browser and Boolean!'."		
	| newBrowser |

	newBrowser := self new.
	newBrowser initForClassesNamed: aListOfClassNames.
	^ newBrowser buildAndOpenBrowserLabel: aString

]

{ #category : #initialization }
ClassListBrowser >> defaultBrowserTitle [
	^  'Class List Browser' 
]

{ #category : #title }
ClassListBrowser >> defaultTitle: aTitle [
	"Set the browser's default title"

	defaultTitle := aTitle
]

{ #category : #initialization }
ClassListBrowser >> initAlphabeticListing [
	| tab stab index |
	self systemOrganizer: SystemOrganization.
	metaClassIndicated := false.
	classDisplayList := Smalltalk classNames.
]

{ #category : #initialization }
ClassListBrowser >> initForClassesNamed: nameList [
	"Initialize the receiver for the class-name-list"

	self systemOrganizer: SystemOrganization.
	metaClassIndicated := false.
	classDisplayList := nameList copy
]

{ #category : #title }
ClassListBrowser >> labelString [
	"Answer the label strilng to use on the browser"

	^ defaultTitle ifNil: [super labelString]
]

{ #category : #toolbuilder }
ClassListBrowser >> setupIfNotInitialisedYet [
	"ClassListBrowser needs some initialisation to work in the ToolBuilder>build: world since there has to be a list of classes ready to be listed. As a default we use the full list of classes in the system"

	classDisplayList ifNil:[self initAlphabeticListing]
]
