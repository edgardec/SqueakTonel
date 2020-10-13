"
A DirectoryChooserDialog is a modal dialog to allow choosing a directory. The actual directory chosen is returned, or nil if no selection was made.

Normal usage would be 
	myDirectory := DirectoryChooserDialog openOn: myApplicationDefaultDirectory label: 'Choose the directory to use'

"
Class {
	#name : #DirectoryChooserDialog,
	#superclass : #FileAbstractSelectionDialog,
	#category : #'ToolBuilder-Morphic-Tools'
}

{ #category : #'instance creation' }
DirectoryChooserDialog class >> findAFolderForProject: aProject label: labelString [
	"Select a directory for either saving or loading a project file"
	"Temporary simple version without the 'interesting' blue ui stuff
	See FileList2 class>>#modalFolderSelectorForProject: for the full horror"
	^self openOn: FileDirectory default label: labelString
]

{ #category : #'instance creation' }
DirectoryChooserDialog class >> openOn: aDirectory label: labelString [
	"open a directory chooser starting with aDirectory"

	"DirectoryChooserDialog openOn: FileDirectory default label: 'Choose the directory to use' "

	^super new
		directory: aDirectory;
		message: labelString;
		getUserResponse
]

{ #category : #'initialize-release' }
DirectoryChooserDialog >> acceptFileName [
	"User clicked to accept the current state so save the directory and close the dialog"

	finalChoice := directory.
	self changed: #close
]

{ #category : #toolbuilder }
DirectoryChooserDialog >> buildButtonsWith: builder [
	"add a 'new directory' button to the beginning of the row of buttons"
	^{ builder pluggableButtonSpec new
				model: self;
				label: 'New Directory' translated;
				color: (self userInterfaceTheme get: #buttonColor for: #DialogWindow);
				action: #newDirectoryName}, (super buildButtonsWith: builder)
]

{ #category : #toolbuilder }
DirectoryChooserDialog >> buildDirectoryTreeWith: builder [

	^ (super buildDirectoryTreeWith: builder)
		hScrollBarPolicy: #never; "Use the dialog grips to see more"
		yourself
]

{ #category : #toolbuilder }
DirectoryChooserDialog >> buildWith: builder [
	"assemble the spec for the chooser dialog UI"

	| windowSpec window |
	windowSpec := self buildWindowWith: builder specs: {
		(self frameOffsetFromTop: 0
			fromLeft: 0
			width: 1
			offsetFromBottom: 0) -> [self buildDirectoryTreeWith: builder].
	}.
	windowSpec buttons addAll: ( self buildButtonsWith: builder ).
	window := builder build: windowSpec.
	window addKeyboardCaptureFilter: self.
	self changed: #selectedPath.
	^window

]

{ #category : #'ui details' }
DirectoryChooserDialog >> finalChoice [
	"return the chosen directory that was saved by an accept click or nil; client must check for validity"

	^ finalChoice
		ifNotNil: [self directory]
]

{ #category : #toolbuilder }
DirectoryChooserDialog >> initialExtent [
	"Since this is a single list it can be a bit narrower than a FileChooserDialog"

	^ super initialExtent * (0.5 @ 1)
]

{ #category : #'ui details' }
DirectoryChooserDialog >> userMessage [
	"return the string to present to the user  in order to explain the purpose of this dialog appearing"
	
	^message ifNil:['Choose a directory name']
]

{ #category : #'ui details' }
DirectoryChooserDialog >> windowTitle [
	
	^ 'Choose Directory'
]
