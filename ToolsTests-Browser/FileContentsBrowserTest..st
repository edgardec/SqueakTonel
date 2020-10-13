Class {
	#name : #FileContentsBrowserTest,
	#superclass : #TestCase,
	#instVars : [
		'browser'
	],
	#category : #'ToolsTests-Browser'
}

{ #category : #running }
FileContentsBrowserTest >> setUp [
	| fileout testCat |
	testCat := self class category.
	fileout := WriteStream on: (String new: 10000).
	SystemOrganization fileOutCategory: testCat on: fileout.
	browser := FileContentsBrowser createBrowserForStream: fileout readStream named: testCat.
]

{ #category : #tests }
FileContentsBrowserTest >> testBrowsingAChangesetShowsMethods [

	| newChangeSet fileContents internalStream class |
	newChangeSet := ChangeSet basicNewNamed: 'fooTestSet' , (Random new nextLargeInt: 10000) asString.
	SystemChangeNotifier uniqueInstance doSilently: [
		class := Object subclass: #FileContentsBrowserTestTestObject
			instanceVariableNames: ''
			classVariableNames: ''
			poolDictionaries: ''
			category: self class category name asString.
		class compileSilently: 'theTestMethod ^ false'].
	
	newChangeSet adoptSelector: #theTestMethod forClass: class.

	internalStream := WriteStream on: (String new: 10000).
	newChangeSet fileOutOn: internalStream.
	fileContents := internalStream contents.
	class removeFromSystem.
	
	browser := FileContentsBrowser createBrowserForStream: (MultiByteBinaryOrTextStream with: fileContents) named: 'testFoo'.

	browser selectSystemCategory: browser systemCategoryList first.
	browser selectClassNamed: browser classList first.
	
	self assert: browser messageList size = 1.
]

{ #category : #tests }
FileContentsBrowserTest >> testChangeMessageCategoriesLeavesClassSelected [
	browser selectSystemCategory: browser systemCategoryList first.
	browser selectClassNamed: self class name.
	
	"This is a no-op."
	browser changeMessageCategories: browser classOrMetaClassOrganizer printString.
	self assert: browser selectedClassName = self class name.
]
