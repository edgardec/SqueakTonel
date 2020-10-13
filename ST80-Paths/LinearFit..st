"
I represent a piece-wise linear approximation to a set of points in the plane.
"
Class {
	#name : #LinearFit,
	#superclass : #Path,
	#category : #'ST80-Paths'
}

{ #category : #examples }
LinearFit class >> example [
	"Select points on a Path using the red button. Terminate by selecting
	any other button. Creates a Path from the points and displays it as a
	piece-wise linear approximation." 

	| aLinearFit aForm flag |
	aLinearFit := LinearFit new.
	aForm := Form extent: 1 @ 40.
	aForm  fillBlack.
	aLinearFit form: aForm.
	flag := true.
	[flag] whileTrue:
		[Sensor waitButton.
		 Sensor redButtonPressed
			ifTrue: [aLinearFit add: Sensor waitButton. Sensor waitNoButton.
					aForm displayOn: Display at: aLinearFit last]
			ifFalse: [flag:=false]].
	aLinearFit displayOn: Display

	"LinearFit example"
]

{ #category : #displaying }
LinearFit >> displayOn: aDisplayMedium at: aPoint clippingBox: clipRect rule: anInteger
fillColor: aForm [
 
	| line |
	line := Line new.
	line form: self form.
	1 to: self size - 1 do: 
		[:i | 
		line beginPoint: (self at: i).
		line endPoint: (self at: i + 1).
		line displayOn: aDisplayMedium
			at: aPoint
			clippingBox: clipRect
			rule: anInteger
			fillColor: aForm]
]

{ #category : #displaying }
LinearFit >> displayOn: aDisplayMedium transformation: aTransformation clippingBox:
clipRect rule: anInteger fillColor: aForm [ 

	| transformedPath |
	"get the scaled and translated Path."
	transformedPath := aTransformation applyTo: self.
	transformedPath
		displayOn: aDisplayMedium
		at: 0 @ 0
		clippingBox: clipRect
		rule: anInteger
		fillColor: aForm
]
