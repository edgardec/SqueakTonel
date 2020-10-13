"
A ColorArray is an array of colors encoded on 32-bits.

The encoding of colors follows the ARGB scheme.
See https://en.wikipedia.org/wiki/RGBA_color_model

The color is decomposed into 4 channels of 8 bits (4 bytes)
- the most significant byte A is alpha channel which governs transparency
  0 means a completely transparent (invisible) color
  255 means an opaque color.
- the second most significant byte R encodes the level of red
  the lower, the darker and/or least saturated
- the third most significant byte G encodes the level of green
- the least significant byte B encodes the level of blue

Color white is encoded as 16rFFFFFFFF.
	((ColorArray with: Color white) basicAt: 1) hex.
For historical reasons, notice that Color black is encoded as a very dark blue 16rFF000001 rather than 16rFF000000.
	((ColorArray with: Color black) basicAt: 1) hex.
Other example of pure red, pure green and pure blue showing the bit position of those channels:
	((ColorArray with: Color red) basicAt: 1) hex.
	((ColorArray with: Color green) basicAt: 1) hex.
	((ColorArray with: Color blue) basicAt: 1) hex.
Color transparent is encoded as zero on all channels:
	((ColorArray with: Color transparent) basicAt: 1) hex.
"
Class {
	#name : #ColorArray,
	#superclass : #RawBitsArray,
	#type : #words,
	#category : #'Collections-Arrayed'
}

{ #category : #converting }
ColorArray >> asColorArray [
	^self
]

{ #category : #accessing }
ColorArray >> at: index [
	^(super at: index) asColorOfDepth: 32
]

{ #category : #accessing }
ColorArray >> at: index put: aColor [
	^super at: index put: (aColor pixelWordForDepth: 32).
]

{ #category : #converting }
ColorArray >> bytesPerElement [

	^4
]
