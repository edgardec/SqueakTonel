Class {
	#name : #FileListTest,
	#superclass : #ClassTestCase,
	#category : #'ToolsTests-FileList'
}

{ #category : #private }
FileListTest >> checkIsServiceIsFromDummyTool: service [
	
	^ (service instVarNamed: #provider) = DummyToolWorkingWithFileList and: [
		service label = 'menu label' and: [
		(service instVarNamed: #selector) = #loadAFileForTheDummyTool: ] ]
]

{ #category : #initialize }
FileListTest >> setUp [

	DummyToolWorkingWithFileList initialize.
]

{ #category : #initialize }
FileListTest >> tearDown [

	DummyToolWorkingWithFileList unregister.
]

{ #category : #tests }
FileListTest >> testAllRegisteredServices [
	"(self selector: #testAllRegisteredServices) debug"

	"This should not throw an exception."
	FileServices allRegisteredServices.
]

{ #category : #tests }
FileListTest >> testMenuReturned [
	"(self selector: #testToolRegistered) debug"

	self assert: (FileServices registeredFileReaderClasses includes: DummyToolWorkingWithFileList)
]

{ #category : #tests }
FileListTest >> testService [
	"a stupid test to check that the class returns a service"
	"(self selector: #testService) debug"
	
	| service |
	service := (DummyToolWorkingWithFileList fileReaderServicesForFile: 'abab.kkk' suffix: 'kkk') first.
	self assert: (self checkIsServiceIsFromDummyTool: service).
	service := (DummyToolWorkingWithFileList fileReaderServicesForFile: 'zkk.gz' suffix: 'gz').
	self assert: service isEmpty
]

{ #category : #tests }
FileListTest >> testServicesForFileEnding [
	"(self selector: #testServicesForFileEnding) debug"

	| items |
	items := (FileList new directory: FileDirectory default; yourself) 
	  itemsForFile: (FileDirectory default fullNameFor: 'aaa.kkk').
	self assert: (items anySatisfy: [ :ea | self checkIsServiceIsFromDummyTool: ea ]).

]

{ #category : #tests }
FileListTest >> testToolRegistered [
	"(self selector: #testToolRegistered) debug"

	self assert: (FileServices registeredFileReaderClasses includes: DummyToolWorkingWithFileList)
]

{ #category : #tests }
FileListTest >> testToolRegisteredUsingInterface [
	"(self selector: #testToolRegisteredUsingInterface) debug"

	self assert: (FileServices isReaderNamedRegistered: #DummyToolWorkingWithFileList)
]
