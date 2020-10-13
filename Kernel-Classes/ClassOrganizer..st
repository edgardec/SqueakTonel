"
I represent method categorization information for classes.  The handling of class comments has gone through a tortuous evolution.   Grandfathered class comments (before late aug 98) have no time stamps, and historically, fileouts of class comments always substituted the timestamp reflecting the author and date/time at the moment of fileout; and historically any timestamps in a filed out class comment were dropped on the floor, with the author & time prevailing at the moment of filein being substituted.   Such grandfathered comments now go out on fileouts with '<historical>' timestamp; class comments created after the 8/98 changes will have their correct timestamps preserved, though there is not yet a decent ui for reading those stamps other than filing out and looking at the file; nor is there yet any ui for browsing and recovering past versions of such comments.  Everything in good time!
"
Class {
	#name : #ClassOrganizer,
	#superclass : #BasicClassOrganizer,
	#category : #'Kernel-Classes'
}

{ #category : #'class initialization' }
ClassOrganizer class >> cleanUp: aggressive [
	"Remove empty method categories when cleaning aggressively"

	aggressive ifTrue: [
		SystemChangeNotifier uniqueInstance doSilently: [
			Smalltalk removeEmptyMessageCategories]].

]

{ #category : #accessing }
ClassOrganizer >> addCategory: catString before: nextCategory [
	SystemChangeNotifier uniqueInstance
		doSilently: [super addCategory: catString before: nextCategory];
		protocolAdded: catString inClass: self subject
]

{ #category : #accessing }
ClassOrganizer >> changeFromCategorySpecs: categorySpecs [
	| oldDict oldCategories |
	oldDict := self elementCategoryDict.
	oldCategories := self categories copy.
	SystemChangeNotifier uniqueInstance doSilently: [
		super changeFromCategorySpecs: categorySpecs].
	self notifyOfChangedSelectorsOldDict: oldDict newDict: self elementCategoryDict.
	self notifyOfChangedCategoriesFrom: oldCategories to: self categories.
]

{ #category : #accessing }
ClassOrganizer >> classComment: aString [
	"Guards against setting the comment in a metaclass which is invalid"
	subject isMeta ifTrue:[^self error: 'Cannot set metaclass comments'].
	^super classComment: aString
]

{ #category : #accessing }
ClassOrganizer >> classComment: aString  stamp: aStamp [
	"Guards against setting the comment in a metaclass which is invalid"
	subject isMeta ifTrue:[^self error: 'Cannot set metaclass comments'].
	^super classComment: aString  stamp: aStamp
]

{ #category : #classifying }
ClassOrganizer >> classify: element under: heading logged: aBoolean [
	self classify: element under: heading suppressIfDefault: true logged: aBoolean

]

{ #category : #classifying }
ClassOrganizer >> classify: element under: heading suppressIfDefault: aBoolean [
	self classify: element under: heading suppressIfDefault: aBoolean logged: false

]

{ #category : #classifying }
ClassOrganizer >> classify: element under: heading suppressIfDefault: aBoolean logged: logged [ 
	| oldCat newCat |
	oldCat := self categoryOfElement: element.
	SystemChangeNotifier uniqueInstance doSilently: [
		super classify: element under: heading suppressIfDefault: aBoolean].
	newCat := self categoryOfElement: element.
	self notifyOfChangedSelector: element from: oldCat to: newCat.
	logged ifTrue: [self logChangedSelector: element category: newCat].

]

{ #category : #classifying }
ClassOrganizer >> classifyAllUnclassified [

	| organizers |
	organizers := self subject withAllSuperclasses collect: [:ea | ea organization].
	(self listAtCategoryNamed: ClassOrganizer default) do: [:sel | | found |
		found := (organizers collect: [ :org | org categoryOfElement: sel])
			detect: [:ea | ea ~= ClassOrganizer default and: [ ea ~= nil]]
			ifNone: [].
		found ifNotNil: [self classify: sel under: found]].

]

{ #category : #private }
ClassOrganizer >> logChangedSelector: element category: newCategory [
	"make an entry in the changes to record the changed category"
	| method |	
	"if we do not have a changes file, the code below would try to make a new method"
	(subject == nil or: [SourceFiles == nil or: [(SourceFiles at: 2) == nil]]) ifTrue: [^self].
	method := subject compiledMethodAt: element ifAbsent: [^self].
	subject logMethodSource: (method getSourceFor: element in: subject)
		forMethodWithNode: (CompiledMethodWithNode method: method node: method) 
		inCategory: newCategory withStamp: method timeStamp notifying: nil.

]

{ #category : #private }
ClassOrganizer >> logSelectorsInChangedCategory: newCategory [
	"make an entry in the changes file for each method in the changed category"
	(self listAtCategoryNamed: newCategory) do: [:element |
		self logChangedSelector: element category: newCategory].

]

{ #category : #private }
ClassOrganizer >> notifyOfChangedCategoriesFrom: oldCollectionOrNil to: newCollectionOrNil [
	(self hasSubject and: [oldCollectionOrNil ~= newCollectionOrNil]) 
		ifTrue: [SystemChangeNotifier uniqueInstance classReorganized: self subject].
]

{ #category : #private }
ClassOrganizer >> notifyOfChangedSelector: element from: oldCategory to: newCategory [
	(self hasSubject and: [(oldCategory ~= newCategory)]) ifTrue: [
		self subject notifyOfRecategorizedSelector: element from: oldCategory to: newCategory.
	].
]

{ #category : #private }
ClassOrganizer >> notifyOfChangedSelectorsOldDict: oldDictionaryOrNil newDict: newDictionaryOrNil [
	(oldDictionaryOrNil isNil and: [newDictionaryOrNil isNil])
		ifTrue: [^ self].
		
	oldDictionaryOrNil isNil ifTrue: [
	newDictionaryOrNil keysAndValuesDo: [:el :cat |
		self notifyOfChangedSelector: el from: nil to: cat].
		^ self.
	].

	newDictionaryOrNil isNil ifTrue: [
	oldDictionaryOrNil keysAndValuesDo: [:el :cat |
		self notifyOfChangedSelector: el from: cat to: nil].
		^ self.
	].
		
	oldDictionaryOrNil keysAndValuesDo: [:el :cat |
		| newCat |
		newCat := newDictionaryOrNil at: el.
		self notifyOfChangedSelector: el from: cat to: newCat.
	].
]

{ #category : #accessing }
ClassOrganizer >> removeCategory: cat [ 
	SystemChangeNotifier uniqueInstance
		doSilently: [super removeCategory: cat];
		protocolRemoved: cat inClass: self subject
]

{ #category : #accessing }
ClassOrganizer >> removeElement: element [
	| oldCat |
	oldCat := self categoryOfElement: element.
	SystemChangeNotifier uniqueInstance doSilently: [
		super removeElement: element].
	self notifyOfChangedSelector: element from: oldCat to: (self categoryOfElement: element).
]

{ #category : #accessing }
ClassOrganizer >> removeEmptyCategories [
	| oldCategories |
	oldCategories := self categories copy.
	SystemChangeNotifier uniqueInstance doSilently: [
		super removeEmptyCategories].
	self notifyOfChangedCategoriesFrom: oldCategories to: self categories.
]

{ #category : #accessing }
ClassOrganizer >> renameCategory: oldCatString toBe: newCatString [
	SystemChangeNotifier uniqueInstance
		doSilently: [super renameCategory: oldCatString toBe: newCatString];
		protocolRenamedFrom: oldCatString asSymbol to: newCatString asSymbol inClass: self subject.
	self logSelectorsInChangedCategory: newCatString.

]

{ #category : #accessing }
ClassOrganizer >> setDefaultList: aSortedCollection [
	| oldDict oldCategories |
	oldDict := self elementCategoryDict.
	oldCategories := self categories copy.
	SystemChangeNotifier uniqueInstance doSilently: [
		super setDefaultList: aSortedCollection].
	self notifyOfChangedSelectorsOldDict: oldDict newDict: self elementCategoryDict.
	self notifyOfChangedCategoriesFrom: oldCategories to: self categories.
]

{ #category : #accessing }
ClassOrganizer >> sortCategories [
	| oldCategories |
	oldCategories := self categories copy.
	SystemChangeNotifier uniqueInstance doSilently: [
		super sortCategories].
	self notifyOfChangedCategoriesFrom: oldCategories to: self categories.
]
