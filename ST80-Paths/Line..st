"
I represent the line segment specified by two points.
"
Class {
	#name : #Line,
	#superclass : #Path,
	#category : #'ST80-Paths'
}

{ #category : #examples }
Line class >> example [
	"Designate two places on the screen by clicking any mouse button. A
	straight path with a square black form will be displayed connecting the
	two selected points."

	| aLine aForm |  
	aForm := Form extent: 20@20.		"make a form one quarter of inch square"
	aForm fillBlack.							"turn it black"
	aLine := Line new.
	aLine form: aForm.						"use the black form for display"
	aLine beginPoint: Sensor waitButton. Sensor waitNoButton.
	aForm displayOn: Display at: aLine beginPoint.	
	aLine endPoint: Sensor waitButton.
	aLine displayOn: Display.				"display the line"

	"Line example"
]

{ #category : #'instance creation' }
Line class >> from: beginPoint to: endPoint withForm: aForm [ 
	"Answer an instance of me with end points begingPoint and endPoint; 
	the source form for displaying the line is aForm."

	| newSelf | 
	newSelf := super new: 2.
	newSelf add: beginPoint.
	newSelf add: endPoint.
	newSelf form: aForm.
	^newSelf
]

{ #category : #'instance creation' }
Line class >> new [

	| newSelf | 
	newSelf := super new: 2.
	newSelf add: 0@0.
	newSelf add: 0@0.
	^newSelf
]

{ #category : #accessing }
Line >> beginPoint [
	"Answer the first end point of the receiver."

	^self first
]

{ #category : #accessing }
Line >> beginPoint: aPoint [ 
	"Set the first end point of the receiver to be the argument, aPoint. 
	Answer aPoint."

	self at: 1 put: aPoint.
	^aPoint
]

{ #category : #displaying }
Line >> displayOn: aDisplayMedium at: aPoint clippingBox: clipRect rule: anInteger fillColor: aForm [ 
	"The form associated with this Path will be displayed, according  
	to one of the sixteen functions of two logical variables (rule), at  
	each point on the Line. Also the source form will be first anded  
	with aForm as a mask. Does not effect the state of the Path."

	collectionOfPoints size < 2 ifTrue: [self error: 'a line must have two points'].
	aDisplayMedium
		drawLine: self form
		from: self beginPoint + aPoint
		to: self endPoint + aPoint
		clippingBox: clipRect
		rule: anInteger
		fillColor: aForm
]

{ #category : #displaying }
Line >> displayOn: aDisplayMedium transformation: aTransformation clippingBox: clipRect rule: anInteger fillColor: aForm [

	| newPath newLine |
	newPath := aTransformation applyTo: self.
	newLine := Line new.
	newLine beginPoint: newPath firstPoint.
	newLine endPoint: newPath secondPoint.
	newLine form: self form.
	newLine
		displayOn: aDisplayMedium
		at: 0 @ 0
		clippingBox: clipRect
		rule: anInteger
		fillColor: aForm
]

{ #category : #displaying }
Line >> displayOnPort: aPort at: aPoint [ 
	aPort sourceForm: self form; combinationRule: Form under; fillColor: nil.
	aPort drawFrom: collectionOfPoints first + aPoint
		to: collectionOfPoints last + aPoint
]

{ #category : #accessing }
Line >> endPoint [
	"Answer the last end point of the receiver."

	^self last
]

{ #category : #accessing }
Line >> endPoint: aPoint [ 
	"Set the first end point of the receiver to be the argument, aPoint. 
	Answer aPoint."

	self at: 2 put: aPoint.
	^aPoint
]
