Class {
	#name : #ImmWin32,
	#superclass : #ImmAbstractPlatform,
	#category : #'Multilingual-ImmPlugin'
}

{ #category : #keyboard }
ImmWin32 >> keyboardFocusForAMorph: aMorph [

	aMorph ifNil: [^ self].
	[
		| left top pos |
		pos := aMorph preferredKeyboardPosition.
		left := (pos x min: Display width max: 0) asInteger.
		top := (pos y min: Display height max: 0) asInteger.
		self setCompositionWindowPositionX: left y: top
	] on: Error
	do: [:ex |].

]

{ #category : #private }
ImmWin32 >> setCompositionWindowPositionX: x y: y [

	<primitive: 'primSetCompositionWindowPosition' module: 'ImmWin32Plugin'>

	^ nil

]
