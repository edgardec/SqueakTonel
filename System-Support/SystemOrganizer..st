"
My instances provide an organization for the classes in the system, just as a ClassOrganizer organizes the messages within a class. The only difference is the methods for fileIn/Out.
"
Class {
	#name : #SystemOrganizer,
	#superclass : #Categorizer,
	#category : #'System-Support'
}

{ #category : #'class initialization' }
SystemOrganizer class >> cleanUp: agressive [
	"Remove empty categories when cleaning aggressively"

	agressive ifTrue:[SystemOrganization removeEmptyCategories].

]

{ #category : #'class initialization' }
SystemOrganizer class >> default [
	"I have a global instance, SystemOrganization.  In case someone stumbles upon my class, and does not know about the global, it can be accessed from here, too."

  ^ SystemOrganization.

]

{ #category : #accessing }
SystemOrganizer >> addCategory: catString before: nextCategory [
	self == SystemOrganization 
		ifTrue: 
			[SystemChangeNotifier uniqueInstance
				doSilently: [super addCategory: catString before: nextCategory];
				classCategoryAdded: catString]
		ifFalse:
			[super addCategory: catString before: nextCategory]
]

{ #category : #remove }
SystemOrganizer >> categoriesMatching: matchString [
	"Return all matching categories"
	^ self categories select: [:c | matchString match: c]
]

{ #category : #query }
SystemOrganizer >> classesIn: categoryName [

	| classes |
	classes := OrderedCollection new.
	self categories withIndexCollect: [:cat :idx |
		(categoryName match: cat)
			ifTrue: [classes addAll: (self listAtCategoryNumber: idx)]
			ifFalse: [nil]].
	^ classes collect: [:clsName | Smalltalk classNamed: clsName]
]

{ #category : #accessing }
SystemOrganizer >> classify: element under: newCategory [
	| oldCategory class |
	self flag: #environments. "do we want notifications for classes in other environments?"
	oldCategory := self categoryOfElement: element.
	super classify: element under: newCategory.
	class := Smalltalk at: element ifAbsent: [^ self].
	self == SystemOrganization ifTrue: [
		SystemChangeNotifier uniqueInstance
			class: class
			recategorizedFrom: oldCategory
			to: newCategory]
]

{ #category : #query }
SystemOrganizer >> commentInventory: categoryName [

	"SystemOrganization commentInventory: 'Morphic*'"

	| classes commentedClasses |
	classes := OrderedCollection new.
	self categories withIndexCollect: [:cat :idx |
		(categoryName match: cat)
			ifTrue: [classes addAll: (self listAtCategoryNumber: idx)]
			ifFalse: [nil]].
	commentedClasses := classes select: [:catCls | (Smalltalk at: catCls) hasComment].
	^ 'There are ' , classes size asString , ' classes in ' , categoryName ,
		' of which ' , commentedClasses size asString , ' have comments and ',
		(classes size - commentedClasses size) asString , ' do not yet have comments.'

]

{ #category : #'fileIn\/Out' }
SystemOrganizer >> fileOut [  "SystemOrganization fileOut"

	| internalStream |
	internalStream := WriteStream on: (String new: 30000).
	internalStream nextPutAll: 'SystemOrganization changeFromCategorySpecs: #('; cr;
		print: SystemOrganization;  "ends with a cr"
		nextPutAll: ')!'; cr.

	FileStream writeSourceCodeFrom: internalStream baseName: (FileDirectory default nextNameFor: 'SystemOrganization' extension: 'st') isSt: true useHtml: false

]

{ #category : #'fileIn\/Out' }
SystemOrganizer >> fileOutCategory: category [ 
	"Store on the file named category (a string) concatenated with '.st' all the 
	classes associated with the category."
	^ self fileOutCategory: category asHtml: false
]

{ #category : #'fileIn\/Out' }
SystemOrganizer >> fileOutCategory: category asHtml: useHtml [
	"FileOut all the classes in the named system category."
	| internalStream |
	internalStream := WriteStream on: (String new: 1000).
	self fileOutCategory: category on: internalStream initializing: true.

	FileStream writeSourceCodeFrom: internalStream baseName: category isSt: true useHtml: useHtml.

]

{ #category : #'fileIn\/Out' }
SystemOrganizer >> fileOutCategory: category on: aFileStream [ 
	"Store on the file associated with aFileStream, all the classes associated 
	with the category and any requested shared pools."
	^self fileOutCategory: category on: aFileStream initializing: true
]

{ #category : #'fileIn\/Out' }
SystemOrganizer >> fileOutCategory: category on: aFileStream initializing: aBool [
	"Store on the file associated with aFileStream, all the traits and classes associated 
	with the category and any requested shared pools in the right order."

	| first poolSet tempClass classes traits |
	traits := self orderedTraitsIn: category.
	classes := self superclassOrder: category.
	poolSet := Set new.
	classes do:  [:class | class sharedPools do: [:eachPool | poolSet add: eachPool]].
	poolSet size > 0 ifTrue: [
		tempClass := Class new.
		tempClass shouldFileOutPools ifTrue: [
			poolSet := poolSet select: [:aPool |
				tempClass shouldFileOutPool: (Smalltalk globals keyAtIdentityValue: aPool)].
			poolSet do: [:aPool | tempClass fileOutPool: aPool onFileStream: aFileStream]]].
	first := true.
	traits, classes do: [:each | 
		first
			ifTrue: [first := false]
			ifFalse: [aFileStream cr; nextPut: Character newPage; cr].
		each
			fileOutOn: aFileStream
			moveSource: false
			toFile: 0
			initializing: false].
	aBool ifTrue: [classes do: [:cls | cls fileOutInitializerOn: aFileStream]].
]

{ #category : #private }
SystemOrganizer >> ifClassOrganizerDo: aBlock [
	"Do nothing, since this is not a class organizer"
]

{ #category : #'fileIn\/Out' }
SystemOrganizer >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a path to me in the other system instead."

self == SystemOrganization ifTrue: [
	dp := DiskProxy global: #SystemOrganization selector: #yourself args: #().
	refStrm replace: self with: dp.
	^ dp].
^ self

]

{ #category : #'fileIn\/Out' }
SystemOrganizer >> orderedTraitsIn: category [ 
	"Answer an OrderedCollection containing references to the traits in the 
	category whose name is the argument, category (a string). The traits 
	are ordered so they can be filed in."

	| behaviors traits |
	behaviors := (self listAtCategoryNamed: category asSymbol) 
			collect: [:title | Smalltalk at: title].
	traits := behaviors reject: [:each | each isBehavior].
	^traits asArray sort: [:t1 :t2 |
		(t2 traitComposition allTraits includes: t1)
			or: [(t1 traitComposition allTraits includes: t2) not]]
]

{ #category : #remove }
SystemOrganizer >> removeCategoriesMatching: matchString [
	"Remove all matching categories with their classes"
	(self categoriesMatching: matchString) do:
		[:c | self removeSystemCategory: c]
]

{ #category : #accessing }
SystemOrganizer >> removeCategory: cat [ 
	| r |
	r := super removeCategory: cat.
	self == SystemOrganization
		ifTrue: [SystemChangeNotifier uniqueInstance classCategoryRemoved: cat].
	^ r
]

{ #category : #remove }
SystemOrganizer >> removeMissingClasses [
	"Remove any class names that are no longer in the Smalltalk dictionary. Used for cleaning up after garbage collecting user-generated classes."
	"SystemOrganization removeMissingClasses"

	elementArray copy do: [:el |
		(Smalltalk includesKey: el) ifFalse: [self removeElement: el]].

]

{ #category : #remove }
SystemOrganizer >> removeSystemCategory: category [
	"remove all the classes and traits associated with the category"

	 (self orderedTraitsIn: category) , (self superclassOrder: category)
		reverseDo: [:each | each removeFromSystem].

	self removeCategory: category.

]

{ #category : #accessing }
SystemOrganizer >> renameCategory: oldCatString toBe: newCatString [
	| r |
	r := super renameCategory: oldCatString toBe: newCatString.
	self == SystemOrganization ifTrue: [
		SystemChangeNotifier uniqueInstance 
			classCategoryRenamedFrom: oldCatString to: newCatString].
	^ r
]

{ #category : #'fileIn\/Out' }
SystemOrganizer >> superclassOrder: category [ 
	"Answer an OrderedCollection containing references to the classes in the 
	category whose name is the argument, category (a string). The classes 
	are ordered with superclasses first so they can be filed in."

	| behaviors classes |
	behaviors := (self listAtCategoryNamed: category asSymbol) 
			collect: [:title | Smalltalk at: title].
	classes := behaviors select: [:each | each isBehavior].
	^ChangeSet superclassOrder: classes
]

{ #category : #query }
SystemOrganizer >> uncommentedClassesIn: categoryName [

	"SystemOrganization uncommentedClassesIn: 'Morphic*'"

	^ (self classesIn: categoryName) select: [:cls | cls hasComment not]
]
