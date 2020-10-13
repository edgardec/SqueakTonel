Class {
	#name : #RcsDiff,
	#superclass : #Object,
	#instVars : [
		'commandLines'
	],
	#category : #'SMBase-utilities'
}

{ #category : #'instance creation' }
RcsDiff class >> lines: aString [
	"Create a new RcsDiff file."
	^(self new) commandLines: aString; yourself
]

{ #category : #applying }
RcsDiff >> applyTo: aString [
	"Apply me to given String and return the patched String."

	| space commandStream originalStream currentLine |
	space := Character space.
	commandStream := ReadStream on: commandLines.
	originalStream := ReadStream on: aString.
	currentLine := 1.
	^String streamContents: [:stream |
		| nextCommand |
		[nextCommand := commandStream next.
		nextCommand isNil] whileFalse: [ 
			| nextLine lineCount |
			nextLine := (commandStream upTo: space) asNumber.
			lineCount := commandStream nextLine asNumber.
			[currentLine = nextLine]
				whileFalse: [stream nextPutAll: originalStream nextLine; cr. currentLine := currentLine + 1].
			nextCommand = $d
				ifTrue:[ lineCount timesRepeat: [originalStream nextLine. currentLine := currentLine + 1]]
				ifFalse:[ nextCommand = $a
							ifTrue:[ stream nextPutAll: originalStream nextLine; cr.
									currentLine := currentLine + 1.
									lineCount timesRepeat: [
										stream nextPutAll: commandStream nextLine; cr]]]].
		stream nextPutAll: originalStream upToEnd]
]

{ #category : #accessing }
RcsDiff >> commandLines: aString [
	commandLines := aString
]
