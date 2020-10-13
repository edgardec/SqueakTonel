"
Tests the optional hierarchical class ordering of Browser.
"
Class {
	#name : #BrowserHierarchicalListTest,
	#superclass : #TestCase,
	#category : #'ToolsTests-Browser'
}

{ #category : #assertion }
BrowserHierarchicalListTest >> assertCorrectOrderOf: classB followedBy: classA in: classCollection [

	"classB comes before classA. Assert that classB is a superclass of classB or that 
	a common superclass is in front of both"
	| commonSuperclasses commonSuperclass classAIndex classBIndex superIndex |
	classA == classB ifTrue: [^ self].
	(classA inheritsFrom: classB) ifTrue: [^ self].
	commonSuperclasses := classA withAllSuperclasses intersection: classB withAllSuperclasses.
	commonSuperclass := commonSuperclasses first.
	(classCollection includes: commonSuperclass) ifFalse: [^ self].
	classAIndex := classCollection indexOf: classA.
	classBIndex := classCollection indexOf: classB.
	superIndex := classCollection indexOf: commonSuperclass.
	(superIndex < classAIndex and: [superIndex < classBIndex]) ifTrue: [^self].
	self fail.
]

{ #category : #helper }
BrowserHierarchicalListTest >> hierarchicalClassListForCategory: category [

	^ Browser new
		selectSystemCategory: category;
		hierarchicalClassList.
]

{ #category : #helper }
BrowserHierarchicalListTest >> nameToClass: classNameWithIndent [

	^ Smalltalk classNamed: classNameWithIndent withoutLeadingBlanks asSymbol
]

{ #category : #tests }
BrowserHierarchicalListTest >> testListClassesHierarchically1 [

	| result classes category |
	category := 'Collections-Abstract'.
	result := self hierarchicalClassListForCategory: category.
	self assert: (SystemOrganization listAtCategoryNamed: category) size equals: result size.
	classes := result collect: [:ea | self nameToClass: ea].
	classes withIndexDo: [:ea : i |
		classes 
			from: 1 to: i
			do: [:other | self assertCorrectOrderOf: other followedBy: ea in: classes]].
]

{ #category : #tests }
BrowserHierarchicalListTest >> testListClassesHierarchically2 [

	| result classes category |
	category := 'Tools-Browser'.
	result := self hierarchicalClassListForCategory: category.
	self assert: (SystemOrganization listAtCategoryNamed: category) size equals: result size.
	classes := result collect: [:ea | self nameToClass: ea].
	classes withIndexDo: [:ea : i |
		classes 
			from: 1 to: i
			do: [:other | self assertCorrectOrderOf: other followedBy: ea in: classes]].
]

{ #category : #tests }
BrowserHierarchicalListTest >> testListClassesHierarchicallyIndent [

	| result dict  |
	result := self hierarchicalClassListForCategory: 'Tools-Browser'.
	"Create class->indent mapping"
	dict := result inject: Dictionary new into: [:classIndentMapping :className |
		| indent |
		indent := className count: [:char | char = Character space or: [char = Character tab]].
		classIndentMapping at: (self nameToClass: className) put: indent.
		classIndentMapping].
	"assert that indent of class is larger than indent of superclass"
	dict keysAndValuesDo: [:class :myIndent |
		dict at: class superclass ifPresent: [:superIndent |
			self assert: myIndent > superIndent]].
]
