"
A morph that always displays the current contents of the text clipboard.
"
Class {
	#name : #ClipboardMorph,
	#superclass : #TextMorph,
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #'parts bin' }
ClipboardMorph class >> descriptionForPartsBin [
	^ self partName:	'Clipboard' translatedNoop
		categories:		#()
		documentation:	'This object will always show whatever is on the text clipboard' translatedNoop
]

{ #category : #initialization }
ClipboardMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color
		r: 1.0
		g: 0.355
		b: 0.452
]

{ #category : #initialization }
ClipboardMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 6
]

{ #category : #initialization }
ClipboardMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color blue
]

{ #category : #'parts bin' }
ClipboardMorph >> initializeToStandAlone [
	super initializeToStandAlone.
""
	self initialize.
	""
	self extent: 200 @ 100.
	self
		backgroundColor: (Color
				r: 0.484
				g: 1.0
				b: 0.484).
	self setBalloonText: 'This shows the current contents of the text clipboard'.
	self newContents: Clipboard clipboardText
]

{ #category : #'stepping and presenter' }
ClipboardMorph >> step [
	self newContents: Clipboard clipboardText
]

{ #category : #testing }
ClipboardMorph >> stepTime [
	"Answer the interval between steps -- in this case a leisurely 1 seconds"

	^ 1000
]

{ #category : #testing }
ClipboardMorph >> wantsSteps [
	^ true
]
