"
I sort a set of passed MCDefinitions, resolving all dependency conflicts automatically.

To use me, first add some items to me using the building protocol or my class-side #items: selector. After that, send #orderedItems to me and I will tell you all items in a loadable order.

Instance Variables
	nondeferred:	<SequenceableCollection>
		Usual items that do not require special sorting mechanics.
	deferred:		<SequenceableCollection>
		Items that are added after all nondeferred items. See MCDefinition >> #wantsToBeOutermost.
	required:		<Set>
	provided:		<Set>
"
Class {
	#name : #MCDependencySorter,
	#superclass : #Object,
	#instVars : [
		'nondeferred',
		'deferred',
		'required',
		'provided'
	],
	#category : #'Monticello-Loading'
}

{ #category : #'instance creation' }
MCDependencySorter class >> items: aCollection [
	^ self new addAll: aCollection
]

{ #category : #'instance creation' }
MCDependencySorter class >> new [
	^ self basicNew initialize
]

{ #category : #utility }
MCDependencySorter class >> sortItems: aCollection [
	| sorter |
	sorter := self items: aCollection.
	sorter externalRequirements do: [:req  | sorter addProvision: req].
	^ sorter orderedItems
]

{ #category : #building }
MCDependencySorter >> add: anItem [
	| requirements |
	(anItem wantsToBeOutermost)
		ifTrue: [^self addDeferred: anItem].
	requirements := self unresolvedRequirementsFor: anItem.
	requirements isEmpty
		ifTrue: [self addToOrder: anItem]
		ifFalse: [self addRequirements: requirements for: anItem].
	^anItem
]

{ #category : #building }
MCDependencySorter >> addAll: aCollection [
	aCollection asArray sort do: [:ea | self add: ea]
]

{ #category : #private }
MCDependencySorter >> addDeferred: anItem [
	"Add an item to the derred list. Deferred items will be appended to #orderedItems after all nondeferred items. See #wantsToBeOutermost."

	^ deferred add: anItem
]

{ #category : #building }
MCDependencySorter >> addExternalProvisions: aCollection [
	(aCollection intersection: self externalRequirements)
		do: [:ea | self addProvision: ea]
]

{ #category : #private }
MCDependencySorter >> addProvision: anObject [
	| newlySatisfied |
	provided add: anObject.
	newlySatisfied := required removeKey: anObject ifAbsent: [#()].
	self addAll: newlySatisfied.
]

{ #category : #private }
MCDependencySorter >> addRequirement: reqObject for: itemObject [
	(self itemsRequiring: reqObject) add: itemObject
]

{ #category : #private }
MCDependencySorter >> addRequirements: aCollection for: anObject [
	aCollection do: [:ea | self addRequirement: ea for: anObject]
]

{ #category : #private }
MCDependencySorter >> addToOrder: anItem [
	nondeferred add: anItem.
	anItem provisions do: [:ea | self addProvision: ea].
]

{ #category : #accessing }
MCDependencySorter >> externalRequirements [
	| unloaded providedByUnloaded |
	unloaded := self itemsWithMissingRequirements.
	providedByUnloaded := (unloaded gather: [:e | e provisions]) asSet.
	^ required keys reject: [:ea | providedByUnloaded includes: ea ]
]

{ #category : #'initialize-release' }
MCDependencySorter >> initialize [
	provided := Set new.
	required := Dictionary new.
	nondeferred := OrderedCollection new.
	deferred := OrderedCollection new.
]

{ #category : #private }
MCDependencySorter >> itemsRequiring: anObject [
	^ required at: anObject ifAbsentPut: [Set new]
]

{ #category : #accessing }
MCDependencySorter >> itemsWithMissingRequirements [
	| items |
	items := Set new.
	required do: [:ea | items addAll: ea].
	^ items

]

{ #category : #accessing }
MCDependencySorter >> orderedItems [
	"Return all ordered items, first nondeferred items, second deferred (outermost) items."

	^ nondeferred , deferred
]

{ #category : #private }
MCDependencySorter >> unresolvedRequirementsFor: anItem [
	^ anItem requirements difference: provided
]
