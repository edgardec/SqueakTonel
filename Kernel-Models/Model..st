"
Provides a superclass for classes that function as models.  The only behavior provided is fast dependents maintenance, which bypasses the generic DependentsFields mechanism.  1/23/96 sw
"
Class {
	#name : #Model,
	#superclass : #Object,
	#instVars : [
		'dependents'
	],
	#classVars : [
		'UseColorfulWindows',
		'WindowActiveOnFirstClick'
	],
	#category : #'Kernel-Models'
}

{ #category : #toolbuilder }
Model class >> buildWith: toolBuilder [
	^self new buildWith: toolBuilder
]

{ #category : #preferences }
Model class >> themeProperties [

	^ {
		{ #uniformWindowColor. 'Colors'. 'The color to be used when all windows should have the same color' }.
		{ #customWindowColor. 'Colors'. 'The color to be used when all windows can have their own color' }.
	}
]

{ #category : #preferences }
Model class >> useColorfulWindows [
	<preference: 'Use colorful windows'
		categoryList: #(Morphic windows)
		description: 'When true, windows have colors specific to their kind.'
		type: #Boolean>
	^UseColorfulWindows ifNil:[true]
]

{ #category : #preferences }
Model class >> useColorfulWindows: aBoolean [

	UseColorfulWindows = aBoolean ifTrue: [^ self].
	UseColorfulWindows := aBoolean.

	(Smalltalk classNamed: #SystemWindow) ifNotNil: [:c | c refreshAllWindows].
	(Smalltalk classNamed: #TheWorldMainDockingBar) ifNotNil: [:c | c updateInstances].
]

{ #category : #preferences }
Model class >> windowActiveOnFirstClick [
	<preference: 'Windows'' Contents Are Always Active'
		category: 'windows'
		description: 'When enabled, the widgets of background windows are sensitive to mouse input. When disabled, clicking background window will only make it the active window, without changing, for example, selections in lists or text fields.'
		type: #Boolean>
		
	^ WindowActiveOnFirstClick ifNil: [ false ]
]

{ #category : #preferences }
Model class >> windowActiveOnFirstClick: aBoolean [

	WindowActiveOnFirstClick := aBoolean.
	(Smalltalk classNamed: #SystemWindow) ifNotNil: [:c | c reconfigureWindowsForFocus].
]

{ #category : #'morphic ui' }
Model >> aboutToStyle: aStyler [
	"Default implementation for text styling. No changes in styler configuration but we are OK to style our contents."

	^ true
]

{ #category : #'morphic ui' }
Model >> aboutToStyle: aStyler requestor: anObject [
	"View-specific extension for styling. Overwrite this method to configure the styler with view-specific information."

	^ self aboutToStyle: aStyler
]

{ #category : #'morphic ui' }
Model >> applyUserInterfaceTheme [

	self dependents do: [:ea |
		ea isSystemWindow ifTrue: [
			ea refreshWindowColor]].
]

{ #category : #toolbuilder }
Model >> buildWindowWith: builder [
	| windowSpec |
	windowSpec := builder pluggableWindowSpec new.
	windowSpec model: self.
	windowSpec label: #windowTitle.
	windowSpec children: OrderedCollection new.
	^windowSpec
]

{ #category : #toolbuilder }
Model >> buildWindowWith: builder specs: specs [
	| windowSpec |
	windowSpec := self buildWindowWith: builder.
	specs do:[:assoc|
		| rect action widgetSpec |
		rect := assoc key.
		action := assoc value.
		widgetSpec := action value.
		widgetSpec ifNotNil:[
			widgetSpec frame: rect.
			windowSpec children add: widgetSpec]].
	^windowSpec
]

{ #category : #'morphic ui' }
Model >> canApplyUserInterfaceTheme [
	^ self dependents notEmpty
]

{ #category : #dependents }
Model >> canDiscardEdits [
	"Answer true if none of the views on this model has unaccepted edits that matter."

	dependents ifNil: [^ true].
	^ super canDiscardEdits

]

{ #category : #dependents }
Model >> containingWindow [
	"Answer the window that holds the receiver.  The dependents technique is odious and may not be airtight, if multiple windows have the same model."

	^ self dependents detect:
		[:d | d isWindowForModel: self] ifNone: [nil]
]

{ #category : #dependents }
Model >> hasUnacceptedEdits [
	"Answer true if any of the views on this model has unaccepted edits."

	dependents == nil ifTrue: [^ false].
	^ super hasUnacceptedEdits

]

{ #category : #toolbuilder }
Model >> labelString [
	"We'd love to sunset this in favour of #windowTitle but there are so many places that would need changing that it really seems more trouble than could possibly be warranted"
	^self class name
]

{ #category : #dependents }
Model >> myDependents [
	^ dependents
]

{ #category : #dependents }
Model >> myDependents: aCollectionOrNil [
	dependents := aCollectionOrNil
]

{ #category : #'morphic ui' }
Model >> postAcceptBrowseFor: anotherModel [ 
	"If I am taking over browsing for anotherModel, sucblasses may override to, for example, position me to the object to be focused on."
]

{ #category : #copying }
Model >> postCopy [

	super postCopy.
	self breakDependents.
]

{ #category : #'morphic ui' }
Model >> representsSameBrowseeAs: anotherModel [
	"Answer true if my browser can browse what anotherModel wants to browse."
	^ false
]

{ #category : #dependents }
Model >> topView [
	"Find the first top view on me. Is there any danger of their being two with the same model?  Any danger from ungarbage collected old views?  Ask if schedulled?"

	dependents ifNil: [^nil].
	dependents do: [:d| (d isWindowForModel: self) ifTrue:[^d]].
	^nil
]

{ #category : #copying }
Model >> veryDeepFixupWith: deepCopier [ 
	"See if the dependents are being copied also.  If so, point at the new copies.  (The dependent has self as its model.)
	Dependents handled in class Object, when the model is not a Model, are fixed up in Object veryDeepCopy."

	| originalDependents refs |
	super veryDeepFixupWith: deepCopier.
	originalDependents := dependents.
	originalDependents ifNil: [
		^self.
		].
	dependents := nil.
	refs := deepCopier references.
	originalDependents
		do: [:originalDependent | | newDependent | 
			newDependent := refs
						at: originalDependent
						ifAbsent: [].
			newDependent
				ifNotNil: [self addDependent: newDependent]]
]

{ #category : #copying }
Model >> veryDeepInner: deepCopier [
	"Shallow copy dependents and fix them later"

]

{ #category : #'user interface' }
Model >> windowActiveOnFirstClick [

	^ self class windowActiveOnFirstClick
]

{ #category : #toolbuilder }
Model >> windowTitle [
	"We'd rather use windowTitle but labelString is deeply embedded; see its comment"
	^self labelString
]
