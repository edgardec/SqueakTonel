"
A composite user interface element.

Instance variables:
	children	<Symbol|Collection>	Symbol to retrieve children or children directly
	layout	<Symbol> The layout for this composite.

"
Class {
	#name : #PluggableCompositeSpec,
	#superclass : #PluggableWidgetSpec,
	#instVars : [
		'children',
		'layout',
		'wantsResizeHandles',
		'spacing'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #accessing }
PluggableCompositeSpec >> children [
	"Answer the selector to retrieve this panel's children"
	^children
]

{ #category : #accessing }
PluggableCompositeSpec >> children: aSymbol [
	"Indicate the selector to retrieve this panel's children"
	children := aSymbol
]

{ #category : #accessing }
PluggableCompositeSpec >> layout [
	"Answer the symbol indicating the layout of the composite:
		#proportional (default): Use frames as appropriate.
		#horizontal: Arrange the elements horizontally
		#vertical: Arrange the elements vertically.
	"
	^layout ifNil:[#proportional]
]

{ #category : #accessing }
PluggableCompositeSpec >> layout: aSymbol [
	"Answer the symbol indicating the layout of the composite:
		#proportional (default): Use frames as appropriate.
		#horizontal: Arrange the elements horizontally
		#vertical: Arrange the elements vertically.
	"
	layout := aSymbol
]

{ #category : #'layout hints' }
PluggableCompositeSpec >> spacing [
	"...between components of this widget."
	
	^ spacing
]

{ #category : #'layout hints' }
PluggableCompositeSpec >> spacing: numberOrPoint [

	spacing := numberOrPoint.
]

{ #category : #accessing }
PluggableCompositeSpec >> wantsResizeHandles [

	^ wantsResizeHandles
]

{ #category : #accessing }
PluggableCompositeSpec >> wantsResizeHandles: aBoolean [

	wantsResizeHandles := aBoolean.
]
