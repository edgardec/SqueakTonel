"
Squeak on iOS at last? 

See http://forum.world.st/Squeak-on-iOS-at-last-td4849478.html.

... The proper way to do this (IMHO) would be by implementing an IMM plugin for iOS just like we have for X11 etc. Morphic calls a plugin function whenever a text input field gets focused, which could be used to trigger the keyboard. But AFAIK nobody has gone that route yet, instead relying on the ObjectiveCBridge plugin to call OS functions directly....
"
Class {
	#name : #ImmAbstractPlatform,
	#superclass : #Object,
	#category : #'Multilingual-ImmPlugin'
}

{ #category : #keyboard }
ImmAbstractPlatform >> keyboardFocusForAMorph: aMorph [

	"do nothing"

]
