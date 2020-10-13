"
The Clipboard class implements a basic buffering scheme for text. The currently selected text is also exported to the OS so that text can be copied from and to other applications. Commonly only a single instance is used (the default clipboard) but applications are free to use other than the default clipboard if necessary.

If you'd like to be notified of the changes of the clipboard, you can subscribe to its #contentChanged event. For example:

subscriber := [ :newClipboardText :updateSource | 
	Transcript show: ('Clipboard was updated by {1}, the new content is: {2}'
		format: {
			updateSource.
			newClipboardText }); cr ].
Clipboard default
	when: #contentChanged
	send: #value:value:
	to: subscriber.

At this point if you open a Transcript and copy or cut some text, then the message will appear on the Transcript. Make sure that there's a reference kept to subscriber, otherwise it will be garbage collected and no messages will appear.
	
To unsubscribe from the clipboard changes, just evaluate:

Clipboard default removeActionsWithReceiver: subscriber
"
Class {
	#name : #Clipboard,
	#superclass : #Object,
	#instVars : [
		'contents',
		'recent',
		'interpreter'
	],
	#classVars : [
		'Default'
	],
	#category : #'System-Support'
}

{ #category : #accessing }
Clipboard class >> chooseRecentClipping [  "Clipboard chooseRecentClipping"
	"Choose by menu from among the recent clippings"
	^self default chooseRecentClipping
]

{ #category : #'initialize-release' }
Clipboard class >> cleanUp: aggressive [

	aggressive ifTrue: [self default reset].
]

{ #category : #'class initialization' }
Clipboard class >> clearInterpreters [

	self allInstances do: [:each | each clearInterpreter].

]

{ #category : #accessing }
Clipboard class >> clipboardText [ "Clipboard clipboardText"
	^self default clipboardText.
]

{ #category : #accessing }
Clipboard class >> clipboardText: aText [ 
	^self default clipboardText: aText
]

{ #category : #accessing }
Clipboard class >> default [
	^Default ifNil:[Default := self new].
]

{ #category : #accessing }
Clipboard class >> default: aClipboard [
	"So that clients can switch between different default clipboards"
	Default := aClipboard.
]

{ #category : #'class initialization' }
Clipboard class >> localeChanged [
	self startUp.
]

{ #category : #'class initialization' }
Clipboard class >> startUp [

	self clearInterpreters.

]

{ #category : #accessing }
Clipboard >> chooseRecentClipping [  "Clipboard chooseRecentClipping"
	"Choose by menu from among the recent clippings"

	recent ifNil: [^ nil].
	^ UIManager default
		chooseFrom: (recent collect: [:txt | ((txt asString contractTo: 50)
									copyReplaceAll: Character cr asString with: '\')
									copyReplaceAll: Character tab asString with: '|'])
		values: recent
]

{ #category : #accessing }
Clipboard >> clearInterpreter [

	interpreter := nil.

]

{ #category : #accessing }
Clipboard >> clipboardText [
	"Return the text currently in the clipboard. If the system clipboard is empty, or if it differs from the Smalltalk clipboard text, use the Smalltalk clipboard. This is done since (a) the Mac clipboard gives up on very large chunks of text and (b) since not all platforms support the notion of a clipboard."

	| string decodedString |
	string := self primitiveClipboardText withSqueakLineEndings.
	(string isEmpty
			or: [string = contents asString])
		ifTrue: [^ contents].
	decodedString := self interpreter fromSystemClipboard: string.
	^ decodedString = contents asString 
		ifTrue: [contents]
		ifFalse: [decodedString asText].

]

{ #category : #accessing }
Clipboard >> clipboardText: text [ 

	self clipboardText: text notifyWith: nil
]

{ #category : #accessing }
Clipboard >> clipboardText: text notifyWith: anObject [
	"Set the contents of the clipboard to text. anObject can be used as a marker for the source of the clipboard change, the default value is nil."

	| string |
	string := text asString.
	self noteRecentClipping: text asText.
	contents := text asText.
	string := self interpreter toSystemClipboard: string.
	self primitiveClipboardText: string.
	self triggerEvent: #contentChanged withArguments: { text. anObject }
]

{ #category : #initialize }
Clipboard >> initialize [

	super initialize.
	self reset.
]

{ #category : #accessing }
Clipboard >> interpreter [

	interpreter ifNil: [self setInterpreter].
	^ interpreter.

]

{ #category : #private }
Clipboard >> noteRecentClipping: text [
	"Keep most recent clippings in a queue for pasteRecent (paste... command)"
	text isEmpty ifTrue: [^ self].
	text size > 50000 ifTrue: [^ self].
	(recent includes: text) ifTrue: [^ self].
	recent addFirst: text.
	[recent size > 5] whileTrue: [recent removeLast].

]

{ #category : #primitives }
Clipboard >> primitiveClipboardText [
	"Get the current clipboard text. Return the empty string if the primitive fails."
	<primitive: 141>
	^ ''
]

{ #category : #primitives }
Clipboard >> primitiveClipboardText: aString [
	"Set the current clipboard text to the given string."

	<primitive: 141>
	"don't fail if the primitive is not implemented"
]

{ #category : #initialize }
Clipboard >> reset [
	"Prepare or clean-up internal buffers, but keep external (or host) clipboard as is."

	contents := '' asText.
	recent := OrderedCollection new.
]

{ #category : #accessing }
Clipboard >> setInterpreter [

	interpreter := LanguageEnvironment defaultClipboardInterpreter.
	interpreter ifNil: [
		"Should never be reached, but just in case."
		interpreter := NoConversionClipboardInterpreter new].

]
