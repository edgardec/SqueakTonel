Class {
	#name : #PluggableTextMorphTest,
	#superclass : #TestCase,
	#instVars : [
		'widget',
		'model'
	],
	#category : #'MorphicTests-Widgets'
}

{ #category : #running }
PluggableTextMorphTest >> setUp [

	super setUp.
	
	model := ValueHolder new contents: ''; yourself.
	widget := PluggableTextMorph on: model text: #contents accept: #contents:.
]

{ #category : #tests }
PluggableTextMorphTest >> test01TextChangeInModel [

	model contents: 'Hello, World!'.
	self assert: model contents equals: widget text asString.
]

{ #category : #tests }
PluggableTextMorphTest >> test02TextChangeInWidget [

	widget replaceSelectionWith: 'Hello, World!'.
	self assert: '' equals: model contents.
	
	widget accept.
	self assert: widget text asString equals: model contents asString.
]

{ #category : #tests }
PluggableTextMorphTest >> test03TriggerAcceptFromModel [

	widget replaceSelectionWith: 'Hello, World!'.
	self assert: widget hasUnacceptedEdits.
	
	model changed: #acceptChanges.
	self assert: widget text asString equals: model contents asString.
]

{ #category : #tests }
PluggableTextMorphTest >> test04TriggerAcceptFromWidget [

	widget replaceSelectionWith: 'Hello, World!'.
	self assert: widget hasUnacceptedEdits.
	
	widget accept.
	self assert: widget text asString equals: model contents asString.
]
