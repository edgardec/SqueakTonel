Class {
	#name : #DependencyBrowserTest,
	#superclass : #TestCase,
	#instVars : [
		'browser'
	],
	#category : #'ToolsTests-Browser'
}

{ #category : #running }
DependencyBrowserTest >> setUp [
	browser := DependencyBrowser new.
]

{ #category : #'tests - buttons' }
DependencyBrowserTest >> testBrowse [
	| b |
	browser packageListIndex: (browser packageList indexOf: #Collections).
	browser packageDepsIndex: (browser packageDeps indexOf: #Compiler).
	browser classDepsIndex: (browser classDeps indexOf: #Scanner).
	browser classListIndex: (browser classList indexOf: #Symbol).
	browser messageListIndex: 1.

	b := browser browseMethodFull.
	self assert: b notNil.
	[self assert: b selectedMessageName = (browser messageList at: browser messageListIndex) ]
		ensure: [ToolBuilder default close: b topView]
]

{ #category : #'tests - class list' }
DependencyBrowserTest >> testClassList [
	"Warning! When Collections' dependencies change, this test may start to fail!"
	self assert: #() equals: browser classList description: 'classList before package selection'.
	
	browser packageListIndex: (browser packageList indexOf: #Collections).
	self 
		assert: #()
		equals: browser classList
		description: 'classList after selecting Collections'.
	
	browser packageDepsIndex: (browser packageDeps indexOf: #Compiler).
	self 
		assert: browser classList notEmpty
		description: 'classList after selecting Compiler'.
	
	browser classDepsIndex: (browser classDeps indexOf: #Scanner).
	self 
		assert: #(Character String Symbol 'Symbol class') 
		equals: browser classList 
		description: 'classList after selecting Scanner class'.
	
	browser classListIndex: (browser classList indexOf: #Symbol).
	self 
		assert: #(Character String Symbol 'Symbol class') 
		equals: browser classList 
		description: 'classList after selecting Symbol class'.
]

{ #category : #'tests - metaclass' }
DependencyBrowserTest >> testHasPackageSelected [
	self deny: browser hasPackageSelected.
	
	browser packageListIndex: 1.
	self assert: browser hasPackageSelected.
	
	browser packageListIndex: 0.
	self deny: browser hasPackageSelected.
]

{ #category : #'tests - metaclass' }
DependencyBrowserTest >> testSelectedClassOrMetaClass [
	"Warning! When Collections' dependencies change, this test may start to fail!"
	self assert: browser selectedClassOrMetaClass isNil.

	browser packageListIndex: (browser packageList indexOf: #Collections).
	self assert: browser selectedClassOrMetaClass isNil.
	
	browser packageDepsIndex: (browser packageDeps indexOf: #Compiler).
	self assert: browser selectedClassOrMetaClass isNil.
	
	browser classDepsIndex: (browser classDeps indexOf: #Scanner).
	self assert: browser selectedClassOrMetaClass isNil.
	
	browser classListIndex: (browser classList indexOf: #Symbol).

	self deny: browser selectedClassOrMetaClass isNil.
	self assert: browser selectedClassOrMetaClass == Symbol.
]

{ #category : #'tests - message list' }
DependencyBrowserTest >> testSelectedMessageClassSideShowsSource [
	"Warning! When Collections' dependencies change, this test may start to fail!"

	browser packageListIndex: (browser packageList indexOf: #'Chronology-Core').
	browser packageDepsIndex: (browser packageDeps indexOf: #Collections).
	browser classDepsIndex: (browser classDeps indexOf: #'Array').
	browser classListIndex: (browser classList indexOf: #'DateAndTime').
	browser messageListIndex: 1.
	self assert: browser selectedMessageName == #ticks.
	
	self assert: browser contents = (DateAndTime sourceCodeAt: #ticks)

]

{ #category : #'tests - message list' }
DependencyBrowserTest >> testSelectedMessageName [
	"Warning! When Collections' dependencies change, this test may start to fail!"
	self assert: browser selectedMessageName isNil.

	browser packageListIndex: (browser packageList indexOf: #Collections).
	self assert: browser selectedMessageName isNil.
	
	browser packageDepsIndex: (browser packageDeps indexOf: #Compiler).
	self assert: browser selectedMessageName isNil.
	
	browser classDepsIndex: (browser classDeps indexOf: #Scanner).
	self assert: browser selectedMessageName isNil.
	
	browser classListIndex: (browser classList indexOf: #Symbol).
	self assert: browser selectedMessageName == #storeOn:.
	
	browser messageListIndex: 1.
	self assert: browser selectedMessageName == #storeOn:.
	
	browser messageListIndex: 0.
	self assert: browser selectedMessageName isNil.
]

{ #category : #'tests - message list' }
DependencyBrowserTest >> testSelectedMessageNameClassSide [
	"Warning! When Collections' dependencies change, this test may start to fail!"
	self assert: browser selectedMessageName isNil.

	browser packageListIndex: (browser packageList indexOf: #'Chronology-Core').
	self assert: browser selectedMessageName isNil.
	
	browser packageDepsIndex: (browser packageDeps indexOf: #Collections).
	self assert: browser selectedMessageName isNil.
	
	browser classDepsIndex: (browser classDeps indexOf: #Array).
	self assert: browser selectedMessageName isNil.
	
	browser classListIndex: (browser classList indexOf: #'DateAndTime').
	self assert: browser selectedMessageName == #ticks.
	
	browser messageListIndex: 1.
	self assert: browser selectedMessageName == #ticks.

]
