"
I'm a dummy class for testing that the registration of the tool to the FileList of actually happens.
In the future the tests should cover that the class register when loaded in memory and unregister when unloaded.
"
Class {
	#name : #DummyToolWorkingWithFileList,
	#superclass : #Object,
	#category : #'ToolsTests-FileList'
}

{ #category : #'class initialization' }
DummyToolWorkingWithFileList class >> fileReaderServicesForFile: fullName suffix: suffix [

	^ (suffix = 'kkk')
		ifTrue: [ self services]
		ifFalse: [#()] 
]

{ #category : #'class initialization' }
DummyToolWorkingWithFileList class >> initialize [
	"self initialize"

	FileServices registerFileReader: self


]

{ #category : #'class initialization' }
DummyToolWorkingWithFileList class >> loadAFileForTheDummyTool: aFileListOrAPath [
	
	"attention. if the file list selects a file the argument will be a fullpath of the selected file else it will pass the filelist itself"
]

{ #category : #'class initialization' }
DummyToolWorkingWithFileList class >> serviceLoadAFilForDummyTool [
	"Answer a service for opening the Dummy tool"

	^ SimpleServiceEntry 
		provider: self 
		label: 'menu label'
		selector: #loadAFileForTheDummyTool:
		description: 'Menu label for dummy tool'
		buttonLabel: 'test'
]

{ #category : #'class initialization' }
DummyToolWorkingWithFileList class >> services [ 

	^ Array with: self serviceLoadAFilForDummyTool


]

{ #category : #'class initialization' }
DummyToolWorkingWithFileList class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #'class initialization' }
DummyToolWorkingWithFileList class >> unregister [

	FileServices unregisterFileReader: self.
	
]
