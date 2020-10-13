"
An SMCategory is a ""tag"" that can be attached to SMCategorizableObjects in order to classify them.

The SMCategories are arranged in a strict hierarchy and each SMCategory both knows it's parent and it's subcategories.
The instvar objects holds all SMObjects belonging to this category.
Instvars name and summary are already inherited from SMObject and describe the category.
The instvar url can be used to refer to a web page that can explain the category in more detail, typically a page at the Squeak Swiki.
SMCategory adds an instance variable called mandatory holding a Set with the classes (SMPackage, SMPackageRelease, SMAccount, SMResource etc) that must belong to at least one subcategory of this SMCategory. Obviously not many categories will be mandatory for each class.

The category tree is maintained by a few trusted people so that chaos will not reign. :-)

"
Class {
	#name : #SMCategory,
	#superclass : #SMObject,
	#instVars : [
		'mandatory',
		'subCategories',
		'parent',
		'objects'
	],
	#category : #'SMBase-domain'
}

{ #category : #private }
SMCategory >> addCategory: cat [
	"Add a category as a subcategory to self.
	The collection of subcategories is lazily instantiated."

	subCategories ifNil: [subCategories := OrderedCollection new].
	cat parent ifNotNil: [cat parent removeCategory: cat ].
	subCategories add: cat.
	cat parent: self.
	^cat
]

{ #category : #private }
SMCategory >> addObject: anObject [
	"Add <anObject> to this category. This should only be called
	from SMCategorizableObject>>addCategory: to ensure consistency."
	
	(objects includes: anObject) ifFalse:[objects add: anObject]
]

{ #category : #services }
SMCategory >> allCategoriesDo: aBlock [
	"Evaluate <aBlock> for all categories below me including me,
	bottom up breadth-first."

	self allSubCategoriesDo: aBlock.
	aBlock value: self
]

{ #category : #services }
SMCategory >> allSubCategoriesDo: aBlock [
	"Evaluate <aBlock> for all categories below me NOT including me,
	bottom up breadth-first."

	subCategories ifNil: [^self].
	subCategories do: [:sub |
		sub allSubCategoriesDo: aBlock.
		aBlock value: sub]
]

{ #category : #services }
SMCategory >> categoryBefore [
	"Return the category listed before me in my parent.
	If I am first or I have no parent, return nil."

	parent isNil ifTrue:[^nil].
	parent subCategories first = self ifTrue:[^nil].
	^parent subCategories before: self
	
]

{ #category : #private }
SMCategory >> delete [
	"Delete me. Disconnect me from my objects and my parent.
	Then delete my subcategories."

	super delete.
	self removeFromObjects; removeFromParent.
	self subCategories do: [:c | c delete ]
]

{ #category : #view }
SMCategory >> getLink: aBuilder [
	"Return a link for using on the web.
	Always from the top."

	^aBuilder getLinkTop: 'category/', id asString text: name
]

{ #category : #testing }
SMCategory >> hasSubCategories [
	^subCategories isEmptyOrNil not
]

{ #category : #testing }
SMCategory >> includes: anObject [
	"Answer if <anObject> is in this category."

	^objects includes: anObject
]

{ #category : #'initialize-release' }
SMCategory >> initialize [
	super initialize.
	name := summary := url := ''.
	objects := OrderedCollection new
]

{ #category : #testing }
SMCategory >> isCategory [
	^true
]

{ #category : #testing }
SMCategory >> isTopCategory [
	^parent isNil
]

{ #category : #accessing }
SMCategory >> mandatory [
	^mandatory
]

{ #category : #accessing }
SMCategory >> mandatory: aSet [
	mandatory := aSet
]

{ #category : #accessing }
SMCategory >> mandatoryFor: aClass [
	"Is this category mandatory for instances of <aClass>?"

	^mandatory ifNil: [false] ifNotNil: [mandatory includes: aClass]
]

{ #category : #services }
SMCategory >> move: cat toAfter: before [
	"Move a category to be after the category <before>."

	subCategories remove: cat.
	before ifNil: [subCategories addFirst: cat] ifNotNil: [subCategories add: cat after: before]
]

{ #category : #accessing }
SMCategory >> objects [
	"Return all objects in this category."

	^objects
]

{ #category : #accessing }
SMCategory >> packages [
	"Return all packages in this category."

	^objects select: [:p | p isPackage]
]

{ #category : #accessing }
SMCategory >> parent [
	^parent
]

{ #category : #private }
SMCategory >> parent: aCategory [
	"Change the parent category.
	This method relies on that somebody else
	updates the parent's subCategories collection."
	
	parent := aCategory
]

{ #category : #services }
SMCategory >> parentsDo: aBlock [
	"Run a block for all my parents starting from the top."

	parent ifNotNil: [
		parent parentsDo: aBlock.
		aBlock value: parent]
]

{ #category : #printing }
SMCategory >> path [
	"Return my name with a full path of my
	parent names separated with slashes like:
		'Squeak versions/Squeak3.5' "

	^String streamContents: [:s |
		self parentsDo: [:cat |
			s nextPutAll: cat name; nextPutAll: '/'].
		s nextPutAll: self name]
]

{ #category : #printing }
SMCategory >> printOn: aStream [

	aStream nextPutAll: self class name, ': ', name
]

{ #category : #private }
SMCategory >> removeDeepFromObjects [
	"Remove myself from my objects and then ask
	my subCategories to do the same."

	self removeFromObjects.
	subCategories do: [:cat | cat removeDeepFromObjects]
]

{ #category : #private }
SMCategory >> removeFromObjects [
	"Remove myself from my objects."

	objects copy do: [:obj | obj removeCategory: self]
]

{ #category : #private }
SMCategory >> removeFromParent [
	"Remove me from my parent."

	parent ifNotNil: [parent removeCategory: self]
]

{ #category : #private }
SMCategory >> removeObject: anObject [
	"Remove <anObject> from this category. This should only be called
	from SMCategorizableObject>>removeCategory: to ensure consistency."
	
	^objects remove: anObject
]

{ #category : #accessing }
SMCategory >> subCategories [
	subCategories ifNil: [^#()].
	^subCategories
]

{ #category : #printing }
SMCategory >> type [

	^'Category'
]

{ #category : #view }
SMCategory >> viewFor: uiObject [
	"This is a double dispatch mechanism for multiple views
	for multiple uis."

	^uiObject categoryViewOn: self
]
