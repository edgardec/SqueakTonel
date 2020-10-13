Class {
	#name : #HierarchyBrowserTest,
	#superclass : #TestCase,
	#instVars : [
		'browser'
	],
	#category : #'ToolsTests-Browser'
}

{ #category : #running }
HierarchyBrowserTest >> setUp [
	browser := HierarchyBrowser new.
]

{ #category : #tests }
HierarchyBrowserTest >> testClassList [
	| c displayedClasses hierarchy |
	browser initHierarchyForClass: browser class.
	
	c := browser class theNonMetaClass.
	displayedClasses := browser classList collect: [:each | each withoutLeadingBlanks ].
	hierarchy := (c allSuperclasses reversed, {browser class}, c allSubclasses) collect: [ :each | each name ].
	self assert: displayedClasses = hierarchy.
]

{ #category : #tests }
HierarchyBrowserTest >> testClassListIndex [
	| expectedCat |
	expectedCat := [:i | (Smalltalk at: (browser classList at: i) withoutLeadingBlanks asSymbol) category ].
	browser initHierarchyForClass: browser class.
	self deny: browser classListIndex = 0.
	
	1 to: 3 do:
		[:n |
		browser classListIndex: n.
		self assert: browser classListIndex = n.
		self assert: browser selectedSystemCategory = (expectedCat value: n)]
]

{ #category : #tests }
HierarchyBrowserTest >> testClassListSansWhitespace [
	| c displayedClasses hierarchy |
	browser initHierarchyForClass: browser class.
	
	c := browser class theNonMetaClass.
	displayedClasses := browser classList collect: [:each | each withoutLeadingBlanks ].
	hierarchy := (c allSuperclasses reversed, {browser class}, c allSubclasses) collect: [ :each | each name ].
	self assert: displayedClasses = hierarchy.
]

{ #category : #tests }
HierarchyBrowserTest >> testInitHierarchyForClass [
	| b |

	b := HierarchyBrowser new initHierarchyForClass: browser class.
	self assert: b selectedClassName = browser class name.
]

{ #category : #tests }
HierarchyBrowserTest >> testSelectClass [
	browser initHierarchyForClass: browser class.
	browser selectClass: ProtoObject.
	self assert: browser selectedClass = ProtoObject.
	
	browser selectClass: CodeHolder.
	self assert: browser selectedClass = CodeHolder.
]

{ #category : #tests }
HierarchyBrowserTest >> testSelectedClassName [
	browser initHierarchyForClass: browser class.
	self assert: browser selectedClassName = browser class name.
	
	browser classListIndex: 0.
	self assert: browser selectedClassName isNil.
]
