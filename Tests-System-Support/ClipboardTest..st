Class {
	#name : #ClipboardTest,
	#superclass : #TestCase,
	#instVars : [
		'originalClipboardText'
	],
	#category : #'Tests-System-Support'
}

{ #category : #running }
ClipboardTest >> setUp [
	"Store the contents of the default clipboard. This is necessary, because all Clipboard instances modify the contents of the system clipboard."

	originalClipboardText := Clipboard default clipboardText
]

{ #category : #running }
ClipboardTest >> tearDown [
	"Restore the contents of the default clipboard. This is necessary, because all Clipboard instances modify the contents of the system clipboard."

	Clipboard default clipboardText: originalClipboardText
]

{ #category : #tests }
ClipboardTest >> testClipboardText [

	| uuidString clipboard |
	uuidString := UUID new asString36.
	clipboard := Clipboard new.
	clipboard clipboardText: uuidString.
	self assert: uuidString equals: clipboard clipboardText asString
]

{ #category : #tests }
ClipboardTest >> testClipboardTextNotifyWith [

	| uuidString clipboard subscriber notifiedText notifiedSource |
	uuidString := UUID new asString36.
	clipboard := Clipboard new.
	subscriber := [ :text :source | 
		notifiedText := text.
		notifiedSource := source ].
	clipboard 
		when: #contentChanged
		send: #value:value:
		to: subscriber.
	clipboard clipboardText: uuidString.
	self
		assert: uuidString equals: notifiedText;
		assert: nil equals: notifiedSource.
	clipboard clipboardText: uuidString reversed notifyWith: self.
	self
		assert: uuidString reversed equals: notifiedText;
		assert: self == notifiedSource.
	clipboard removeActionsWithReceiver: subscriber.
	clipboard clipboardText: uuidString.
	self
		assert: uuidString reversed equals: notifiedText;
		assert: self == notifiedSource
]
