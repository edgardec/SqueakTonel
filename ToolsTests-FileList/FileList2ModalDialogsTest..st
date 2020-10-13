"
TestRunner open
"
Class {
	#name : #FileList2ModalDialogsTest,
	#superclass : #TestCase,
	#category : #'ToolsTests-FileList'
}

{ #category : #tests }
FileList2ModalDialogsTest >> testModalFileSelector [
	| window fileList2 |
	window := FileList2 morphicViewFileSelector.
	window openCenteredInWorld.
	fileList2 := window valueOfProperty: #fileListModel.
	fileList2 fileListIndex: 1.
	window delete.
	self assert: fileList2 getSelectedFile isNil.
	fileList2 okHit.
	self deny: fileList2 getSelectedFile isNil



]

{ #category : #tests }
FileList2ModalDialogsTest >> testModalFileSelectorForSuffixes [
	| window fileList2 |
	window := FileList2 morphicViewFileSelectorForSuffixes: nil.
	window openCenteredInWorld.
	fileList2 := window valueOfProperty: #fileListModel.
	fileList2 fileListIndex: 1.
	window delete.
	self assert: fileList2 getSelectedFile isNil.
	fileList2 okHit.
	self deny: fileList2 getSelectedFile isNil

]

{ #category : #tests }
FileList2ModalDialogsTest >> testModalFolderSelector [
	| window fileList2 |
	window := FileList2 morphicViewFolderSelector.
	fileList2 := window model.
	window openInWorld: self currentWorld extent: 300@400.
	fileList2 fileListIndex: 1.
	window delete.
	self assert: fileList2 getSelectedDirectory withoutListWrapper isNil.
	fileList2 okHit.
	self deny: fileList2 getSelectedDirectory withoutListWrapper isNil


]

{ #category : #tests }
FileList2ModalDialogsTest >> testModalFolderSelectorForProjectLoad [
	| window fileList2 w |
	window := FileList2
		morphicViewProjectLoader2InWorld: self currentWorld
		reallyLoad: false.
	fileList2 := window valueOfProperty: #FileList.
	w := self currentWorld.
	window position: w topLeft + (w extent - window extent // 2).
	window openInWorld: w.
	window delete.
	self assert: fileList2 getSelectedDirectory withoutListWrapper isNil.
	fileList2 okHit.
	self deny: fileList2 getSelectedDirectory withoutListWrapper isNil

]
