"
I am the abstract superclass of the Graphic spatial primitives. I represent an ordered sequence of Points. Spatial primitives are used to generate ""trajectories"" such as lines and circles.
"
Class {
	#name : #Path,
	#superclass : #DisplayObject,
	#instVars : [
		'form',
		'collectionOfPoints'
	],
	#category : #'ST80-Paths'
}

{ #category : #examples }
Path class >> example [
	"Creates a Path from mousePoints and displays it several ways on the display screen. Messes up the display. For learning about class Path, just select the code below and execute it to create a path and see it redisplayed in another place on the screen. Each path displays using a different form. A path is indicated by pressing the red mouse button in a sequence; press any other mouse button to terminate. "

	| aPath aForm pl fl flag |
	aForm := Form extent: 2 @ 40.		"creates a form one inch long"
	aForm fillBlack.							"turns it black"
	aPath := Path new.
	aPath form: aForm.						"use the long black form for displaying"
	flag := true.
	[flag]
		whileTrue: 
			[Sensor waitButton.
			Sensor redButtonPressed
				ifTrue: 
					[aPath add: Sensor waitButton.
					Sensor waitNoButton.
					aForm displayOn: Display at: aPath last]
				ifFalse: [flag := false]].
	Display fillWhite.
	aPath displayOn: Display.			"the original path"
	pl := aPath translateBy: 0 @ 100.
	fl := Form extent: 40 @ 40.
	fl fillGray.
	pl form: fl.
	pl displayOn: Display.				"the translated path"
	Sensor waitNoButton

	"Path example"
]

{ #category : #'instance creation' }
Path class >> new [

	^self basicNew initializeCollectionOfPoints
]

{ #category : #'instance creation' }
Path class >> new: anInteger [

	^self basicNew initializeCollectionOfPoints: anInteger
]

{ #category : #adding }
Path >> add: aPoint [ 
	"Include aPoint as one of the receiver's elements."

	^collectionOfPoints add: aPoint
]

{ #category : #accessing }
Path >> at: index [ 
	"Answer the point on the receiver's path at position index."

	^collectionOfPoints at: index
]

{ #category : #accessing }
Path >> at: index put: aPoint [ 
	"Store the argument, aPoint, as the point on the receiver's path at position
	index."

	^collectionOfPoints at: index put: aPoint
]

{ #category : #enumerating }
Path >> collect: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Collect the resulting values into a path that is like the receiver. Answer 
	the new path."

	| newCollection |
	newCollection := collectionOfPoints collect: aBlock.
	newCollection form: self form.
	^newCollection
]

{ #category : #'display box access' }
Path >> computeBoundingBox [ 
	"Refer to the comment in DisplayObject|computeBoundingBox."

	| box |
	box := Rectangle origin: (self at: 1) extent: 0 @ 0.
	collectionOfPoints do: 
		[:aPoint | box swallow: (Rectangle origin: aPoint extent: 0 @ 0)].
	^box
]

{ #category : #displaying }
Path >> displayOn: aDisplayMedium at: aDisplayPoint clippingBox: clipRectangle rule: ruleInteger fillColor: aForm [ 
	"Display this Path--offset by aPoint, clipped by clipRect and the form 
	associated with this Path will be displayedr according to one of the sixteen 
	functions of two logical variables (rule). Also the source form will be first 
	anded with aForm as a mask. Does not effect the state of the Path"

	collectionOfPoints do: 
		[:element | 
		self form
			displayOn: aDisplayMedium
			at: element + aDisplayPoint
			clippingBox: clipRectangle
			rule: ruleInteger
			fillColor: aForm]
]

{ #category : #displaying }
Path >> displayOn: aDisplayMedium transformation: displayTransformation clippingBox: clipRectangle rule: ruleInteger fillColor: aForm [ 
	"Displays this path, translated and scaled by aTransformation. Get the
	scaled and translated Path."

	| newPath transformedPath |
	transformedPath := displayTransformation applyTo: self.
	newPath := Path new.
	transformedPath do: [:point | newPath add: point].
	newPath form: self form.
	newPath
		displayOn: aDisplayMedium
		at: 0 @ 0
		clippingBox: clipRectangle
		rule: ruleInteger
		fillColor: aForm
]

{ #category : #accessing }
Path >> first [
	"Answer the first point on the receiver's path; included to correspond to 
	OrderedCollection protocol."

	^collectionOfPoints first
]

{ #category : #accessing }
Path >> firstPoint [
	"Answer the first point on the receiver's path."

	^collectionOfPoints first
]

{ #category : #accessing }
Path >> firstPoint: aPoint [ 
	"Replace the first element of the receiver with the new value aPoint. 
	Answer the argument aPoint."

	collectionOfPoints at: 1 put: aPoint.
	^aPoint
]

{ #category : #accessing }
Path >> form [
	"Answer the receiver's form, or, if form is nil, then answer a 1 x 1 black 
	form (a black dot)."

	| aForm |
	form == nil
		ifTrue: 
			[aForm := Form extent: 1 @ 1.
			aForm fillBlack.
			^aForm]
		ifFalse: 
			[^form]
]

{ #category : #accessing }
Path >> form: aForm [ 
	"Make the argument, aForm, be the receiver's form."

	form := aForm
]

{ #category : #private }
Path >> initializeCollectionOfPoints [

	collectionOfPoints := OrderedCollection new
]

{ #category : #private }
Path >> initializeCollectionOfPoints: anInteger [

	collectionOfPoints := OrderedCollection new: anInteger
]

{ #category : #testing }
Path >> isEmpty [

	^collectionOfPoints isEmpty
]

{ #category : #accessing }
Path >> last [
	"Answer the last point on the receiver's path; included to correspond to 
	OrderedCollection protocol."

	^collectionOfPoints last
]

{ #category : #accessing }
Path >> offset [
	"There are basically two kinds of display objects in the system: those
	that, when asked to transform themselves, create a new object; and those
	that side effect themselves by maintaining a record of the transformation
	request (typically an offset). Path, like Rectangle and Point, is a display
	object of the first kind."

	self shouldNotImplement
]

{ #category : #removing }
Path >> removeAllSuchThat: aBlock [ 
	"Evaluate aBlock for each element of the receiver.
	Remove each element for which aBlock evaluates to true."

	collectionOfPoints removeAllSuchThat: aBlock.

]

{ #category : #transforming }
Path >> scaleBy: aPoint [ 
	"Answers a new Path scaled by aPoint. Does not affect the current data in 
	this Path."

	| newPath | 
	newPath := self species new: self size. 
	newPath form: self form.
	collectionOfPoints do: [:element | newPath add: (element scaleBy: aPoint)].
	^newPath
]

{ #category : #accessing }
Path >> secondPoint [
	"Answer the second element of the receiver."

	^collectionOfPoints at: 2
]

{ #category : #accessing }
Path >> secondPoint: aPoint [ 
	"Replace the second element of the receiver with the new value aPoint. 
	Answer the argument aPoint."

	collectionOfPoints at: 2 put: aPoint.
	^aPoint
]

{ #category : #enumerating }
Path >> select: aBlock [ 
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Collect into a new path like the receiver only those elements for which 
	aBlock evaluates to true. Answer the new path."

	| newCollection |
	newCollection := collectionOfPoints select: aBlock.
	newCollection form: self form.
	^newCollection
]

{ #category : #accessing }
Path >> size [
	"Answer the length of the receiver."

	^collectionOfPoints size
]

{ #category : #accessing }
Path >> thirdPoint [
	"Answer the third element of the receiver."

	^collectionOfPoints at: 3
]

{ #category : #accessing }
Path >> thirdPoint: aPoint [ 
	"Replace the third element of the receiver with the new value aPoint. 
	Answer the argument aPoint."

	collectionOfPoints at: 3 put: aPoint.
	^aPoint
]

{ #category : #transforming }
Path >> translateBy: aPoint [ 
	"Answers a new Path whose elements are translated by aPoint. Does not
	affect the elements of this Path."

	| newPath |
	newPath := self species new: self size.
	newPath form: self form.
	collectionOfPoints do: [:element | newPath add: (element translateBy: aPoint)].
	^newPath
]
