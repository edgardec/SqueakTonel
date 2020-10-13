"
The MarqueeMorph is a subclass of the BorderedMorph which quickly cycles its border color.

The implementation could be simplified and generalized.  The color values and cycle speed are hard-coded for example.
"
Class {
	#name : #MarqueeMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'colors',
		'count'
	],
	#category : #'MorphicExtras-AdditionalWidgets'
}

{ #category : #initialization }
MarqueeMorph >> initialize [

        super initialize.
        colors := {Color red. Color white. Color blue}.
        count := 0
]

{ #category : #'stepping and presenter' }
MarqueeMorph >> step [

        count := count + 1.
        count > colors size ifTrue: [count := 1].
        self borderColor: (colors at: count)
]

{ #category : #'stepping and presenter' }
MarqueeMorph >> stepTime [
        "Answer the desired time between steps in milliseconds."

        ^ 200
]

{ #category : #'stepping and presenter' }
MarqueeMorph >> wantsSteps [

        ^ true
]
