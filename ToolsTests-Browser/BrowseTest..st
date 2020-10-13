Class {
	#name : #BrowseTest,
	#superclass : #TestCase,
	#instVars : [
		'originalBrowserClass',
		'originalHierarchyBrowserClass'
	],
	#category : #'ToolsTests-Browser'
}

{ #category : #private }
BrowseTest >> currentBrowsers [

	^ (Project current world submorphsSatisfying: [:each |
		(each isKindOf: SystemWindow)
			and: [each model isKindOf: Browser]]) asSet
]

{ #category : #private }
BrowseTest >> currentHierarchyBrowsers [

	^ (Project current world submorphsSatisfying: [:each |
		(each isKindOf: SystemWindow)
			and: [each model isKindOf: HierarchyBrowser]]) asSet
]

{ #category : #private }
BrowseTest >> ensureMorphic [
	self isMorphic ifFalse: [self error: 'This test should be run in Morphic'].
]

{ #category : #private }
BrowseTest >> isMorphic [
	^Smalltalk isMorphic
]

{ #category : #running }
BrowseTest >> setUp [
	| systemNavigation |
	systemNavigation := SystemNavigation default.
	originalBrowserClass := systemNavigation browserClass.
	originalHierarchyBrowserClass := systemNavigation hierarchyBrowserClass.
	
	 systemNavigation browserClass: nil.
	 systemNavigation hierarchyBrowserClass: nil.
	
	
]

{ #category : #running }
BrowseTest >> tearDown [
	| systemNavigation |
	systemNavigation := SystemNavigation default.
	 systemNavigation browserClass: originalBrowserClass.
	 systemNavigation hierarchyBrowserClass: originalHierarchyBrowserClass.
]

{ #category : #tests }
BrowseTest >> testBrowseClass [
	"self debug: #testBrowseClass"
	| browsersBefore browsersAfter opened |
	self ensureMorphic.
	
	browsersBefore := self currentBrowsers.
	self withImmediatelyOpeningWindowsDo: [1 class browse].
	browsersAfter := self currentBrowsers.
	
	self assert:  (browsersAfter size  = (browsersBefore size + 1)).
	opened := browsersAfter removeAll: browsersBefore; yourself.
	self assert:  (opened size = 1).
	opened := opened asArray first.
	self assert: (opened model selectedClass == SmallInteger).
	
	opened delete
	
	
	
]

{ #category : #tests }
BrowseTest >> testBrowseHierarchyClass [
	"self debug: #testBrowseHierarchyClass"
	| browsersBefore browsersAfter opened |
	self ensureMorphic.
	
	browsersBefore := self currentHierarchyBrowsers.
	self withImmediatelyOpeningWindowsDo: [1 class browseHierarchy].
	browsersAfter := self currentHierarchyBrowsers.
	
	self assert:  (browsersAfter size  = (browsersBefore size + 1)).
	opened := browsersAfter removeAll: browsersBefore; yourself.
	self assert:  (opened size = 1).
	opened := opened asArray first.
	self assert: (opened model selectedClass == SmallInteger).
	
	opened delete
	
	
	
]

{ #category : #tests }
BrowseTest >> testBrowseHierarchyInstance [
	"self debug: #testBrowseHierarchyInstance"
	| browsersBefore browsersAfter opened |
	self ensureMorphic.
	
	browsersBefore := self currentHierarchyBrowsers.
	self withImmediatelyOpeningWindowsDo: [1 browseHierarchy].
	browsersAfter := self currentHierarchyBrowsers.
	
	self assert:  (browsersAfter size  = (browsersBefore size + 1)).
	opened := browsersAfter removeAll: browsersBefore; yourself.
	self assert:  (opened size = 1).
	opened := opened asArray first.
	self assert: (opened model selectedClass == SmallInteger).
	
	opened delete
	
	
	
]

{ #category : #tests }
BrowseTest >> testBrowseHierarchyMetaclass [
	"self debug: #testBrowseHierarchyMetaclass"
	| browsersBefore browsersAfter opened |
	self ensureMorphic.
	
	browsersBefore := self currentHierarchyBrowsers.
	self withImmediatelyOpeningWindowsDo: [1 class class browseHierarchy].
	browsersAfter := self currentHierarchyBrowsers.
	
	self assert:  (browsersAfter size  = (browsersBefore size + 1)).
	opened := browsersAfter removeAll: browsersBefore; yourself.
	self assert:  (opened size = 1).
	opened := opened asArray first.
	self assert: (opened model selectedClass == Metaclass).
	
	opened delete
	
	
	
]

{ #category : #tests }
BrowseTest >> testBrowseInstance [
	"self debug: #testBrowseInstance"
	| browsersBefore browsersAfter opened |
	self ensureMorphic.
	
	browsersBefore := self currentBrowsers.
	self withImmediatelyOpeningWindowsDo: [1 browse].
	browsersAfter := self currentBrowsers.
	
	self assert:  (browsersAfter size  = (browsersBefore size + 1)).
	opened := browsersAfter removeAll: browsersBefore; yourself.
	self assert:  (opened size = 1).
	opened := opened asArray first.
	self assert: (opened model selectedClass == SmallInteger).
	
	opened delete
	
	
	
]

{ #category : #tests }
BrowseTest >> testBrowseMetaclass [
	"self debug: #testBrowseMetaclass"
	| browsersBefore browsersAfter opened |
	self ensureMorphic.
	
	browsersBefore := self currentBrowsers.
	self withImmediatelyOpeningWindowsDo: [1 class class browse].
	browsersAfter := self currentBrowsers.
	
	self assert:  (browsersAfter size  = (browsersBefore size + 1)).
	opened := browsersAfter removeAll: browsersBefore; yourself.
	self assert:  (opened size = 1).
	opened := opened asArray first.
	self assert: (opened model selectedClass == SmallInteger).
	
	opened delete
	
	
	
]

{ #category : #tests }
BrowseTest >> testFindReferencesToFloatNaN [
	self assert: (SystemNavigation new allCallsOn: (Float bindingOf: #NaN)) notEmpty
]

{ #category : #tests }
BrowseTest >> testSystemNavigationAllBehaviorsDo [
	| oc |
	oc := OrderedCollection new.
	SystemNavigation new allBehaviorsDo:
		[:c| oc add: c].
	self assert: oc size = oc asSet size
]

{ #category : #private }
BrowseTest >> withImmediatelyOpeningWindowsDo: aBlock [
	"Turn off any preferences that defer to the user to open a window."
	| openToolsAttachedToMouseCursor |
	(UIManager default respondsTo: #openToolsAttachedToMouseCursor:) ifFalse:
		[^aBlock value].

	openToolsAttachedToMouseCursor := UIManager default openToolsAttachedToMouseCursor.
	UIManager default openToolsAttachedToMouseCursor: false.
	^aBlock ensure:
		[UIManager default openToolsAttachedToMouseCursor: openToolsAttachedToMouseCursor]
]
