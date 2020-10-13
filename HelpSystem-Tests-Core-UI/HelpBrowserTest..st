Class {
	#name : #HelpBrowserTest,
	#superclass : #TestCase,
	#category : #'HelpSystem-Tests-Core-UI'
}

{ #category : #accessing }
HelpBrowserTest >> defaultTestClass [
	^HelpBrowser
]

{ #category : #tests }
HelpBrowserTest >> testDefaultHelpBrowser [
	
	| current replacement instance |
	current := self defaultTestClass defaultHelpBrowser.
	replacement := AdvancedHelpBrowserDummy.
	[
	  self defaultTestClass defaultHelpBrowser: replacement.
	  self assert: self defaultTestClass defaultHelpBrowser == replacement.
 
	  instance := self defaultTestClass open.
	  self assert: instance rootTopic notNil.
	  self assert: instance isOpen.
	] ensure: [ self defaultTestClass defaultHelpBrowser: current ]
	 
]

{ #category : #tests }
HelpBrowserTest >> testDefaultHelpBrowserIsReplacable [
	
	| current replacement instance |
	"save the one that is registered"
	current := self defaultTestClass defaultHelpBrowser.
	replacement := AdvancedHelpBrowserDummy.
	[
	  self defaultTestClass defaultHelpBrowser: replacement.
	  self assert: self defaultTestClass defaultHelpBrowser == replacement.	  
	  instance := self defaultTestClass open.
	  
	] ensure: [
		self defaultTestClass defaultHelpBrowser: current
	]
	 
]

{ #category : #tests }
HelpBrowserTest >> testLazyDefaultHelpBrowser [
	
	self assert: self defaultTestClass defaultHelpBrowser notNil
]

{ #category : #tests }
HelpBrowserTest >> testOpen [

	| browser |
	[ 
		"This should not throw an exception."
		browser := self defaultTestClass open.
		Project current world doOneCycleNow ]
		ensure: [
			browser ifNotNil: [ browser delete ] ]
]

{ #category : #tests }
HelpBrowserTest >> testRegistration [
	        
	TheWorldMenu registeredOpenCommands detect: [:each | each first = 'Help Browser'] ifNone: [self fail].
	
]
