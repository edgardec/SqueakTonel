Class {
	#name : #MorphHierarchyListMorph,
	#superclass : #SimpleHierarchicalListMorph,
	#category : #'Morphic-Widgets'
}

{ #category : #private }
MorphHierarchyListMorph >> createContainer [
	"Private - Create a container"
	| container |
	container := BorderedMorph new.
	container extent: (self world extent * (1 / 4 @ (2 / 3))) rounded.
	container layoutPolicy: TableLayout new.
	container hResizing: #rigid.
	container vResizing: #rigid.
	container
		color: (Color gray: 0.9);
		borderWidth: 1;
		borderColor: Color gray.
	container layoutInset: 0.
	"container useRoundedCorners."
	""
	container setProperty: #morphHierarchy toValue: true.
	container setNameTo: 'Objects Hierarchy' translated.
	""
	^ container
]

{ #category : #private }
MorphHierarchyListMorph >> inAContainer [
	"Answer the receiver contained in a proper container"
	| container |
	container := self createContainer.
	container addMorphBack: self.
	" 
	nasty hack to force the scroolbar recreation"
	self extent: container extent - container borderWidth.
	""
	^ container
]

{ #category : #initialization }
MorphHierarchyListMorph >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel keystroke: keyActionSel [ 
	super
		on: anObject
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: getMenuSel
		keystroke: keyActionSel.
	""
	self borderWidth: 0.
	self autoDeselect: false.
	self enableDrag: false.
	self enableDrop: true.
	self hResizing: #spaceFill.
	self vResizing: #spaceFill.
self expandRoots
]

{ #category : #selection }
MorphHierarchyListMorph >> setSelectedMorph: aMorph [ 
	super setSelectedMorph: aMorph.
self owner isNil ifFalse:[self owner delete]
]
