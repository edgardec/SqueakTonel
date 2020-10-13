"
This is a dummy for a custom Help browser that can be registered as a replacement for the HelpBrowser class.

Instance Variables
	rootTopic:		<HelpTopic>

rootTopic
	- The root help topic

"
Class {
	#name : #AdvancedHelpBrowserDummy,
	#superclass : #Object,
	#instVars : [
		'rootTopic',
		'isOpen'
	],
	#category : #'HelpSystem-Tests-Core-UI'
}

{ #category : #'initialize-release' }
AdvancedHelpBrowserDummy >> initialize [
	isOpen := false
]

{ #category : #testing }
AdvancedHelpBrowserDummy >> isOpen [
	^isOpen
]

{ #category : #accessing }
AdvancedHelpBrowserDummy >> model [
	^self
]

{ #category : #mocking }
AdvancedHelpBrowserDummy >> open [
	isOpen := true
]

{ #category : #mocking }
AdvancedHelpBrowserDummy >> rootTopic [
	^rootTopic
]

{ #category : #mocking }
AdvancedHelpBrowserDummy >> rootTopic: aTopic [
	rootTopic := aTopic
]

{ #category : #mocking }
AdvancedHelpBrowserDummy >> showFirstTopic [
	^rootTopic
]
