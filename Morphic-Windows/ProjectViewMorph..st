"
I am a Morphic view of a project. I display a scaled version of the project's thumbnail, which itself is a scaled-down snapshot of the screen taken when the project was last exited. When I am displayed, I check to see if the project thumbnail has changed and, if so, I update my own view of that thumbnail.

"
Class {
	#name : #ProjectViewMorph,
	#superclass : #ImageMorph,
	#instVars : [
		'project',
		'lastProjectThumbnail'
	],
	#category : #'Morphic-Windows'
}

{ #category : #scripting }
ProjectViewMorph class >> defaultNameStemForInstances [
	^ 'ProjectView' translatedNoop
]

{ #category : #'fileIn\/Out' }
ProjectViewMorph class >> fileReaderServicesForFile: fullName suffix: suffix [

	^({ 'extseg'. 'project'. 'pr'. 'morph'. 'morphs'. 'sp'. '*' } includes: suffix)
		ifTrue: [ self services]
		ifFalse: [#()]
]

{ #category : #'class initialization' }
ProjectViewMorph class >> initialize [

	FileServices registerFileReader: self
]

{ #category : #'project window creation' }
ProjectViewMorph class >> newMVCProject [
	"Create an instance of me on a new MVC project (in a SystemWindow)."

	| proj window |
	proj := Project new.
	window := (SystemWindow labelled: proj name) model: proj.
	window
		addMorph: (self on: proj)
		frame: (0@0 corner: 1.0@1.0).
	^ window

]

{ #category : #'project window creation' }
ProjectViewMorph class >> newProjectViewInAWindowFor: aProject [
	"Return an instance of me on a new Morphic project (in a SystemWindow)."

	| window proj |
	proj := self on: aProject.
	window := (SystemWindow labelled: aProject name) model: aProject.
	window
		addMorph: proj
		frame: (0@0 corner: 1.0@1.0).
	proj borderWidth: 0.
	^ window

]

{ #category : #'instance creation' }
ProjectViewMorph class >> on: aProject [

	^ self new on: aProject

]

{ #category : #'project window creation' }
ProjectViewMorph class >> openFromDirectory: aDirectory andFileName: aFileName [
	
	Project canWeLoadAProjectNow ifFalse: [^ self].
	^ProjectLoading openFromDirectory: aDirectory andFileName: aFileName
]

{ #category : #'project window creation' }
ProjectViewMorph class >> openFromDirectoryAndFileName: anArray [
	
	Project canWeLoadAProjectNow ifFalse: [^ self].
	^ProjectLoading 
		openFromDirectory: anArray first 
		andFileName: anArray second
]

{ #category : #'project window creation' }
ProjectViewMorph class >> openFromFile: fileName [
	
	self flag: #bob.		"better not to use this one. nil directories are not nice.
						see #openFromDirectoryAndFileName: or 
						#openFromDirectory:andFileName: instead"

	self halt.

	Project canWeLoadAProjectNow ifFalse: [^ self].
	^ProjectLoading openFromDirectory: nil andFileName: fileName
]

{ #category : #'project window creation' }
ProjectViewMorph class >> openFromFileList: fullName [
	
	self flag: #bob.		"not sent??"

	self halt.

	^self openFromFile:  fullName
]

{ #category : #'instance creation' }
ProjectViewMorph class >> openOn: aProject [
	"Open a ProjectViewMorph for the project in question"
	ProjectViewOpenNotification signal ifTrue: [
		Preferences projectViewsInWindows ifTrue: [
			(self newProjectViewInAWindowFor: aProject) openInWorld
		] ifFalse: [
			(self on: aProject) openInWorld		"but where??"
		].
	].

]

{ #category : #'project window creation' }
ProjectViewMorph class >> serviceOpenProjectFromFile [
	"Answer a service for opening a .pr project file"

	^ (SimpleServiceEntry 
		provider: self 
		label: 'load as project' translatedNoop
		selector: #openFromDirectoryAndFileName:
		description: 'open project from file' translatedNoop
		buttonLabel: 'load' translatedNoop
	)
		argumentGetter: [ :fileList | fileList dirAndFileName]
]

{ #category : #'fileIn\/Out' }
ProjectViewMorph class >> services [

	^ Array with: self serviceOpenProjectFromFile

	
]

{ #category : #'initialize-release' }
ProjectViewMorph class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #'submorphs-add\/remove' }
ProjectViewMorph >> abandon [
	"Home ViewMorph of project is going away."

	project := nil.
	super abandon.


]

{ #category : #layout }
ProjectViewMorph >> acceptDroppingMorph: morphToDrop event: evt [
	"Accept -- in a custom sense here -- a morph dropped on the receiver."

	| myCopy smallR |

	(self isTheRealProjectPresent) ifFalse: [
		^morphToDrop rejectDropMorphEvent: evt.		"can't handle it right now"
	].
	(morphToDrop isKindOf: NewHandleMorph) ifTrue: [	"don't send these"
		^morphToDrop rejectDropMorphEvent: evt.
	].
	self dropEnabled ifFalse:
		[^ morphToDrop rejectDropMorphEvent: evt].

	self eToyRejectDropMorph: morphToDrop event: evt.		"we will send a copy"
	myCopy := morphToDrop veryDeepCopy.	"gradient fills require doing this second"
	smallR := (morphToDrop bounds scaleBy: image height / Display height) rounded.
	smallR := smallR squishedWithin: image boundingBox.
	image getCanvas
		paintImage: (morphToDrop imageForm scaledToSize: smallR extent)
		at: smallR topLeft.
	myCopy openInWorld: project world


]

{ #category : #private }
ProjectViewMorph >> addProjectNameMorph [

	| m |

	self removeAllMorphs.
	m := UpdatingStringMorph contents: self safeProjectName font: self fontForName.
	m target: self; getSelector: #safeProjectName; putSelector: #safeProjectName:.
	m useStringFormat; fitContents.
	self addMorphBack: m.
	self updateNamePosition.
	^m


]

{ #category : #private }
ProjectViewMorph >> addProjectNameMorphFiller [

	| m |

	self removeAllMorphs.
	m := AlignmentMorph newRow color: Color transparent.
	self addMorphBack: m.
	m
		on: #mouseDown send: #editTheName: to: self;
		on: #mouseUp send: #yourself to: self.
	self updateNamePosition.


]

{ #category : #events }
ProjectViewMorph >> balloonText [
	^ 'Click here to enter the
project named
"{1}"' translated format: {project name}
]

{ #category : #accessing }
ProjectViewMorph >> borderWidthForRounding [

	^1
]

{ #category : #events }
ProjectViewMorph >> checkForNewerVersionAndLoad [

	self withProgressDo: [
		project loadFromServer
	] 


]

{ #category : #drawing }
ProjectViewMorph >> colorAroundName [

	^Color gray: 0.8
]

{ #category : #initialization }
ProjectViewMorph >> dismissViaHalo [
	| choice |
	project ifNil:[^self delete]. "no current project"
	choice := UIManager default chooseFrom: {
		'yes - delete the window and the project' translated.
		'no - delete the window only' translated
	} title: ('Do you really want to delete {1}
and all its content?' translated format: {project name printString}).
	choice = 1 ifTrue:[^self expungeProject].
	choice = 2 ifTrue:[^self delete].
]

{ #category : #events }
ProjectViewMorph >> doButtonAction [
	"My inherent button action consists of entering the project I represent"

	self enter
]

{ #category : #drawing }
ProjectViewMorph >> drawOn: aCanvas [

	| font projectName nameForm rectForName |

	self ensureImageReady.
	super drawOn: aCanvas.
	self isEditingName ifTrue: [^self].

	font := self fontForName.
	projectName := self safeProjectName.
	nameForm := (StringMorph contents: projectName font: font) imageForm.
	nameForm := nameForm scaledToSize: (self extent - (4@2) min: nameForm extent).
	rectForName := self bottomLeft + 
			(self width - nameForm width // 2 @ (nameForm height + 2) negated)
				extent: nameForm extent.
	rectForName topLeft eightNeighbors do: [ :pt |
		aCanvas
			stencil: nameForm 
			at: pt
			color: self colorAroundName.
	].
	aCanvas
		drawImage: nameForm 
		at: rectForName topLeft

]

{ #category : #events }
ProjectViewMorph >> editTheName: evt [

	self isTheRealProjectPresent ifFalse: [
		^self inform: 'The project is not present and may not be renamed now' translated
	].
	self addProjectNameMorph launchMiniEditor: evt.
]

{ #category : #drawing }
ProjectViewMorph >> ensureImageReady [

	self isTheRealProjectPresent ifFalse: [^self].
	project thumbnail ifNil: [
		image fill: image boundingBox rule: Form over 
			fillColor: project color.
		^self
	].
	project thumbnail ~~ lastProjectThumbnail ifTrue: ["scale thumbnail to fit my bounds"
		lastProjectThumbnail := project thumbnail.
		self updateImageFrom: lastProjectThumbnail.
		project thumbnail ifNotNil: [project thumbnail hibernate].
		image borderWidth: 1
	].



]

{ #category : #events }
ProjectViewMorph >> enter [
	"Enter my project."

	self world == self outermostWorldMorph ifFalse: [^Beeper beep].	"can't do this at the moment"
	project class == DiskProxy 
		ifFalse: 
			[(project world notNil and: 
					[project world isMorph 
						and: [project world hasOwner: self outermostWorldMorph]]) 
				ifTrue: [^Beeper beep	"project is open in a window already"]].
	project class == DiskProxy 
		ifTrue: 
			["When target is not in yet"

			self enterWhenNotPresent.	"will bring it in"
			project class == DiskProxy ifTrue: [^self inform: 'Project not found' translated]].
	(owner isSystemWindow) ifTrue: [project viewSize: self extent].
	self showMouseState: 3.
	project 
		enter: false
		revert: false
		saveForRevert: false
]

{ #category : #events }
ProjectViewMorph >> enterAsActiveSubproject [
    "Enter my project."

    project class == DiskProxy 
        ifTrue: 
            ["When target is not in yet"

            [self enterWhenNotPresent    "will bring it in"] on: ProjectEntryNotification
                do: [:ex | ^ex projectToEnter enterAsActiveSubprojectWithin: self world].
            project class == DiskProxy ifTrue: [self error: 'Could not find view']].
    (owner isSystemWindow) ifTrue: [project viewSize: self extent].
    self showMouseState: 3.
    project enterAsActiveSubprojectWithin: self world
]

{ #category : #events }
ProjectViewMorph >> enterWhenNotPresent [

	self withProgressDo: [
		project enter: false revert: false saveForRevert: false.	"will bring it in"
	] 


]

{ #category : #events }
ProjectViewMorph >> expungeProject [

	(self confirm: ('Do you really want to delete {1}
and all its content?' translated format: {project name}))
		ifFalse: [^ self].
	owner isSystemWindow
		ifTrue: [owner model: nil;
				 delete].
	
	project delete.
	self delete.
]

{ #category : #geometry }
ProjectViewMorph >> extent: aPoint [
	"Set my image form to the given extent."

	| newExtent scaleP scale |

	((bounds extent = aPoint) and: [image depth = Display depth]) ifFalse: [
		lastProjectThumbnail ifNil: [ lastProjectThumbnail := image ].
		scaleP := aPoint / lastProjectThumbnail extent.
		scale := scaleP "scaleP x asFloat max: scaleP y asFloat".
		newExtent := (lastProjectThumbnail extent * scale) rounded.
		self image: (Form extent: newExtent depth: Display depth).
		self updateImageFrom: lastProjectThumbnail.
	].
	self updateNamePosition.
]

{ #category : #drawing }
ProjectViewMorph >> fontForName [

	^(TextStyle default fontOfSize: 15) emphasized: 1

]

{ #category : #'event handling' }
ProjectViewMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'event handling' }
ProjectViewMorph >> handlesMouseOver: evt [
	^ true
]

{ #category : #'event handling' }
ProjectViewMorph >> handlesMouseOverDragging: evt [

	^ true
]

{ #category : #initialization }
ProjectViewMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	"currentBorderColor := Color gray."
	self addProjectNameMorphFiller.
	self enableDragNDrop: true.
	self isOpaque: true.

]

{ #category : #drawing }
ProjectViewMorph >> isEditingName [

	| nameMorph |
	nameMorph := self findA: UpdatingStringMorph.
	nameMorph ifNil: [^false].

	^nameMorph hasFocus

]

{ #category : #drawing }
ProjectViewMorph >> isTheRealProjectPresent [

	project ifNil: [^ false].
	project isInMemory ifFalse: [^ false].
	project class == DiskProxy ifTrue: [^ false].
	^true

]

{ #category : #events }
ProjectViewMorph >> lastProjectThumbnail: aForm [
	
	lastProjectThumbnail := aForm
]

{ #category : #'event handling' }
ProjectViewMorph >> mouseDown: evt [

	evt yellowButtonPressed ifTrue:
		[self showMenuForProjectView].
	evt hand newMouseFocus: self.
	self removeProperty: #wasOpenedAsSubproject.
	self showMouseState: 2.
]

{ #category : #'event handling' }
ProjectViewMorph >> mouseEnter: evt [

	self showMouseState: 1
]

{ #category : #'event handling' }
ProjectViewMorph >> mouseLeave: evt [

	self showMouseState: 3.

]

{ #category : #'event handling' }
ProjectViewMorph >> mouseLeaveDragging: evt [

	self mouseLeave: evt


]

{ #category : #'event handling' }
ProjectViewMorph >> mouseUp: evt [

	((self containsPoint: evt cursorPoint) and: 
				[(self hasProperty: #wasOpenedAsSubproject) not]) ifTrue:
		[^ self enter].
	self showMouseState: 3.

]

{ #category : #'objects from disk' }
ProjectViewMorph >> objectForDataStream: refStrm [
	
	| copy |

	1 = 1 ifTrue: [^self].		"this didn't really work"

	copy := self copy lastProjectThumbnail: nil.
	"refStrm replace: self with: copy."
	^copy

]

{ #category : #events }
ProjectViewMorph >> on: aProject [

	project := aProject.
	self addProjectNameMorphFiller.
	lastProjectThumbnail := nil.
	project thumbnail: project previewImageForm.
	project thumbnail
		ifNil: [self extent: 100@80]		"more like screen dimensions?"
		ifNotNil: [self extent: project thumbnail extent].
]

{ #category : #accessing }
ProjectViewMorph >> project [
	^project
]

{ #category : #events }
ProjectViewMorph >> project: aProject [

	project := aProject.
	self addProjectNameMorphFiller.
]

{ #category : #caching }
ProjectViewMorph >> releaseCachedState [

	"see if we can reduce size of published file, but there may be problems"
	super releaseCachedState.
	lastProjectThumbnail := image.

]

{ #category : #drawing }
ProjectViewMorph >> safeProjectName [
	| projectName args |
	projectName := self valueOfProperty: #SafeProjectName ifAbsent: ['???'].
	self isTheRealProjectPresent 
		ifFalse: 
			[project class == DiskProxy 
				ifTrue: 
					[args := project constructorArgs.
					((args isKindOf: Array) 
						and: [args size = 1 and: [args first isString]]) 
							ifTrue: [^args first]]
				ifFalse: [^projectName]].
	self setProperty: #SafeProjectName toValue: project name.
	^project name
]

{ #category : #drawing }
ProjectViewMorph >> safeProjectName: aString [ 
	self addProjectNameMorphFiller.
	self isTheRealProjectPresent ifFalse: [^self].
	project renameTo: aString.
	self setProperty: #SafeProjectName toValue: project name.
	self updateNamePosition.
	(owner isSystemWindow) ifTrue: [owner setLabel: aString]
]

{ #category : #events }
ProjectViewMorph >> seeIfNameChanged [

	| nameBefore nameNow |

	nameBefore := self valueOfProperty: #SafeProjectName ifAbsent: ['???'].
	nameNow := self safeProjectName.
	(submorphs notEmpty and: [nameBefore = nameNow]) ifTrue: [^self].
	self addProjectNameMorphFiller.

]

{ #category : #drawing }
ProjectViewMorph >> showBorderAs: aColor [

	"image border: image boundingBox width: 1 fillColor: aColor.
	currentBorderColor := aColor.
	self changed"

]

{ #category : #events }
ProjectViewMorph >> showMenuForProjectView [
	| menu |
	(menu := MenuMorph new)
		add: 'enter this project' translated
		action: [^ self enter];

 		add: 'ENTER ACTIVE' translated
		action: [self setProperty: #wasOpenedAsSubproject toValue: true.
            ^ self enterAsActiveSubproject];
		
		add: 'PUBLISH (also saves a local copy)' translated
		action: [^ project storeOnServerShowProgressOn: self forgetURL: false];
		
		add: 'PUBLISH to a different server' translated
		action: [project forgetExistingURL.
			^ project storeOnServerShowProgressOn: self forgetURL: true];
		
		add: 'see if server version is more recent' translated
		action: [^ self checkForNewerVersionAndLoad];

		addLine;
		add: 'expunge this project' translated
		action: [^ self expungeProject].

	menu title: ('Project Named \"{1}"' translated withCRs format: {project name}).
	menu invokeModal.
]

{ #category : #events }
ProjectViewMorph >> showMouseState: anInteger [ 
	| aMorph |
	(owner isSystemWindow)
		ifTrue: [aMorph := owner]
		ifFalse: [aMorph := self].
	anInteger = 1
		ifTrue: ["enter"
			aMorph
				addMouseActionIndicatorsWidth: 10
				color: (Color blue alpha: 0.3)].
	anInteger = 2
		ifTrue: ["down"
			aMorph
				addMouseActionIndicatorsWidth: 15
				color: (Color blue alpha: 0.7)].
	anInteger = 3
		ifTrue: ["leave"
			aMorph deleteAnyMouseActionIndicators]
]

{ #category : #'stepping and presenter' }
ProjectViewMorph >> step [
	| cmd |
	"Check for a command that could not be executed in my subproject.  Once it is done, remove the trigger.  If this is too slow, make armsLengthCmd an inst var."

	self seeIfNameChanged.
	cmd := self valueOfProperty: #armsLengthCmd.
	cmd ifNil: [^ super step].
	self removeProperty: #armsLengthCmd.
	project perform: cmd.
	project enter.
]

{ #category : #'stepping and presenter' }
ProjectViewMorph >> stepTime [

	^1000
]

{ #category : #'fileIn\/out' }
ProjectViewMorph >> storeSegment [
	"Store my project out on the disk as an ImageSegment.  Keep the outPointers in memory.  Name it <project name>.seg"

	project storeSegment

]

{ #category : #accessing }
ProjectViewMorph >> thumbnail [
	^ project ifNotNil: [project thumbnail]
]

{ #category : #drawing }
ProjectViewMorph >> updateImageFrom: sourceForm [

	(WarpBlt toForm: image)
		sourceForm: sourceForm;
		cellSize: 2;  "installs a colormap"
		combinationRule: Form over;
		copyQuad: (sourceForm boundingBox) innerCorners
		toRect: image boundingBox.

]

{ #category : #drawing }
ProjectViewMorph >> updateNamePosition [

	| nameMorph shadowMorph nameFillerMorph |

	(nameMorph := self findA: UpdatingStringMorph) ifNotNil: [
		nameMorph position:
			(self left + (self width - nameMorph width // 2)) @
			(self bottom - nameMorph height - 2).
	].
	(nameFillerMorph := self findA: AlignmentMorph) ifNotNil: [
		nameFillerMorph
			position: self bottomLeft - (0@20);
			extent: self width@20.
	].
	(shadowMorph := self findA: ImageMorph) ifNotNil: [
		shadowMorph delete	"no longer used"
	].


]

{ #category : #copying }
ProjectViewMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
project := deepCopier references at: project ifAbsent: [project].
lastProjectThumbnail := deepCopier references at: lastProjectThumbnail 
				ifAbsent: [lastProjectThumbnail].

]

{ #category : #copying }
ProjectViewMorph >> veryDeepInner: deepCopier [ 
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	project := project.	"Weakly copied"
	lastProjectThumbnail := lastProjectThumbnail veryDeepCopyWith: deepCopier.

]

{ #category : #'dropping\/grabbing' }
ProjectViewMorph >> wantsDroppedMorph: aMorph event: evt [
	"Answer if the receiver would accept a drop of a given morph."

	"If drop-enabled not set, answer false"
	(super wantsDroppedMorph: aMorph event: evt) ifFalse: [^ false].

	"If project not present, not morphic, or not initialized, answer false"
	self isTheRealProjectPresent ifFalse: [^ false].
	project isMorphic ifFalse: [^ false].
	project world viewBox ifNil: [^ false].

	^ true
]

{ #category : #'event handling' }
ProjectViewMorph >> wantsKeyboardFocusFor: aSubmorph [

	^true
]

{ #category : #rounding }
ProjectViewMorph >> wantsRoundedCorners [
	^SystemWindow roundedWindowCorners 
		and: [(owner isSystemWindow) not]
]

{ #category : #events }
ProjectViewMorph >> withProgressDo: aBlock [

	ComplexProgressIndicator new 
		targetMorph: self;
		historyCategory: 'project loading';
		withProgressDo: aBlock

]
