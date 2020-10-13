Class {
	#name : #TableLayoutTest,
	#superclass : #TestCase,
	#instVars : [
		'container',
		'reset'
	],
	#category : #'MorphicTests-Layouts'
}

{ #category : #helper }
TableLayoutTest >> defaultFont [

	^ TextStyle defaultFont
]

{ #category : #helper }
TableLayoutTest >> defaultMorphSize [

	^ Morph new extent
]

{ #category : #helper }
TableLayoutTest >> ensureLayout: aMorph [

	^ aMorph
		fullBounds;
		yourself
]

{ #category : #failures }
TableLayoutTest >> expectedFailures [

	^ #(testDialogMinimalExtent)
]

{ #category : #helper }
TableLayoutTest >> newContainer [

	^ Morph new
		layoutPolicy: TableLayout new;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		listDirection: #leftToRight;
		color: self randomColor
]

{ #category : #helper }
TableLayoutTest >> newMorph [

	^ Morph new
		layoutPolicy: TableLayout new;
		color: self randomColor
]

{ #category : #helper }
TableLayoutTest >> randomColor [

	^ Color h: 360 atRandom s: 1 v: 1
]

{ #category : #helper }
TableLayoutTest >> repeat: aNumber times: aString [

	^ String streamContents: [:stream |
		aNumber timesRepeat: [stream nextPutAll: aString]]
]

{ #category : #running }
TableLayoutTest >> setUp [

	super setUp.
	
	reset := {
		([:enable | [self useRetractableScrollBars: enable]]
			value: self useRetractableScrollBars)
			in: [:block | self useRetractableScrollBars: false].
	}.
]

{ #category : #running }
TableLayoutTest >> tearDown [

	reset do: #value.
	super tearDown.
]

{ #category : #'tests - example layouts' }
TableLayoutTest >> testBrowser [
	" replicate the layout used by the system browser with a table layout "

	| buttons |
	buttons := #('browse' 'senders' 'implementors' 'versions' 'inheritance' 'hierarchy' 'vars' 'source') collect: [:label |
		self newMorph
			hResizing: #spaceFill;
			vResizing: #shrinkWrap;
			wrapCentering: #center;
			layoutPolicy: TableLayout new;
			layoutInset: 8;
			addMorph: (StringMorph new contents: label)].
	
	container := self newContainer
		listDirection: #topToBottom;
		layoutInset: 8;
		cellGap: 8;
		addMorphBack: (self newContainer
			cellGap: 8;
			listDirection: #leftToRight;
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			minimumHeight: 30;
			addMorphBack: (self newMorph hResizing: #spaceFill; vResizing: #spaceFill);
			addMorphBack: (self newMorph hResizing: #spaceFill; vResizing: #spaceFill);
			addMorphBack: (self newMorph hResizing: #spaceFill; vResizing: #spaceFill);
			addMorphBack: (self newMorph hResizing: #spaceFill; vResizing: #spaceFill));
		addMorphBack: (self newContainer
			vResizing: #shrinkWrap;
			hResizing: #spaceFill;
			cellGap: 2;
			addAllMorphsBack: buttons);
		addMorphBack: (self newMorph
			minimumHeight: 100;
			hResizing: #spaceFill;
			vResizing: #spaceFill).
	
	container extent: 0 @ 0.
	"container openInHand."
	
	self ensureLayout: container.
	self assert: 100 + 30 + self defaultFont height + (8 * 6) equals: container height
]

{ #category : #tests }
TableLayoutTest >> testCellGap [

	| first gap second |
	gap := 13.
	container := self newContainer
		cellGap: gap;
		addMorphBack: (first := self newMorph);
		addMorphBack: (second := self newMorph).
	
	container listDirection: #leftToRight.
	self ensureLayout: container.
	self assert: (self defaultMorphSize x * 2 + gap) @ self defaultMorphSize y equals: container extent.
	self assert: (0 @ 0 extent: first extent) equals: first bounds.
	self assert: (first width + gap @ 0 extent: second extent) equals: second bounds.
	
	container listDirection: #topToBottom.
	self ensureLayout: container.
	self assert: self defaultMorphSize x @ (self defaultMorphSize y * 2 + gap) equals: container extent.
	self assert: (0 @ 0 extent: first extent) equals: first bounds.
	self assert: (0 @ (first height + gap) extent: second extent) equals: second bounds.
	
	container listDirection: #rightToLeft.
	self ensureLayout: container.
	" changing listDirection here moves our container in the world, reset for easier assertions "
	container position: 0 @ 0.
	
	self assert: (self defaultMorphSize x * 2 + gap) @ self defaultMorphSize y equals: container extent.
	self assert: (0 @ 0 extent: second extent) equals: second bounds.
	self assert: (second width + gap @ 0 extent: first extent) equals: first bounds.
	
	container listDirection: #bottomToTop.
	self ensureLayout: container.
	container position: 0 @ 0.
	self assert: self defaultMorphSize x @ (self defaultMorphSize y * 2 + gap) equals: container extent.
	self assert: (0 @ 0 extent: second extent) equals: second bounds.
	self assert: (0 @ (second height + gap) extent: first extent) equals: first bounds
]

{ #category : #tests }
TableLayoutTest >> testCellInset [

	| first second inset |
	container := self newContainer
		addMorphBack: (first := self newMorph);
		addMorphBack: (second := self newMorph).
	
	inset := 13.
	self ensureLayout: (container cellInset: inset).
	self assert: (self defaultMorphSize x  * 2 + (inset * 4)) @ (self defaultMorphSize y + (inset * 2)) equals: container extent.
	
	inset := Rectangle left: 13 right: 7 top: 3 bottom: 17.
	self ensureLayout: (container cellInset: inset).
	self assert: (self defaultMorphSize x * 2 + (inset left + inset right * 2)) @ (self defaultMorphSize y + (inset top + inset right * 2)) equals: container extent.
	
	inset := 7 @ 13.
	self ensureLayout: (container cellInset: inset).
	self assert: (self defaultMorphSize x * 2) + (inset x * 2 * 2) @ (self defaultMorphSize y + (inset y * 2)) equals: container extent
]

{ #category : #'tests - example layouts' }
TableLayoutTest >> testDialog [
	" construct a typical yes/no confirm dialog.
	
	the test itself is currently expected to fail, as we do not support minimum extent that is derived from layout for rigid containers "

	| contentLabel font spacing |
	spacing := 8.
	container := self newContainer
		listDirection: #topToBottom;
		hResizing: #rigid;
		cellGap: spacing;
		layoutInset: (Rectangle left: 0 right: 0 top: 0 bottom: spacing);
		addMorphBack: (self newContainer
			cellGap: spacing;
			hResizing: #spaceFill;
			layoutInset: spacing;
			addMorphBack: (self newMorph extent: 16 asPoint);
			addMorphBack: (TextMorph new contents: 'Please Confirm'; hResizing: #spaceFill; centered);
			addMorphBack: (self newMorph extent: 16 asPoint));
		addMorphBack: (contentLabel := TextMorph new margins: spacing @ 0; vResizing: #shrinkWrap; hResizing: #spaceFill);
		addMorphBack: (self newContainer
			cellGap: spacing;
			addMorphBack: (self newMorph extent: 50 @ 26);
			addMorphBack: (self newMorph extent: 50 @ 26)).
	"container openInHand."
	
	font := self defaultFont.
	contentLabel contents: (self repeat: 80 times: 'a ').
	
	container width: (font widthOfString: contentLabel contents) + 2 + (spacing * 2).
	self ensureLayout: container.
	self assert: (font widthOfString: contentLabel contents) + 2 + (spacing * 2) equals: container width.
	
	container width: (font widthOfString: contentLabel contents) // 2.
	self ensureLayout: container.
	self assert: ((font widthOfString: contentLabel contents) // 2) equals: container width.
]

{ #category : #'tests - example layouts' }
TableLayoutTest >> testDialogMinimalExtent [
	"Like #testDialog, but tests for the minimal extent, too."

	self testDialog.
	
	" ensure we can't resize below our children's width "
	container width: 0.
	self ensureLayout: container.
	self assert: container firstSubmorph width equals: container width.
]

{ #category : #tests }
TableLayoutTest >> testDisableLayoutEmptyArrangement [

	container := Morph new
		layoutPolicy: TableLayout new;
		listDirection: #rightToLeft; "... to not get into the layout's fast lane ..."
		wrapCentering: #center; "... to actually trigger the bug ..."
		addMorphBack: Morph new;
		addMorphBack: Morph new;
		yourself.

	container submorphsDo: [:m | m disableLayout: true].
	self shouldnt: [self ensureLayout: container] raise: Error.
]

{ #category : #tests }
TableLayoutTest >> testInnerTopLeft [
	"The morph that is layed out in the owner must be in the top-left corner, regardless of its resizing properties."
	
	| inner |
	container := self newContainer
		hResizing: #rigid;
		vResizing: #rigid;
		addMorphBack: (inner := self newMorph
			layoutPolicy: nil;
			addMorphBack: self newMorph;
			yourself);
		yourself.
	
	#(rigid shrinkWrap spaceFill) do: [:h | #(rigid shrinkWrap spaceFill) do: [:v |
		inner hResizing: h; vResizing: v.
		self ensureLayout: container.
		self assert: container topLeft equals: inner topLeft]].
]

{ #category : #tests }
TableLayoutTest >> testListCentering [

	| firstChild secondChild thirdChild |
	container := self newContainer
		hResizing: #rigid;
		vResizing: #rigid;
		listDirection: #topToBottom;
		wrapCentering: #topLeft;
		extent: 100 @ 200;
		addMorphBack: (firstChild := self newMorph extent: 50 @ 50);
		addMorphBack: (secondChild := self newMorph extent: 80 @ 50);
		addMorphBack: (thirdChild := self newMorph extent: 50 @ 50).
	
	container listCentering: #topLeft.
	self ensureLayout: container.
	" 15 is (80 - 50) / 2, because of the wrapCentering we fill to the large child and then center "
	self assert: 15 @ 0 equals: firstChild position.
	self assert: 0 @ 50 equals: secondChild position.
	self assert: 15 @ 100 equals: thirdChild position.
	
	container listCentering: #bottomRight.
	self ensureLayout: container.
	self assert: 15 @ 50 equals: firstChild position.
	self assert: 0 @ 100 equals: secondChild position.
	self assert: 15 @ 150 equals: thirdChild position.
	
	container listCentering: #justified.
	self ensureLayout: container.
	self assert: 15 @ 0 equals: firstChild position.
	" center of the parent morph: "
	self assert: 0 @ ((200 / 2) - (50 / 2)) equals: secondChild position.
	self assert: 15 @ 150 equals: thirdChild position.
	
	container listCentering: #center.
	self ensureLayout: container.
	self assert: 15 @ 25 equals: firstChild position.
	self assert: 0 @ ((200 / 2) - (50 / 2)) equals: secondChild position.
	self assert: 15 @ 125 equals: thirdChild position
]

{ #category : #tests }
TableLayoutTest >> testPluggableTextMorph [

	| ptm |
	ptm := PluggableTextMorph new
		extent: 100@50;
		setText: 'Hello World! Hello World! Hello World! Hello World!';
		wrapFlag: true.
			
	container := self newContainer addMorphBack: ptm.
	self ensureLayout: container.
	self assert: 100@50 equals: container extent.

	self assert: ptm vIsScrollbarShowing.
	self deny: ptm hIsScrollbarShowing.

	"Make it a one-liner."
	ptm wrapFlag: false.
	self ensureLayout: container.
	self deny: ptm vIsScrollbarShowing.
	self assert: ptm hIsScrollbarShowing.

	"Make it a one-liner without the horizontal scrollbar."
	ptm hideScrollBarsIndefinitely.
	self ensureLayout: container.
	self deny: ptm vIsScrollbarShowing.
	self deny: ptm hIsScrollbarShowing.

]

{ #category : #tests }
TableLayoutTest >> testPluggableTextMorphScrollBarNotNeeded [
	"The entire test might fit if the scroll bar would only disappear..."

	| ptm |
	ptm := PluggableTextMorph new
		extent: 100@50;
		setText: 'Hello World! Hello World! \\\ Hello World! Hello World!' withCRs.
	container := self newContainer addMorphBack: ptm.
	
	"Make it fit exactly first."
	ptm hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	self ensureLayout: container.
	ptm hResizing: #rigid; vResizing: #rigid.
	ptm wrapFlag: true.

	"No scrollbars required."
	self ensureLayout: container.
	self deny: ptm vIsScrollbarShowing.
	
	"It wraps immediately."
	ptm width: ptm width - 5.
	self ensureLayout: container.
	self assert: ptm vIsScrollbarShowing.

	"No scrollbars required."
	ptm width: ptm width + 5.
	self ensureLayout: container.
	self deny: ptm vIsScrollbarShowing.
]

{ #category : #tests }
TableLayoutTest >> testPluggableTextMorphShrinkWrap [

	| ptm |
	ptm := PluggableTextMorph new
		extent: 100@50;
		setText: 'Hello World! Hello World! \\\ Hello World! Hello World!' withCRs.
	container := self newContainer addMorphBack: ptm.
	
	ptm wrapFlag: false. "for the inner text morph"
	ptm hResizing: #shrinkWrap; vResizing: #shrinkWrap. "for the outer scroll pane"	
	self ensureLayout: container.

	self deny: ptm vIsScrollbarShowing.
	self deny: ptm hIsScrollbarShowing.
	self assert: ptm innerExtent equals: ptm textMorph extent.
]

{ #category : #'tests - scroll panes' }
TableLayoutTest >> testScrollPaneBarUpdate [

	| child container |
	container := ScrollPane new color: Color green; extent: 300 @ 300; showVScrollBarOnlyWhenNeeded; showHScrollBarOnlyWhenNeeded.
	container scroller addMorphBack: (child := Morph new color: Color red; extent: 100 @ 100).
	
	self ensureLayout: container.
	self assert: container hScrollBar owner isNil.
	self assert: container vScrollBar owner isNil.
	
	child extent: 400 @ 100.
	self ensureLayout: container.
	self assert: container hScrollBar owner notNil.
	self assert: container vScrollBar owner isNil.
	
	child extent: 400 @ 400.
	self ensureLayout: container.
	self assert: container hScrollBar owner notNil.
	self assert: container hScrollBar owner notNil
]

{ #category : #tests }
TableLayoutTest >> testScrollPaneShrinkWrap [

	| scroll scrollContent |
	container := self newContainer
		vResizing: #rigid;
		addMorphBack: (self newMorph extent: 50 @ 50);
		addMorphBack: (scroll := ScrollPane new
			hResizing: #shrinkWrap;
			vResizing: #spaceFill;
			showVScrollBarOnlyWhenNeeded;
			hideHScrollBarIndefinitely).
	
	" shrinkWrap the horizontal axis but scroll vertically "
	scroll scroller
		layoutPolicy: TableLayout new;
		addMorphBack: (scrollContent := self newMorph extent: 200 @ 500).

	container extent: 1 @ 300.
	self ensureLayout: container.
	self assert: container left = (container layoutChanged; fullBounds; left). "Do not be jumpy."
	self assert: (200 + scroll scrollBarThickness + scroll borderWidth) @ 300 equals: scroll extent.
	
	scrollContent extent: 300 @ 500.
	self ensureLayout: container.
	self assert: (300 + scroll scrollBarThickness + scroll borderWidth) @ 300 equals: scroll extent
]

{ #category : #'tests - scroll panes' }
TableLayoutTest >> testScrollerFill [
	"A scroll pane's scroller (i.e., the transform morph) has always #spaceFill behavior within the scroll pane's layout. Thus, submorphs (here: title and content) can themselves be #spaceFill. Embed a text morph to check height-for-width compatibility."
	
	| content title |
	container := ScrollPane new.
	
	container scroller
		layoutPolicy: TableLayout new;
		color: Color random;
		addMorphBack: (title := TextMorph new hResizing: #spaceFill; contents: 'Here comes an interesting title');
		addMorphBack: (content := self newMorph extent: 400 @ 400; hResizing: #spaceFill).
	container extent: 50 @ 50. "Pick an extent so that the title must wrap!"
	self ensureLayout: container.
	
	"container openInHand."
	
	container extent: 500 @ 500.
	self ensureLayout: container.
	self assert: 500 @ 500 equals: container extent.
	self assert: 500 - (container borderWidth  * 2) @ 400 equals: content extent.
	
	container extent: 300 @ 300.
	self ensureLayout: container.
	self assert: 300 @ 300 equals: container extent.
	self assert: 300 - container borderWidth - container scrollBarThickness @ 400 equals: content extent
]

{ #category : #'tests - scroll panes' }
TableLayoutTest >> testScrollerFillWithContainer [
	"A scroll pane's scroller (i.e., the transform morph) has always #spaceFill behavior within the scroll pane's layout. Thus, submorphs (here: title and content) can themselves be #spaceFill. Embed a text morph to check height-for-width compatibility. Add an extra container between scroller and title/content."

	| content title |
	container := ScrollPane new.
	
	container scroller
		layoutPolicy: TableLayout new;
		addMorphBack: (self newContainer
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			listDirection: #topToBottom;
			addMorphBack: (title := TextMorph new hResizing: #spaceFill; contents: 'Here comes an interesting title');
			addMorphBack: (content := self newMorph extent: 400 @ 400; hResizing: #spaceFill)).
	container extent: 50 @ 50. "Pick an extent so that the title must wrap!"
	self ensureLayout: container.
	
	"container openInHand."
	
	container extent: 500 @ 500.
	self ensureLayout: container.
	self assert: 500 @ 500 equals: container extent.
	self assert: 500 - (container borderWidth  * 2) @ 400 equals: content extent.
	
	container extent: 300 @ 300.
	self ensureLayout: container.
	self assert: 300 @ 300 equals: container extent.
	self assert: 300 - container borderWidth - container scrollBarThickness @ 400 equals: content extent
]

{ #category : #tests }
TableLayoutTest >> testShrinkWrapAndSpaceFill [

	| shrinkWrapped spaceFilled |
	container := self newContainer
		addMorphBack: (spaceFilled := self newMorph hResizing: #spaceFill; vResizing: #spaceFill);
		addMorphBack: (shrinkWrapped := self newMorph hResizing: #shrinkWrap; vResizing: #shrinkWrap).
	
	" minimal size "
	self ensureLayout: container.
	self assert: 1 equals: spaceFilled width.
	self assert: self defaultMorphSize equals: shrinkWrapped extent.
	
	" scale up horizontally "
	self ensureLayout: (container extent: self defaultMorphSize x * 2 @ self defaultMorphSize y).
	self assert: self defaultMorphSize equals: spaceFilled extent.
	self assert: self defaultMorphSize equals: shrinkWrapped extent.
	
	" scale up in horizontally and vertically "
	self ensureLayout: (container extent: self defaultMorphSize * 2).
	self assert: self defaultMorphSize x @ (self defaultMorphSize y * 2) equals: spaceFilled extent.
	self assert: self defaultMorphSize equals: shrinkWrapped extent
]

{ #category : #tests }
TableLayoutTest >> testShrinkWrapScrollPaneAlwaysShowBars [

	| scroll scrollContent |
	container := self newContainer
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		addMorphBack: (scroll := ScrollPane new
			hResizing: #shrinkWrap;
			vResizing: #shrinkWrap;
			alwaysShowHScrollBar;
			alwaysShowVScrollBar).
	
	scroll scroller
		layoutPolicy: TableLayout new;
		addMorphBack: (scrollContent := self newMorph extent: 300 @ 300).
	
	self ensureLayout: container.
	self assert: (300 @ 300) + scroll scrollBarThickness + scroll borderWidth equals: container extent
]

{ #category : #'tests - example layouts' }
TableLayoutTest >> testSidebarAndScrollingView [
	" construct a container that has a fixed size sidebar on the left and a scrolling window that adapts flexibly to the container's size "

	| scrolling sidebar content title |
	container := self newContainer
		addMorphBack: (sidebar := self newMorph width: 200; hResizing: #rigid; vResizing: #spaceFill);
		addMorphBack: (scrolling := ScrollPane new hResizing: #spaceFill; vResizing: #spaceFill).
	
	scrolling scroller
		layoutPolicy: TableLayout new;
		addMorphBack: (self newContainer
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			listDirection: #topToBottom;
			addMorphBack: (title := TextMorph new hResizing: #spaceFill; contents: 'Here comes a title');
			addMorphBack: (content := self newMorph extent: 400 @ 400; hResizing: #spaceFill)).
	self ensureLayout: container.
	
	"container openInHand."
	
	container extent: 500 @ 500.
	self ensureLayout: container.
	self assert: 200 @ 500 equals: sidebar extent.
	self assert: 300 @ 500 equals: scrolling extent.
	self assert: 300 - (scrolling borderWidth  * 2) @ 400 equals: content extent.
	
	container extent: 300 @ 300.
	self ensureLayout: container.
	self assert: 200 @ 300 equals: sidebar extent.
	self assert: 100 @ 300 equals: scrolling extent.
	self assert: 100 - scrolling borderWidth - scrolling scrollBarThickness @ 400 equals: content extent
]

{ #category : #tests }
TableLayoutTest >> testTwoTextMorphsHorizontal [

	| str1 str2 label2 label1 heightAt200 |
	str1 := 'abc def'.
	str2 := 'tzu ghj qwe'.
	container := self newContainer
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		addMorphBack: (label1 := TextMorph new contents: str1; wrapFlag: true; hResizing: #spaceFill);
		addMorphBack: (label2 := TextMorph new contents: str2; wrapFlag: true; hResizing: #spaceFill).
	
	container width: 200.
	self ensureLayout: container.
	heightAt200 := container height.
	
	self assert: 100 equals: label1 width.
	self assert: 100 equals: label2 width.
	
	container width: 100.
	self ensureLayout: container.
	self assert: 50 equals: label1 width.
	self assert: 50 equals: label2 width.
	self assert: container height > heightAt200.
	
	container width: 10000.
	self ensureLayout: container.
	self assert: 5000 equals: label1 width.
	self assert: 5000 equals: label2 width.
	self assert: self defaultFont height + 2 equals: container height
]

{ #category : #tests }
TableLayoutTest >> testTwoTextMorphsVertical [

	| str1 str2 label2 label1 font |
	str1 := 'abc def'.
	str2 := 'tzu ghj qwe'.
	container := self newContainer
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		listDirection: #topToBottom;
		addMorphBack: (label1 := TextMorph new contents: str1; wrapFlag: true; hResizing: #spaceFill);
		addMorphBack: (label2 := TextMorph new contents: str2; wrapFlag: true; hResizing: #spaceFill).
	
	font := self defaultFont.
	
	container width: 200.
	self ensureLayout: container.
	self assert: 200 @ (font height + 2) equals: label1 extent.
	self assert: 200 @ (font height + 2) equals: label2 extent.
	
	container width: 50.
	self ensureLayout: container.
	self assert: 50 equals: label1 width.
	self assert: 50 equals: label2 width.
	" check that we land on a multiple of the line height "
	self assert: 0 equals: container height \\ (font height + 2).
	
	container width: 20.
	self ensureLayout: container.
	self assert: 20 equals: label1 width.
	self assert: 20 equals: label2 width.
	" check that we land on a multiple of the line height "
	self assert: 0 equals: container height \\ (font height + 2)
]

{ #category : #tests }
TableLayoutTest >> testWrappingLayout [

	container := self newContainer
		hResizing: #rigid;
		listDirection: #leftToRight;
		wrapDirection: #none;
		addMorphBack: (self newMorph extent: 50 @ 50);
		addMorphBack: (self newMorph extent: 50 @ 50);
		addMorphBack: (self newMorph extent: 50 @ 50).
	
	container width: 50.
	self ensureLayout: container.
	self assert: 50 @ 50 equals: container extent.
	self assert: #(0 50 100) equals: (container submorphs collect: #left).
	
	container wrapDirection: #leftToRight.
	self ensureLayout: container.
	self assert: 50 @ 150 equals: container extent.
	self assert: #(0 0 0) equals: (container submorphs collect: #left).
	
	container width: 125.
	self ensureLayout: container.
	self assert: 125 @ 100 equals: container extent.
	self assert: #(0 50 0) equals: (container submorphs collect: #left)
]

{ #category : #running }
TableLayoutTest >> useRetractableScrollBars [
	
	^ ScrollPane classPool at: #UseRetractableScrollBars
]

{ #category : #running }
TableLayoutTest >> useRetractableScrollBars: aBoolean [
	"Re-implemented to avoid triggering #allSubInstancesDo:."
	
	ScrollPane classPool at: #UseRetractableScrollBars put: aBoolean.
]
