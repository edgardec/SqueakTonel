"
See PDA comment. 
"
Class {
	#name : #PDAMorph,
	#superclass : #SystemWindow,
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #'parts bin' }
PDAMorph class >> descriptionForPartsBin [
	^ self partName:	'PDA' translatedNoop
		categories:		#()
		documentation:	'A Personal Digital Assistant' translatedNoop
]

{ #category : #initialization }
PDAMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #initialization }
PDAMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	
	self extent: 406 @ 408.
	PDA new initialize openAsMorphIn: self
]

{ #category : #'parts bin' }
PDAMorph >> initializeToStandAlone [
	super initializeToStandAlone.
	self fullBounds  "seemingly necessary to get its icon right in a parts bin"
]

{ #category : #'stepping and presenter' }
PDAMorph >> step [

	self setLabel: model labelString.  "Super won't step if collapsed"
	super step.
	
]

{ #category : #testing }
PDAMorph >> stepTime [

	^ (60 - Time now seconds + 1) * 1000

]

{ #category : #testing }
PDAMorph >> wantsSteps [

	^ true  "collapsed or not"
]

{ #category : #stepping }
PDAMorph >> wantsStepsWhenCollapsed [
	"Keep time up to date in title bar"

	^ true
]
