Class {
	#name : #MessageNamesTest,
	#superclass : #TestCase,
	#instVars : [
		'browser'
	],
	#category : #'ToolsTests-Browser'
}

{ #category : #running }
MessageNamesTest >> setUp [
	browser := MessageNames openMessageNames.
]

{ #category : #running }
MessageNamesTest >> tearDown [
	browser topView ifNotNil: [:v |
		ToolBuilder default close: v].
]

{ #category : #tests }
MessageNamesTest >> testCannotUnselectCategory [
	| selectorList |
	browser searchString: 'cull'.
	browser selectorListIndex: 1.
	selectorList := browser selectorList copy.
	
	browser selectorListIndex: 0.
	self assert: selectorList = browser selectorList.
]

{ #category : #tests }
MessageNamesTest >> testOpenMessageNames [
	| b |
	b := MessageNames openMessageNames.
	[self assert: (b isKindOf: MessageNames)]
		ensure: [ToolBuilder default close: b topView].
]

{ #category : #tests }
MessageNamesTest >> testSearchString [
	| cCount cullCount cullCullCount |
	browser searchString: 'c'.
	cCount := browser selectorList size.
	
	browser searchString: 'cull:'.
	cullCount := browser selectorList size.
	
	self assert: cullCount < cCount.
	
	browser searchString: 'cull:cull:'.
	cullCullCount := browser selectorList size.
	
	self assert: cullCullCount < cullCount.
]

{ #category : #tests }
MessageNamesTest >> testSelectedClassOrMetaClass [
	| firstClass |
	browser searchString: 'cull:'.
	firstClass := browser messageList first actualClass.
	
	browser messageListIndex: 1.
	self assert: browser selectedClassOrMetaClass = firstClass.
	
	browser messageListIndex: 0.
	self assert: browser selectedClassOrMetaClass isNil.
	
	"And just to be sure:"
	browser messageListIndex: 1.
	self assert: browser selectedClassOrMetaClass = firstClass.
]

{ #category : #tests }
MessageNamesTest >> testSelectedMessageCategoryName [
	browser searchString: 'cull:'.
	browser selectorListIndex: 1.
	browser messageListIndex: 1.
	self deny: browser selectedMessageCategoryName isNil.

	browser messageListIndex: 0.
	self assert: browser selectedMessageCategoryName isNil.
]

{ #category : #tests }
MessageNamesTest >> testSelection [
	browser searchString: 'cull:'.
	browser selectorListIndex: 1.
	browser messageListIndex: 1.
	self assert: (browser selection isKindOf: MethodReference).
	browser messageListIndex: 0.
	self assert: browser selection isNil.
]
