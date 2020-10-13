Class {
	#name : #CharacterScannerTest,
	#superclass : #TestCase,
	#instVars : [
		'style',
		'mWidth',
		'spaceWidth'
	],
	#category : #'GraphicsTests-Text'
}

{ #category : #running }
CharacterScannerTest >> setUp [
	style := TextStyle default copy.
	style firstIndent: 0; restIndent: 0; rightIndent: 0.
	mWidth := style defaultFont widthOf: $m.
	spaceWidth := style defaultFont widthOf: Character space.
]

{ #category : #tests }
CharacterScannerTest >> testBreakAnywhere [
	| p text cbs indicesOfM |
	text := ((String new: 2 withAll: $m) , (String space) , (String new: 2 withAll: $m)) asText.
	p := NewParagraph new.
	p
		compose: text
		style: style
		from: 1
		in: (0 @ 0 corner: mWidth+1 @ (style lineGrid * 6)).
	indicesOfM := (1 to: text size) select: [:i | (text at: i) = $m].
	self assert: p lines size equals: indicesOfM size description: 'Each m is on a new line'.
	self assert: (p lines collect: #first) equals: indicesOfM description: 'Each line begins with m'.
	
	cbs := indicesOfM collect: [:i | p characterBlockForIndex: i].
	self assert: (cbs collect: #left as: Set) size = 1 description: 'Selecting before each m align on same column'
	 
		
]

{ #category : #tests }
CharacterScannerTest >> testBreakAnywhereWhenFirstCharDoesNotFit [
	| p text cbs |
	text := ((String new: 2 withAll: $m) , (String space) , (String new: 2 withAll: $m)) asText.
	p := NewParagraph new.
	p
		compose: text
		style: style
		from: 1
		in: (0 @ 0 corner: mWidth-1 @ (style lineGrid * 7)).
	self assert: p lines size equals: text size + 1 description: 'Each character is on a new line, past end also'.
	self assert: (p lines collect: #first) equals: (1 to: text size + 1) asArray description: 'Each character is on a new line'.
	
	cbs := (1 to: text size + 1) collect: [:i | p characterBlockForIndex: i].
	self assert: (cbs collect: #left as: Set) size = 1 description: 'Selecting before each character align on left'
	 
		
]

{ #category : #tests }
CharacterScannerTest >> testBreakAtLastCr [
	| p text cbfirst cblast cbend cbend2 |
	text := ((String new: 4 withAll: $m) , (String new: 2 withAll: Character space) , String cr) asText.
	p := NewParagraph new.
	p
		compose: text
		style: style
		from: 1
		in: (0 @ 0 corner: mWidth*4+(spaceWidth*2)+1 @ (style lineGrid * 4)).
	self assert: p lines size = 2 description: 'An empty last line after CR must be materialized'.
	self assert: p lines first last = 7 description: 'The CR is included in the line preceding it'.
	
	cbfirst := p characterBlockForIndex: 1.
	cblast := p characterBlockForIndex: text size.
	self assert: cblast origin y = cbfirst origin y description: 'The CR coordinate is still on the first line'.
	cbend := p characterBlockForIndex: text size + 1.
	self assert: cbend origin y >= cblast corner y description: 'Past end is located on the next line'.
	
	cbend2 := p characterBlockAtPoint: 0 @ (cbend corner y + style lineGrid).
	self assert: cbend = cbend2 description: 'Clicking below the second line gives the past end location'.
	self assert: cbend origin = cbend2 origin.
	self assert: cbend corner = cbend2 corner.
	 
		
]

{ #category : #tests }
CharacterScannerTest >> testBreakAtLastSpace [
	| p text cbfirst cblast cbend cbend2 |
	text := ((String new: 4 withAll: $m) , (String new: 3 withAll: Character space)) asText.
	p := NewParagraph new.
	p
		compose: text
		style: style
		from: 1
		in: (0 @ 0 corner: mWidth*4+(spaceWidth*2)+1 @ (style lineGrid * 4)).
	self assert: p lines size = 2 description: 'In leftFlush alignment, spaces at end of line overflowing the right margin should flow on next line'.
	self assert: p lines first last = 7 description: 'The space which is crossing the right margin is included in the first line as if it were a CR'.
	
	cbfirst := p characterBlockForIndex: 1.
	cblast := p characterBlockForIndex: text size.
	self assert: cblast origin y = cbfirst origin y description: 'The last space coordinate is still on the first line'.
	cbend := p characterBlockForIndex: text size + 1.
	self assert: cbend origin y >= cblast corner y description: 'Past end is located on the next line'.
	
	cbend2 := p characterBlockAtPoint: 0 @ (cbend corner y + style lineGrid).
	self assert: cbend = cbend2 description: 'Clicking below the second line gives the past end location'.
	self assert: cbend origin = cbend2 origin.
	self assert: cbend corner = cbend2 corner.
	 
		
]

{ #category : #tests }
CharacterScannerTest >> testBreakAtSpace [
	| p text cbfirst cblast cbend cbend2 |
	text := ((String new: 4 withAll: $m) , (String new: 4 withAll: Character space)) asText.
	p := NewParagraph new.
	p
		compose: text
		style: style
		from: 1
		in: (0 @ 0 corner: mWidth*4+(spaceWidth*2)+1 @ (style lineGrid * 4)).
	self assert: p lines size = 2 description: 'In leftFlush alignment, spaces at end of line overflowing the right margin should flow on next line'.
	self assert: p lines first last = 7 description: 'The space which is crossing the right margin is included in the first line as if it were a CR'.
	
	cbfirst := p characterBlockForIndex: 1.
	cblast := p characterBlockForIndex: text size.
	self assert: cblast origin y >= cbfirst corner y description: 'The last space coordinate is under the first line'.
	cbend := p characterBlockForIndex: text size + 1.
	self assert: cbend origin x >= cblast corner x description: 'Past end is located right of last space'.
	
	cbend2 := p characterBlockAtPoint: 0 @ (cbend corner y + style lineGrid).
	self assert: cbend = cbend2 description: 'Clicking below the second line gives the past end location'.
	self assert: cbend origin = cbend2 origin.
	self assert: cbend corner = cbend2 corner.
	 
		
]

{ #category : #tests }
CharacterScannerTest >> testBreakBeforeLongWord [
	| p text cbfirst cblast cbend cbend2 cbend1 cbspace |
	text := ((String with: $m) , (String with: Character space) , (String new: 4 withAll: $m)) asText.
	p := NewParagraph new.
	p
		compose: text
		style: style
		from: 1
		in: (0 @ 0 corner: mWidth*4+(spaceWidth*2)+1 @ (style lineGrid * 4)).
	self assert: p lines size = 2 description: 'In leftFlush alignment, a long word overflowing the right margin should flow on next line'.
	self assert: p lines first last = 2 description: 'The space before the long word is on the first line'.
	
	cbfirst := p characterBlockForIndex: 1.
	cblast := p characterBlockForIndex: text size.
	self assert: cblast origin y >= cbfirst corner y description: 'The long word coordinate is under the first line'.
	cbend := p characterBlockForIndex: text size + 1.
	self assert: cbend origin x >= cblast corner x description: 'Past end is located right of long word'.
	
	cbend2 := p characterBlockAtPoint: 0 @ (cbend corner y + style lineGrid).
	self assert: cbend = cbend2 description: 'Clicking below the second line gives the past end location'.
	self assert: cbend origin = cbend2 origin.
	self assert: cbend corner = cbend2 corner.
	
	cbspace := p characterBlockForIndex: 2.
	self assert: cbspace origin y = cbfirst origin y description: 'The space is on the first line'.
	
	cbend1 := p characterBlockAtPoint: cbspace corner x + 1 @ cbspace center y.
	self assert: cbend1 origin x >= cbspace corner x description: 'Clicking after the space starts right after the space'.
	self assert: cbend1 origin y = cbspace origin y description: 'Clicking after the space starts on same line as the space'.
	self assert: cbend1 stringIndex = 3  description: 'Clicking after the space starts on the long word'.
	 
		
]

{ #category : #tests }
CharacterScannerTest >> testClickLeftOfCenteredText [
	| p text cbfirst cbfirst2 |
	style := TextStyle default.
	mWidth := style defaultFont widthOf: $m.
	spaceWidth := style defaultFont widthOf: Character space.
	text := (String new: 4 withAll: $m) asText.
	text addAttribute: TextAlignment centered from: 1 to: text size.
	p := NewParagraph new.
	p
		compose: text
		style: style
		from: 1
		in: (2 @ 2 extent: mWidth*8 @ (style lineGrid * 2)).
	
	cbfirst := p characterBlockForIndex: 1.
	cbfirst2 := p characterBlockAtPoint: 1 @ cbfirst center y.
	self assert: cbfirst = cbfirst2.
	self assert: cbfirst origin = cbfirst2 origin description: 'Clicking left of the margin shall position the cursor correctly'.
]
