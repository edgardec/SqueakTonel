"
EToyProjectHistoryMorph new openInWorld

EToyProjectHistoryMorph provides a quick reference of the most recent projects. Click on one to go there.
"
Class {
	#name : #EToyProjectHistoryMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'changeCounter'
	],
	#category : #'Etoys-Experimental'
}

{ #category : #'parts bin' }
EToyProjectHistoryMorph class >> descriptionForPartsBin [
	^ self partName: 	'ProjectHistory' translatedNoop
		categories:		#()
		documentation:	'A tool that lets you navigate back to recently-visited projects' translatedNoop
]

{ #category : #'as yet unclassified' }
EToyProjectHistoryMorph >> closeMyFlapIfAny [

	| myFlap allTabs myTab myWorld |

	myWorld := self world.
	myFlap := self nearestOwnerThat: [ :each | each isFlap].
	myFlap ifNil: [
		self delete.
		^self].
	allTabs := myWorld submorphs select: [ :each | each isFlapTab].
	myTab := allTabs detect: [ :each | each referent == myFlap] ifNone: [^self].
	myTab hideFlap.
	self refreshWorld.
	

]

{ #category : #'as yet unclassified' }
EToyProjectHistoryMorph >> confirmedDelete: aProject evt: evt from: origin [
	
	self delete.
	aProject = Project current ifTrue: [
		^ self inform: 'Cannot delete current project' translated].
	(self confirm: ('Do you really want to delete {1}
and all its content?' translated format: {aProject name}))
		ifTrue: [
			aProject isTopProject ifTrue: [Project current beTopProject].
			aProject delete.
			Project rebuildAllProjects].
]

{ #category : #initialization }
EToyProjectHistoryMorph >> defaultBorderColor [
	^ Color transparent
]

{ #category : #initialization }
EToyProjectHistoryMorph >> defaultBorderStyle [
	^ BorderStyle raised
]

{ #category : #initialization }
EToyProjectHistoryMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 4
]

{ #category : #initialization }
EToyProjectHistoryMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightBrown
]

{ #category : #initialization }
EToyProjectHistoryMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self listDirection: #topToBottom;
		 layoutInset: 4;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 useRoundedCorners;
		 rebuild 
]

{ #category : #'as yet unclassified' }
EToyProjectHistoryMorph >> jumpToProject [

	self closeMyFlapIfAny.
	Project current jumpToProject.


]

{ #category : #'as yet unclassified' }
EToyProjectHistoryMorph >> mouseDown: evt in: aMorph [

	aMorph setProperty: #mouseDownPoint toValue: evt cursorPoint.

]

{ #category : #'as yet unclassified' }
EToyProjectHistoryMorph >> mouseLeave: evt in: aMorph [

	aMorph removeProperty: #mouseDownPoint.
]

{ #category : #'as yet unclassified' }
EToyProjectHistoryMorph >> mouseMove: evt in: aMorph [

	| start tuple project url pvm |
	start := aMorph valueOfProperty: #mouseDownPoint ifAbsent: [^self].
	(start dist: evt cursorPoint) abs < 5 ifTrue: [^self].
	aMorph removeProperty: #mouseDownPoint.
	evt hand hasSubmorphs ifTrue: [^self].
	tuple := aMorph valueOfProperty: #projectParametersTuple ifAbsent: [^self].
	project := tuple fourth first.
	(project notNil and: [project world notNil]) ifTrue: [
		^evt hand attachMorph: (ProjectViewMorph on: project).
	].
	url := tuple third.
	url isEmptyOrNil ifTrue: [^self].
	pvm := ProjectViewMorph new.
	pvm
		project: (DiskProxy global: #Project selector: #namedUrl: args: {url});
		lastProjectThumbnail: tuple second.
	evt hand attachMorph: pvm.

]

{ #category : #'as yet unclassified' }
EToyProjectHistoryMorph >> mouseUp: evt in: aMorph [

	| tuple project url |

	(aMorph boundsInWorld containsPoint: evt cursorPoint) ifFalse: [^self].
	tuple := aMorph valueOfProperty: #projectParametersTuple ifAbsent: [^Beeper beep].
	project := tuple fourth first.
	(project notNil and: [project world notNil]) ifTrue: [self closeMyFlapIfAny. ^project enter].
	url := tuple third.
	url isEmptyOrNil ifTrue: [^Beeper beep].
	self closeMyFlapIfAny.
	ProjectLoading thumbnailFromUrl: url.

"---
	newTuple := {
		aProject name.
		aProject thumbnail.
		aProject url.
		WeakArray with: aProject.
	}.
---"
]

{ #category : #'as yet unclassified' }
EToyProjectHistoryMorph >> rebuild [

	| history r1 |
	history := ProjectHistory currentHistory mostRecentCopy.
	changeCounter := ProjectHistory changeCounter.
	self removeAllMorphs.
	self rubberBandCells: true.
	r1 := self addARow: {
		self inAColumn: {
			StringMorph new contents: 'Jump...' translated; lock.
		}.
	}.
	r1 on: #mouseUp send: #jumpToProject to: self.

	history do: [ :each |
		(
			self addARow: {
				(each second scaledToSize: 64@64) asMorph.
				(self inARow: {
					StringMorph new contents: each first; lock.
					"StringMorph new contents: each fourth first; lock."
				}) hResizing: #spaceFill; layoutInset: 10@0.
				(self inAColumn: {
					StringMorph new
						color: Color red;
						contents: 'X';
						on: #mouseDown send: #confirmedDelete:evt:from: to: self withValue: each fourth first
				}) hResizing: #shrinkWrap.
			}
		)
			color: Color paleYellow;
			borderStyle: (BorderStyle raised width: 1);
			vResizing: #spaceFill;
			on: #mouseUp send: #mouseUp:in: to: self;
			on: #mouseDown send: #mouseDown:in: to: self;
			on: #mouseMove send: #mouseMove:in: to: self;
			on: #mouseLeave send: #mouseLeave:in: to: self;
			setProperty: #projectParametersTuple toValue: each;
			setBalloonText: (each third isEmptyOrNil ifTrue: ['not saved'] ifFalse: [each third])
	].
"---
	newTuple := {
		aProject name.
		aProject thumbnail.
		aProject url.
		WeakArray with: aProject.
	}.
---"
]

{ #category : #'stepping and presenter' }
EToyProjectHistoryMorph >> step [

	changeCounter = ProjectHistory changeCounter ifTrue: [^self].
	self rebuild.
	
]
