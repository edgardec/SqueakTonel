"
Used to generate .sexp files for the Quick Guides.  These are the help system for Etoys.  
How to use:
Pressing the Help button [?] at the top left of the screen, brings up the QuickGuides flap.  The index page has categories of help.  The Jump To... button allows you to get to any help guide.  
To create a new guide, copy the bookmorph out of the flap.  Use the halos to completely change the contents.  Create help pages for a new topic.  
When you are done, write the entire project out using ""Keep the current project"".  It is now a .pr file.
If you put the .pr into the QuickGuides folder, you will be able to see it in the Help flap.  (Click the Help button [?] once to close help, and once again to open it.)
You can test a .pr file in the QuickGuides folder, but it is not in the proper format to include in the OLPC build.
The purpose of QuickGuideGenerator is to put a guide in to the proper format for distribution.  
0) Get the new Guides from  http://tinlizzie.org/quickguides
1) Make a folder called ""To-Be-Translated"" at the top level of your file system.  Put the .pr files of all new guides into this folder.
1.5) Make a folder called ""Newer"" in the folder that has the Etoys image file.  Must be a fresh new folder.
2) Start Etoys.  You will NOT save this image.
3) Execute
	QuickGuideGenerator new openInWorld.
4) Wait until a new window appears.
5) Find the folder ""To-Be-Translated"" in the list and click on it.  It's path will appear in the top pane.
6) Press the ""Generate"" button. Wait.
7) Quit Etoys.
8) ""Newer"" will now have a .sexp file for each guide that was a .pr file.   Files ending in .sexp contain Yoshiki's S-expression linearization of object trees.
9) Copy the .sexp files to QuickGuides, and delete the .pr files of the same name.
10) Rename Newer to be Newer-day-month-year
11) Copy Newer-xx to http://tinlizzie.org/share/QG-compressed
12) copy the .sexp files into http://tinlizzie.org/share/QG-compressed/Quickguides


"
Class {
	#name : #QuickGuideGenerator,
	#superclass : #Morph,
	#instVars : [
		'input',
		'output',
		'inputMorph',
		'outputMorph',
		'fileList'
	],
	#category : #'Etoys-Squeakland-Morphic-Books'
}

{ #category : #all }
QuickGuideGenerator >> currentDirectorySelected [

	^ fileList currentDirectorySelected.

]

{ #category : #all }
QuickGuideGenerator >> generate [

	| inDir outDir |
	inDir := FileDirectory on: input.
	inDir fileNames ifEmpty: [
		self inform: 'the input path doesn''t point to\the directory with projects' withCRs. ^ self].
	outDir := FileDirectory on: output.
	outDir assureExistence.
	outDir fileNames ifNotEmpty: [
		"self halt.	let me see what is in it!"
		self inform: 'output directory is not empty.\Please remove files in it first.' withCRs. ^ self].

	QuickGuideMorph convertProjectsWithBooksToSISSIn: inDir to: outDir.

]

{ #category : #all }
QuickGuideGenerator >> getInput [

	^ input.

]

{ #category : #all }
QuickGuideGenerator >> getOutput [

	^ output.

]

{ #category : #all }
QuickGuideGenerator >> initialDirectoryList [

	^ fileList initialDirectoryList
]

{ #category : #all }
QuickGuideGenerator >> initialize [

	super initialize.
	input := ''.
	output := (FileDirectory on: Smalltalk imagePath) fullPathFor: 'Newest'.
	self setup.

]

{ #category : #all }
QuickGuideGenerator >> makeInputDirList [

	| m |
	fileList := FileList2 morphicView model.
	fileList directory: (FileDirectory default).
	m := (SimpleHierarchicalListMorph 
		on: self
		list:  #initialDirectoryList
		selected: #currentDirectorySelected
		changeSelected: #setSelectedDirectoryTo:
		menu: nil
		keystroke: nil)
			autoDeselect: false;
			enableDrag: false;
			enableDrop: true;
			yourself.
	m extent: m extent + (200@200).
	^ m.

]

{ #category : #all }
QuickGuideGenerator >> setInput: aString [

	input := aString asString.
	(input endsWith: FileDirectory slash) ifTrue: [input := input copyFrom: 1 to: input size - 1].
	inputMorph hasUnacceptedEdits: false.

]

{ #category : #all }
QuickGuideGenerator >> setOutput: aString [

	output := aString asString.
	(output endsWith: FileDirectory slash) ifTrue: [output := output copyFrom: 1 to: output size - 1].
	outputMorph hasUnacceptedEdits: false.

]

{ #category : #all }
QuickGuideGenerator >> setSelectedDirectoryTo: dir [

	input := dir withoutListWrapper pathName.
	fileList setSelectedDirectoryTo: dir.

	self changed: #fileList.
	self changed: #contents.
	self changed: #currentDirectorySelected.
	self changed: #getInput.

]

{ #category : #all }
QuickGuideGenerator >> setup [

	| button |
	self color: Color lightBlue.
	self extent: 650@360.
	self addMorph: self makeInputDirList.
	inputMorph := PluggableTextMorph on: self text: #getInput accept: #setInput:.
	inputMorph acceptOnCR: true.
	self addMorph: inputMorph.
	inputMorph extent: 300@50.
	inputMorph position: 355@0.

	outputMorph := PluggableTextMorph on: self text: #getOutput accept: #setOutput:.
	outputMorph acceptOnCR: true.
	outputMorph extent: 300@50.
	outputMorph position: 355@50.
	self addMorph: outputMorph.

	button := SimpleButtonMorph new.
	button
		labelString: 'Generate' font: Preferences standardMenuFont;
		actionSelector: #generate;
		arguments: #();
		target: self.
	button position: 365@125.
	self addMorph: button.

		
]
