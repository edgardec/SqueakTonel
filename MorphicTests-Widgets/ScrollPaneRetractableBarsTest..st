Class {
	#name : #ScrollPaneRetractableBarsTest,
	#superclass : #ScrollPaneTest,
	#category : #'MorphicTests-Widgets'
}

{ #category : #testing }
ScrollPaneRetractableBarsTest class >> shouldInheritSelectors [

	^ true
]

{ #category : #running }
ScrollPaneRetractableBarsTest >> setUp [

	super setUp.
	sut retractable: true.
]

{ #category : #tests }
ScrollPaneRetractableBarsTest >> test01ScrollBarPolicyWhenNeeded [

	sut
		hScrollBarPolicy: #whenNeeded;
		vScrollBarPolicy: #whenNeeded.
		
	content extent: 100@100.
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
ScrollPaneRetractableBarsTest >> test02ScrollBarPolicyAlways [

	sut
		hScrollBarPolicy: #always;
		vScrollBarPolicy: #always.
		
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
ScrollPaneRetractableBarsTest >> test06ScrollRanges [
	
	content extent: 200@300.
	self refresh.
	
	self
		assert: 200 equals: sut hTotalScrollRange;
		assert: 300 equals: sut vTotalScrollRange;
		assert: 100 equals: sut hLeftoverScrollRange;
		assert: 200 equals: sut vLeftoverScrollRange.

	sut hScrollBarValue: 50.
	sut vScrollBarValue: 30.
	
	"Scrolling does not affect the scroll ranges."
	self
		assert: 200 equals: sut hTotalScrollRange;
		assert: 300 equals: sut vTotalScrollRange;
		assert: 100 equals: sut hLeftoverScrollRange;
		assert: 200 equals: sut vLeftoverScrollRange.
]

{ #category : #tests }
ScrollPaneRetractableBarsTest >> test08ScrollToShow [

	content extent: 300@300.
	self refresh.
	
	"1a) Scroll down/right to show bottom right corner."
	self scrollToTopLeft.
	sut scrollToShow: (50@50 corner: 100@100).
	self assert: 0@0 equals: sut scroller offset.
	
	"1b) Scroll up/left to show top left corner."
	self scrollToBottomRight.
	sut scrollToShow: (100@100 corner: 150@150).
	self assert: 100@100 equals: sut scroller offset.

	"2a) Too big, so show bottom right corner because we scroll down/right."
	self scrollToTopLeft.
	sut scrollToShow: (0@0 corner: 100@100).
	self assert: 0@0 equals: sut scroller offset.

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
ScrollPaneRetractableBarsTest >> test10ShrinkWrapHorizontally [

	sut vResizing: #rigid.
	sut hResizing: #shrinkWrap.
	sut vScrollBarPolicy: #always.
	
	content extent: 300@300.
	sut extent: 100@100.
		
	sut hScrollBarPolicy: #always.
	self refresh.
	self assert: 300 equals: content width.
	self assert: content width equals: sut width.

	sut hScrollBarPolicy: #whenNeeded.
	self refresh.
	self assert: 300 equals: content width.
	self assert: content width equals: sut width.
	
	content width: 450.
	self refresh.
	self assert: (sut right = sut vScrollBar left or: [sut left = sut vScrollBar right]).
]

{ #category : #tests }
ScrollPaneRetractableBarsTest >> test11ShrinkWrapVertically [

	sut vResizing: #shrinkWrap.
	sut hResizing: #rigid.
	sut hScrollBarPolicy: #always.
	
	content extent: 300@300.
	sut extent: 100@100.
		
	sut vScrollBarPolicy: #always.
	self refresh.
	self assert: 300 equals: content height.
	self assert: content height equals: sut height.

	sut vScrollBarPolicy: #whenNeeded.
	self refresh.
	self assert: 300 equals: content height.
	self assert: content height equals: sut height.
	
	content height: 450.
	self refresh.
	self assert: sut bottom equals: sut hScrollBar top.
]
