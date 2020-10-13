"
This class demonstrates how to use PluggableListViews.

"
Class {
	#name : #PluggableTest,
	#superclass : #Object,
	#instVars : [
		'musicTypeList',
		'musicTypeIndex',
		'artistList',
		'artistIndex'
	],
	#category : #'ST80-Pluggable Views'
}

{ #category : #example }
PluggableTest class >> open [
	"PluggableTest open"

	| model listView1 topView listView2 |
	model := self new.
	listView1 := PluggableListView 
				on: model
				list: #musicTypeList
				selected: #musicType
				changeSelected: #musicType:
				menu: #musicTypeMenu:
				keystroke: #musicTypeKeystroke:.
	listView1 menuTitleSelector: #musicTypeListTitle.
	listView2 := PluggableListView 
				on: model
				list: #artistList
				selected: #artist
				changeSelected: #artist:
				menu: nil
				keystroke: #artistKeystroke:.
	topView := (StandardSystemView new)
				label: 'Pluggable Test';
				minimumSize: 300 @ 200;
				borderWidth: 1;
				addSubView: listView1;
				addSubView: listView2 toRightOf: listView1.
	topView borderWidth: 1.
	topView controller open
]

{ #category : #'artist pane' }
PluggableTest >> artist [

	^ artistIndex

]

{ #category : #'artist pane' }
PluggableTest >> artist: anInteger [

	artistIndex := anInteger.
	self changed: #artist.

]

{ #category : #'artist pane' }
PluggableTest >> artistKeystroke: aCharacter [

	self artistList doWithIndex: [:artist :i |
		(artist first asLowercase = aCharacter asLowercase) ifTrue: [
			self artist: i]].

]

{ #category : #'artist pane' }
PluggableTest >> artistList [

	((musicTypeIndex ~= nil) and:
	 [musicTypeIndex between: 1 and: artistList size])
		ifTrue: [^ artistList at: musicTypeIndex]
		ifFalse: [^ #()].

]

{ #category : #'artist pane' }
PluggableTest >> artistName [
	"Answer the name of the currently selected artist, or nil if no artist is selected."

	| artistsForCurrentType |
	artistsForCurrentType := self artistList.
	(artistIndex between: 1 and: artistsForCurrentType size)
		ifTrue: [^ artistsForCurrentType at: artistIndex]
		ifFalse: [^ nil].

]

{ #category : #'menu commands' }
PluggableTest >> earlyCmd [

	self musicType: (musicTypeList indexOf: 'early').

]

{ #category : #'menu commands' }
PluggableTest >> flashCmd [

	Display reverse; reverse.
]

{ #category : #'menu commands' }
PluggableTest >> grungeCmd [

	SelectionMenu confirm:
		'You mean, like those strange bands from Seattle?'
]

{ #category : #initialization }
PluggableTest >> initialize [

	musicTypeList := #('reggae' 'classical' 'early').
	artistList := #(
		('alpha blondy' 'black uhuru' 'bob marley' 'burning spear')
		('bach' 'beethoven' 'josquin' 'morley' 'mozart' 'telemann')
		('josquin' 'morley' 'telemann')).
	musicTypeIndex := 0.
	artistIndex := 0.

]

{ #category : #'music type pane' }
PluggableTest >> musicType [

	^ musicTypeIndex

]

{ #category : #'music type pane' }
PluggableTest >> musicType: anInteger [

	| oldArtist |
	oldArtist := self artistName.
	musicTypeIndex := anInteger.  "this changes artists list"
	artistIndex := self artistList indexOf: oldArtist.
	self changed: #musicType.
	self changed: #artistList.

]

{ #category : #'music type pane' }
PluggableTest >> musicTypeKeystroke: aCharacter [

	musicTypeList doWithIndex: [:type :i |
		(type first asLowercase = aCharacter asLowercase)
			ifTrue: [self musicType: i]].

]

{ #category : #'music type pane' }
PluggableTest >> musicTypeList [

	^ musicTypeList

]

{ #category : #'music type pane' }
PluggableTest >> musicTypeListTitle [
	^ 'Choose a command'
]

{ #category : #'music type pane' }
PluggableTest >> musicTypeMenu: aMenu [

	^ aMenu addList: #(
		(reggae reggaeCmd)
		(early earlyCmd)
		(grunge grungeCmd)
		-
		(flash flashCmd))

]

{ #category : #'music type pane' }
PluggableTest >> musicTypeName [
	"Answer the name of the currently selected music type, or nil if no music type is selected."

	(musicTypeIndex between: 1 and: musicTypeList size)
		ifTrue: [^ musicTypeList at: musicTypeIndex]
		ifFalse: [^ nil].

]

{ #category : #'menu commands' }
PluggableTest >> perform: sel orSendTo: otherObject [
	(self respondsTo: sel) ifTrue: [self perform: sel] ifFalse: [otherObject perform: sel]
]

{ #category : #'menu commands' }
PluggableTest >> reggaeCmd [

	self musicType: (musicTypeList indexOf: 'reggae').

]
