Class {
	#name : #SugarButton,
	#superclass : #ThreePhaseButtonMorph,
	#instVars : [
		'mouseDownTime',
		'didMenu',
		'labelName',
		'highLightColor',
		'disabledImage'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #initialization }
SugarButton >> adaptToWorld: aWorld [

	super adaptToWorld: aWorld.
	self state: #off.

]

{ #category : #accessing }
SugarButton >> disabled [

	self state: #disabled.

]

{ #category : #accessing }
SugarButton >> disabledImage: aForm [

	disabledImage := aForm.

]

{ #category : #drawing }
SugarButton >> drawOn: aCanvas [

	| origin |
	image ifNil: [origin := 0@0] ifNotNil: [origin := bounds origin + ((bounds extent - image extent) // 2)].
	state == #disabled ifTrue: [
		aCanvas fillRectangle: self bounds fillStyle: color.
		disabledImage ifNotNil: [^ aCanvas translucentImage: disabledImage at: origin]].
	state == #off ifTrue: [
		aCanvas fillRectangle: self bounds fillStyle: color. 
		offImage ifNotNil: [^ aCanvas translucentImage: offImage at: origin]].
	image ifNotNil: [
		aCanvas fillRectangle: self bounds fillStyle: (highLightColor ifNil: [color]). 
		aCanvas translucentImage: image at: origin].
]

{ #category : #accessing }
SugarButton >> enabled [

	self state: #off.

]

{ #category : #'event handling' }
SugarButton >> handlesMouseDown: evt [

	^ state ~~ #disabled.

]

{ #category : #'event handling' }
SugarButton >> handlesMouseOver: evt [

	^ state ~~ #disabled.

]

{ #category : #'event handling' }
SugarButton >> handlesMouseStillDown: evt [

	^ state ~~ #disabled.

]

{ #category : #'event handling' }
SugarButton >> handlesMouseUp: evt [

	^ state ~~ #disabled.

]

{ #category : #accessing }
SugarButton >> highLightColor: aColor [

	highLightColor := aColor.

]

{ #category : #initialization }
SugarButton >> initialize [

	super initialize.
	highLightColor := Color black.
	self setProperty: #wantsHaloFromClick toValue: false.

]

{ #category : #'event handling' }
SugarButton >> mouseDown: evt [

	super mouseDown: evt.
	mouseDownTime := Time millisecondClockValue.
	didMenu := nil.

]

{ #category : #'event handling' }
SugarButton >> mouseEnter: evt [

	self state: #over.

]

{ #category : #'event handling' }
SugarButton >> mouseLeave: evt [

	self state: #off.

]

{ #category : #'event handling' }
SugarButton >> mouseStillDown: evt [

	(mouseDownTime isNil or: [(Time millisecondClockValue - mouseDownTime) abs < 1000]) ifTrue: [
		^super mouseStillDown: evt
	].
	didMenu ifNotNil: [^super mouseStillDown: evt].
	didMenu := target showMenuFor: actionSelector event: evt.

]

{ #category : #'event handling' }
SugarButton >> mouseUp: evt [

	super mouseUp: evt.
	self state: #off.

]

{ #category : #geometry }
SugarButton >> naviHeight: anInteger [

	| imageSize |
	imageSize := image
		ifNotNil: [(anInteger * (image height asFloat / self height)) asInteger]
		ifNil: [(anInteger * 0.6) asInteger].
	imageSize := imageSize@imageSize.

	image ifNotNil: [image := image scaledToSize: imageSize].
	offImage ifNotNil: [offImage := offImage scaledToSize: imageSize].
	pressedImage ifNotNil: [pressedImage := pressedImage scaledToSize: imageSize].
	disabledImage ifNotNil: [disabledImage := disabledImage scaledToSize: imageSize].
	super extent: anInteger@anInteger.

]
