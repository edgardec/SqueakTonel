Class {
	#name : #ScrollPaneTest,
	#superclass : #TestCase,
	#instVars : [
		'sut',
		'content'
	],
	#category : #'MorphicTests-Widgets'
}

{ #category : #running }
ScrollPaneTest >> refresh [
	
	sut fullBounds.		
]

{ #category : #running }
ScrollPaneTest >> scrollToBottomRight [

	sut hScrollBar setValue: sut hScrollBar maximumValue.
	sut vScrollBar setValue: sut vScrollBar maximumValue.
]

{ #category : #running }
ScrollPaneTest >> scrollToTopLeft [

	sut
		hScrollBarValue: 0;
		vScrollBarValue: 0;
		setScrollDeltas.
]

{ #category : #running }
ScrollPaneTest >> setUp [

	super setUp.
	sut := ScrollPane new.
	sut
		retractable: false;
		scrollBarOnLeft: false;
		extent: 100@100;
		borderWidth: 0; "Very important for the math in tests!"
		hScrollBarPolicy: #whenNeeded;
		vScrollBarPolicy: #whenNeeded.
	content := Morph new.
	sut scroller addMorph: content.
]

{ #category : #tests }
ScrollPaneTest >> test00SetUp [

	self assert: 100@100 equals: sut extent.
]

{ #category : #tests }
ScrollPaneTest >> test01ScrollBarPolicyWhenNeeded [

	sut extent: 125@125.

	sut
		hScrollBarPolicy: #whenNeeded;
		vScrollBarPolicy: #whenNeeded.
		
	content extent: 100@100.
	self refresh.
	
	self
		deny: sut hIsScrollbarShowing;
		deny: sut vIsScrollbarShowing.

	content extent: 125@125.
	self refresh.
	
	self
		deny: sut hIsScrollbarShowing;
		deny: sut vIsScrollbarShowing.
			
	content extent: 150@150.
	self refresh.

	self
		assert: sut hIsScrollbarShowing;
		assert: sut vIsScrollbarShowing.
		
	content extent: 125@125.
	self refresh.
	
	self
		deny: sut hIsScrollbarShowing;
		deny: sut vIsScrollbarShowing.
]

{ #category : #tests }
ScrollPaneTest >> test02ScrollBarPolicyAlways [

	sut
		hScrollBarPolicy: #always;
		vScrollBarPolicy: #always.
		
	content extent: 50@50.
	self refresh.
	
	self
		assert: sut hIsScrollbarShowing;
		assert: sut vIsScrollbarShowing.
		
	content extent: 150@150.
	self refresh.

	self
		assert: sut hIsScrollbarShowing;
		assert: sut vIsScrollbarShowing.
]

{ #category : #tests }
ScrollPaneTest >> test03ScrollBarPolicyNever [

	sut
		hScrollBarPolicy: #never;
		vScrollBarPolicy: #never.
		
	content extent: 50@50.
	self refresh.
	
	self
		deny: sut hIsScrollbarShowing;
		deny: sut vIsScrollbarShowing.
		
	content extent: 150@150.
	self refresh.

	self
		deny: sut hIsScrollbarShowing;
		deny: sut vIsScrollbarShowing.
]

{ #category : #tests }
ScrollPaneTest >> test04ScrollingCallIn [

	content extent: 200@200.
	self refresh.
	
	self
		assert: 0 equals: sut hScrollBar value;
		assert: 0 equals: sut vScrollBar value;
		assert: 0@0 equals: sut scroller offset.
		
	sut hScrollBar setValue: 50.
	sut vScrollBar setValue: 50.

	self
		assert: 50 equals: sut hScrollBar value;
		assert: 50 equals: sut vScrollBar value;
		assert: 50@50 equals: sut scroller offset.

]

{ #category : #tests }
ScrollPaneTest >> test05ScrollingCallOut [
	"There is no automatic call-out from pane to scroll bars yet."
	
	content extent: 200@200.
	self refresh.
	
	self
		assert: 0 equals: sut hScrollBar value;
		assert: 0 equals: sut vScrollBar value;
		assert: 0@0 equals: sut scroller offset.
		
	sut hScrollBarValue: 50.
	sut vScrollBarValue: 50.

	self
		assert: 0 equals: sut hScrollBar value;
		assert: 0 equals: sut vScrollBar value;
		assert: 50@50 equals: sut scroller offset.
	
	sut hSetScrollDelta.
	sut vSetScrollDelta.
	
	self
		assert: 50 equals: sut hScrollBar value;
		assert: 50 equals: sut vScrollBar value.
]

{ #category : #tests }
ScrollPaneTest >> test06ScrollRanges [
	
	content extent: 200@300.
	self refresh.
	
	self
		assert: 200 equals: sut hTotalScrollRange;
		assert: 300 equals: sut vTotalScrollRange;
		assert: 100 equals: sut hLeftoverScrollRange - sut scrollBarThickness;
		assert: 200 equals: sut vLeftoverScrollRange - sut scrollBarThickness.

	sut hScrollBarValue: 50.
	sut vScrollBarValue: 30.
	
	"Scrolling does not affect the scroll ranges."
	self
		assert: 200 equals: sut hTotalScrollRange;
		assert: 300 equals: sut vTotalScrollRange;
		assert: 100 equals: sut hLeftoverScrollRange - sut scrollBarThickness;
		assert: 200 equals: sut vLeftoverScrollRange - sut scrollBarThickness.

]

{ #category : #tests }
ScrollPaneTest >> test07GuardOffsets [
	"Scroll bars will never report negative values because they have 0 as minimum. Programmatic access, however, might provide those. Visual appearance should not break then."
	
	content extent: 200@300.
	self refresh.

	sut hScrollBarValue: -10.
	sut vScrollBarValue: -20.
	
	self assert: 0@0 equals: sut scroller offset.
]

{ #category : #tests }
ScrollPaneTest >> test08ScrollToShow [

	content extent: 300@300.
	self refresh.
	
	"1a) Scroll down/right to show bottom right corner."
	self scrollToTopLeft.
	sut scrollToShow: (50@50 corner: 100@100).
	self assert: (sut scrollBarThickness @ sut scrollBarThickness) equals: sut scroller offset.
	
	"1b) Scroll up/left to show top left corner."
	self scrollToBottomRight.
	sut scrollToShow: (100@100 corner: 150@150).
	self assert: 100@100 equals: sut scroller offset.

	"2a) Too big, so show bottom right corner because we scroll down/right."
	self scrollToTopLeft.
	sut scrollToShow: (0@0 corner: 100@100).
	self assert: (sut scrollBarThickness @ sut scrollBarThickness) equals: sut scroller offset.

	"2b) Too big, so show top left corner because we scroll up/left."
	self scrollToBottomRight.
	sut scrollToShow: (50@50 corner: 150@150).
	self assert: 50@50 equals: sut scroller offset.

	"3) No negative offsets."
	self scrollToTopLeft.
	sut scrollToShow: (-10 @ -10 corner: 50@50).
	self assert: 0@0 equals: sut scroller offset.
]

{ #category : #tests }
ScrollPaneTest >> test09HideShowTransition [

	content extent: 300@300.
	self refresh.

	"1) Horizontal bar not needed anymore."
	sut extent: 100@100.
	sut vScrollBar setValue: 50.
	sut width: content width + sut vScrollBar width.
	self assert: sut vLeftoverScrollRange equals: sut vScrollBar maximumValue.

	"2) Vertical bar not needed anymore."
	sut extent: 100@100.
	sut hScrollBar setValue: 50.
	sut height: content height + sut hScrollBar height.
	self assert: sut hLeftoverScrollRange equals: sut hScrollBar maximumValue.

]

{ #category : #tests }
ScrollPaneTest >> test10ShrinkWrapHorizontally [

	sut vResizing: #rigid.
	sut hResizing: #shrinkWrap.
	sut vScrollBarPolicy: #always.
	
	content extent: 300@300.
	sut extent: 100@100.
		
	sut hScrollBarPolicy: #always.
	self refresh.
	self assert: 300 equals: content width.
	self assert: content width + sut scrollBarThickness equals: sut width.

	sut hScrollBarPolicy: #whenNeeded.
	self refresh.
	self assert: 300 equals: content width.
	self assert: content width + sut scrollBarThickness equals: sut width.
	
	content width: 450.
	self refresh.
	self assert: (sut right = sut vScrollBar right or: [sut left = sut vScrollBar left]).
]

{ #category : #tests }
ScrollPaneTest >> test11ShrinkWrapVertically [

	sut vResizing: #shrinkWrap.
	sut hResizing: #rigid.
	sut hScrollBarPolicy: #always.
	
	content extent: 300@300.
	sut extent: 100@100.
		
	sut vScrollBarPolicy: #always.
	self refresh.
	self assert: 300 equals: content height.
	self assert: content height + sut scrollBarThickness equals: sut height.

	sut vScrollBarPolicy: #whenNeeded.
	self refresh.
	self assert: 300 equals: content height.
	self assert: content height + sut scrollBarThickness equals: sut height.
	
	content height: 450.
	self refresh.
	self assert: sut bottom equals: sut hScrollBar bottom.
]
