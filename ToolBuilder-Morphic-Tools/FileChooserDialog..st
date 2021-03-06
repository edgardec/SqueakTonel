"
A FileChooserDialog is a modal dialog to allow choosing a file. The full file name is returned, or nil if no selection was made.

Normal usage would be 
	myFilename := FileChooserDialog openOn: myApplicationDefaultDirectory pattern: '*.myapp' label: 'Choose the file to load'
to find a file with a name matching *.myapp and with the directory initial choice set to myApplicationDefaultDirectory.  Only filenames matching the pattern will appear in the file list view.

"
Class {
	#name : #FileChooserDialog,
	#superclass : #FileAbstractSelectionDialog,
	#category : #'ToolBuilder-Morphic-Tools'
}

{ #category : #'instance creation' }
FileChooserDialog class >> openOn: aDirectory [
	"Open a modal dialog to choose a file. Start the dialog with aDirectory selected
	and files matching the default 'everything' pattern"

	"FileChooserDialog openOn: FileDirectory default"

	^self openOn: aDirectory pattern: nil label: nil

]

{ #category : #'instance creation' }
FileChooserDialog class >> openOn: aDirectory pattern: matchString label: labelString [
	"Open a modal dialog to choose a file. Start the dialog with aDirectory selected
	and files matching the matchString pattern. Set the user message to labelString."

	"FileChooserDialog openOn: FileDirectory default pattern: '*.changes' label: 'Do something with the selected files' "

	^self new
		directory: aDirectory;
		pattern: matchString;
		message: labelString;
		getUserResponse
]

{ #category : #'instance creation' }
FileChooserDialog class >> openOn: aDirectory suffixList: aCollection label: labelString [
	"Open a modal dialog to choose a file. Start the dialog with aDirectory selected 	and files matching the file name suffixes in aCollection. Set the user message to labelString."

	"FileChooserDialog openOn: FileDirectory default suffixList: { 'changes' . 'image' } label: 'Do something with the selected files' "

	^self new
		directory: aDirectory;
		suffixList: aCollection;
		message: labelString;
		getUserResponse
]

{ #category : #'instance creation' }
FileChooserDialog class >> openOnPattern: matchString label: labelString [
	"Open a modal dialog to choose a file. Start the dialog with a default directory
	selected and with files matching the default 'everything' pattern  Set the user
	message to labelString"

	"FileChooserDialog openOnPattern: '*.changes' label: 'Do something with the selected files' "

	^self openOn: nil pattern: matchString label: labelString

]

{ #category : #'instance creation' }
FileChooserDialog class >> openOnSuffixList: patternList label: labelString [
	"Open a modal dialog to choose a file. Start the dialog with a default directory
	selected and with files matching the file name suffixes in patternList. Set the
	user message to labelString."

	"FileChooserDialog openOnSuffixList: { 'changes' . 'image' } label: 'Do something with the selected files' "

	^self openOn: nil suffixList: patternList label: labelString

]

{ #category : #toolbuilder }
FileChooserDialog >> buildWith: builder [
	"assemble the spec for the chooser dialog UI"

	| windowSpec window |
	windowSpec := self buildWindowWith: builder specs: {
		(self frameOffsetFromTop: 0
			fromLeft: 0.35
			width: 0.65
			offsetFromBottom: 0) -> [self buildFileListWith: builder].
		(self frameOffsetFromTop: 0
			fromLeft: 0
			width: 0.35
			offsetFromBottom: 0) -> [self buildDirectoryTreeWith: builder].
	}.
	windowSpec buttons addAll: ( self buildButtonsWith: builder ).
	window := builder build: windowSpec.
	window addKeyboardCaptureFilter: self.
	self changed: #selectedPath.
	^window

]

{ #category : #'ui details' }
FileChooserDialog >> userMessage [
	"return the string to present to the user  in order to explain the purpose of this dialog appearing"
	
	^message ifNil:['Choose a file name']
]

{ #category : #'ui details' }
FileChooserDialog >> windowTitle [
	"return the window label; would be some application dependent string but I suspect we will want to make the outer morph a dialogue box with no label anyway"
	
	^ 'Choose File'
]
