"
I am an inspector that also shows all messages the inspected objects can understand. I combine inspector and code browser.

InspectorBrowser openOn: Smalltalk
"
Class {
	#name : #InspectorBrowser,
	#superclass : #Model,
	#instVars : [
		'inspector',
		'browser'
	],
	#category : #'Tools-Inspector'
}

{ #category : #'inspector compatibility' }
InspectorBrowser class >> basicInspect: anObject [ 
	"ToolBuilder open: (self basicInspect: Morph new)"
	
	^ self new
		setInspectorClass: BasicInspector;
		object: anObject;
		yourself
]

{ #category : #'inspector compatibility' }
InspectorBrowser class >> inspect: anObject [ 
	"ToolBuilder open: (self inspect: 42)"

	^ self new inspect: anObject
]

{ #category : #'instance creation' }
InspectorBrowser class >> on: anObject [ 
	"We have to call #inspect: instead of #object: to choose the correct #inspectorClass."
	
	^ self new inspect: anObject
]

{ #category : #'instance creation' }
InspectorBrowser class >> openOn: anObject [

	^ ToolBuilder open: (self on: anObject)
]

{ #category : #'instance creation' }
InspectorBrowser class >> openOn: anObject withLabel: label [

	^ ToolBuilder open: (self on: anObject) label: label
]

{ #category : #toolbuilder }
InspectorBrowser >> buildWith: builder [

	| windowSpec |
	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 0.3@0.3) -> [inspector buildFieldListWith: builder].
		(0.3@0 corner: 1.0@0.3) -> [inspector buildValuePaneWith: builder].
		(0@0.3 corner: 0.3@1.0) -> [browser buildMessageListWith: builder].
		(0.3@0.3 corner: 1.0@1.0) -> [browser buildCodePaneWith: builder].
	}.
	^ builder build: windowSpec
]

{ #category : #initialization }
InspectorBrowser >> initialExtent [

	^ (inspector initialExtent x max: browser initialExtent x)
		@ ((inspector initialExtent y * 2/3) + browser initialExtent y)
]

{ #category : #initialization }
InspectorBrowser >> initialize [

	super initialize.
	
	self setInspectorClass: Inspector.
	self setBrowserClass: Browser.
]

{ #category : #initialization }
InspectorBrowser >> inspect: anObject [
	"Reinitialize the inspector so that it is inspecting anObject."

	inspector inspect: anObject.
	browser setClass: anObject class.
]

{ #category : #toolbuilder }
InspectorBrowser >> labelString [
	"The window title"

	^ 'Inspector Browser: ', inspector labelString
]

{ #category : #stepping }
InspectorBrowser >> modelWakeUpIn: aWindow [

	inspector modelWakeUpIn: aWindow.
	browser modelWakeUpIn: aWindow.
]

{ #category : #accessing }
InspectorBrowser >> object [

	^ inspector object
]

{ #category : #accessing }
InspectorBrowser >> object: anObject [
	"Set anObject to be the object being inspected by the receiver."

	inspector object: anObject.
	browser setClass: anObject class.
]

{ #category : #initialization }
InspectorBrowser >> setBrowserClass: aClass [

	browser := aClass new.
]

{ #category : #initialization }
InspectorBrowser >> setInspectorClass: aClass [

	inspector := aClass new.
	inspector addDependent: self.
]

{ #category : #stepping }
InspectorBrowser >> stepAt: millisecondClockValue in: aWindow [
	
	inspector stepAt: millisecondClockValue in: aWindow.
	browser stepAt: millisecondClockValue in: aWindow.
]

{ #category : #stepping }
InspectorBrowser >> stepTimeIn: aWindow [

	^ (inspector stepTimeIn: aWindow)
		max: (browser stepTimeIn: aWindow)
]

{ #category : #updating }
InspectorBrowser >> update: anAspect [
	"When the inspector exchanges the object-under-inspection, reset the class of my browser."
	
	anAspect = #object ifTrue: [
		browser setClass: inspector object class].
	anAspect = #windowTitle ifTrue: [
		self changed: #windowTitle].
	super update: anAspect.
]

{ #category : #stepping }
InspectorBrowser >> updateListsAndCodeIn: aWindow [

	inspector updateListsAndCodeIn: aWindow.
	browser updateListsAndCodeIn: aWindow.
]

{ #category : #stepping }
InspectorBrowser >> wantsStepsIn: aWindow [

	^ (inspector wantsStepsIn: aWindow)
		or: [browser wantsStepsIn: aWindow]
]
