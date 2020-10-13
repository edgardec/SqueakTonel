Class {
	#name : #InstanceBrowser,
	#superclass : #Lexicon,
	#instVars : [
		'objectViewed'
	],
	#category : #'Protocols-Tools'
}

{ #category : #'user interface' }
InstanceBrowser >> defaultWindowColor [
	^ (Color r: 0.726 g: 0.9 b: 0.9)
]

{ #category : #'menu commands' }
InstanceBrowser >> inspectViewee [
	"Open an Inspector on the object I view"

	objectViewed inspect
]

{ #category : #'menu commands' }
InstanceBrowser >> offerMenu [
	"Offer a menu to the user, in response to the hitting of the menu button on the tool pane"

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu title: ('Messages of {1}' translated format: {objectViewed nameForViewer}).
	aMenu addStayUpItem.
	aMenu addTranslatedList: #(
		('vocabulary...' 			chooseVocabulary)
		('what to show...'			offerWhatToShowMenu)
		-
		('inst var refs (here)'		setLocalInstVarRefs)
		('inst var defs (here)'		setLocalInstVarDefs)
		('class var refs (here)'		setLocalClassVarRefs)
		-

		('navigate to a sender...' 	navigateToASender)
		('recent...' 					navigateToRecentMethod)
		('show methods in current change set'
									showMethodsInCurrentChangeSet)
		('show methods with initials...'
									showMethodsWithInitials)
		-
		"('toggle search pane' 		toggleSearch)"

		-
		-
		('browse full (b)' 			browseMethodFull)
		('browse hierarchy (h)'		browseClassHierarchy)
		('browse protocol (p)'		browseFullProtocol)
		-
		('fileOut'					fileOutMessage)
		('printOut'					printOutMessage)
		-
		('senders of... (n)'			browseSendersOfMessages)
		('implementors of... (m)'		browseMessages)
		('versions (v)' 				browseVersions)
		('inheritance (i)'			methodHierarchy)
		-
		('references... (r)' 				browseVariableReferences)
		('assignments... (a)' 				browseVariableAssignments)
		-
		('viewer on me'				viewViewee)
		('inspector on me'			inspectViewee)
		-
		('more...'					shiftedYellowButtonActivity)).
	
	^ aMenu popUpInWorld: self currentWorld
]

{ #category : #initialization }
InstanceBrowser >> openOnObject: anObject inWorld: ignored showingSelector: aSelector [
	"Create and open a SystemWindow to house the receiver, showing the categories pane."
	^self openOnObject: anObject showingSelector: aSelector
]

{ #category : #initialization }
InstanceBrowser >> openOnObject: anObject showingSelector: aSelector [
	"Create and open a SystemWindow to house the receiver, showing the categories pane."

	objectViewed := anObject.
	self openOnClass: anObject class showingSelector: aSelector
]

{ #category : #'as yet unclassified' }
InstanceBrowser >> setClassAndSelectorIn: csBlock [
	| cm |
	super setClassAndSelectorIn: [:class :selector |
		(class notNil and: [selector notNil]) ifTrue: [^ csBlock value: class value: selector].
		cm := targetClass
					lookupSelector: (self selection asString findTokens: Character space) first asSymbol.
		cm ifNotNil: [^ csBlock value: (cm methodClass ifNil: [targetClass]) value: cm selector]].
	^ csBlock value: nil value: nil
]

{ #category : #'window title' }
InstanceBrowser >> startingWindowTitle [
	"Answer the initial window title to apply"

	^ 'Vocabulary of ', objectViewed nameForViewer
]

{ #category : #'target-object access' }
InstanceBrowser >> targetObject [
	"Answer the object to which this tool is bound"

	^ objectViewed
]

{ #category : #'menu commands' }
InstanceBrowser >> viewViewee [
	"Open a viewer on the object I view"

	objectViewed beViewed
]
