"
This class implements the Fast Fourier Transform roughly as described on page 367
of ""Theory and Application of Digital Signal Processing"" by Rabiner and Gold.
Each instance caches tables used for transforming a given size (n = 2^nu samples) of data.

It would have been cleaner using complex numbers, but often the data is all real.
"
Class {
	#name : #FFT,
	#superclass : #Object,
	#instVars : [
		'nu',
		'n',
		'sinTable',
		'permTable',
		'realData',
		'imagData',
		'window'
	],
	#category : #'Sound-Synthesis'
}

{ #category : #'instance creation' }
FFT class >> new: anIntegerPowerOfTwo [
	"Answer a new FFT instance for transforming data packets of the given size."

	^ self new setSize: anIntegerPowerOfTwo

]

{ #category : #testing }
FFT >> imagData [

	^ imagData

]

{ #category : #'bulk processing' }
FFT >> initializeHammingWindow: alpha [
	"Initialize the windowing function to the generalized Hamming window. See F. Richard Moore, Elements of Computer Music, p. 100. An alpha of 0.54 gives the Hamming window, 0.5 gives the hanning window."

	| v midPoint |
	window := Float32Array new: n.
	midPoint := (n + 1) / 2.0.
	1 to: n do: [:i |
		v := alpha + ((1.0 - alpha) * (2.0 * Float pi * ((i - midPoint) / n)) cos).
		window at: i put: v].


]

{ #category : #'bulk processing' }
FFT >> initializeTriangularWindow [
	"Initialize the windowing function to the triangular, or Parzen, window. See F. Richard Moore, Elements of Computer Music, p. 100."

	| v |
	window := Float32Array new: n.
	0 to: (n // 2) - 1 do: [:i |
		v := i / ((n // 2) - 1).
		window at: (i + 1) put: v.
		window at: (n - i) put: v].

]

{ #category : #initialization }
FFT >> n [

	^ n

]

{ #category : #initialization }
FFT >> nu: order [
	"Initialize variables and tables for transforming 2^nu points"
	|  j perms k |
	nu := order.
	n := 2 bitShift: nu-1.

	"Initialize permutation table (bit-reversed indices)"
	j:=0.
	perms := WriteStream on: (Array new: n).
	0 to: n-2 do:
		[:i |
		i < j ifTrue: [perms nextPut: i+1; nextPut: j+1].
		k := n // 2.
		[k <= j] whileTrue: [j := j-k.  k := k//2].
		j := j + k].
	permTable := perms contents.

	"Initialize sin table 0..pi/2 in n/4 steps."
	sinTable := (0 to: n/4) collect: [:i | (i asFloat / (n//4) * Float pi / 2.0) sin]
]

{ #category : #transforming }
FFT >> permuteData [
	| i end a b |
	i := 1.
	end := permTable size.
	[i <= end] whileTrue:
		[a := permTable at: i.
		b := permTable at: i+1.
		realData swap: a with: b.
		imagData swap: a with: b.
		i := i + 2]
]

{ #category : #testing }
FFT >> plot: samples in: rect [
	"Throw-away code just to check out a couple of examples"
	| dx pen min max x |
	Display fillWhite: rect; border: (rect expandBy: 2) width: 2.
	min := 1.0e30.  max := -1.0e30.
	samples do:
		[:v |
		min := min min: v.
		max := max max: v].
	pen := Pen new.  pen up.
	x := rect left.
	dx := rect width asFloat / samples size.
	samples do:
		[:v | | y |
		y := (max-v) / (max-min) * rect height asFloat.
		pen goto: x asInteger @ (rect top + y asInteger).
		pen down.
		x := x + dx].
	max printString displayOn: Display at: (x+2) @ (rect top-9).
	min printString displayOn: Display at: (x+2) @ (rect bottom - 9)
]

{ #category : #'plugin-testing' }
FFT >> pluginPrepareData [
	"The FFT plugin requires data to be represented in WordArrays or FloatArrays"
	sinTable := sinTable asFloat32Array.
	permTable := permTable asWordArray.
	realData := realData asFloat32Array.
	imagData := imagData asFloat32Array.
]

{ #category : #'plugin-testing' }
FFT >> pluginTest [  "Display restoreAfter: [(FFT new nu: 12) pluginTest]."
	"Test on an array of 256 samples"
	"Initialize to pure (co)Sine Wave, plot, transform, plot, invert and plot again"
	self realData: ((1 to: n) collect: [:i | (Float pi * (i-1) / (n/8)) cos]).
	self plot: realData in: (100@20 extent: 256@60).
	self pluginPrepareData.
	Transcript cr; print: (Time millisecondsToRun:[self pluginTransformData: true]); endEntry.
	self plot: realData in: (100@100 extent: 256@60).
	self plot: imagData in: (100@180 extent: 256@60).
	Transcript cr; print: (Time millisecondsToRun:[self pluginTransformData: false]); endEntry.
	self plot: realData in: (100@260 extent: 256@60)
]

{ #category : #'plugin-testing' }
FFT >> pluginTransformData: forward [
	"Plugin testing -- if the primitive is not implemented 
	or cannot be found run the simulation. See also: FFTPlugin"
	<primitive: 'primitiveFFTTransformData' module: 'FFTPlugin'>
	^(Smalltalk at: #FFTPlugin ifAbsent:[^self primitiveFailed])
		doPrimitive: 'primitiveFFTTransformData'.
]

{ #category : #testing }
FFT >> realData [

	^ realData

]

{ #category : #initialization }
FFT >> realData: real [
	realData := real.
	imagData := real collect: [:i | 0.0]  "imaginary component all zero"
]

{ #category : #initialization }
FFT >> realData: real imagData: imag [
	realData := real.
	imagData := imag
]

{ #category : #testing }
FFT >> samplesPerCycleForIndex: i [
	"Answer the number of samples per cycle corresponding to a power peak at the given index. Answer zero if i = 1, since an index of 1 corresponds to the D.C. component."

	| windowSize |
	windowSize := 2 raisedTo: nu.
	(i < 1 or: [i > (windowSize // 2)]) ifTrue: [^ self error: 'index is out of range'].
	i = 1 ifTrue: [^ 0].  "the D.C. component"
	^ windowSize asFloat / (i - 1)

]

{ #category : #transforming }
FFT >> scaleData [
	"Scale all elements by 1/n when doing inverse"
	| realN |
	realN := n asFloat.
	1 to: n do:
		[:i |
		realData at: i put: (realData at: i) / realN.
		imagData at: i put: (imagData at: i) / realN]
]

{ #category : #'bulk processing' }
FFT >> setSize: anIntegerPowerOfTwo [
	"Initialize variables and tables for performing an FFT on the given number of samples. The number of samples must be an integral power of two (e.g. 1024). Prepare data for use with the fast primitive."

	self nu: (anIntegerPowerOfTwo log: 2) asInteger.
	n = anIntegerPowerOfTwo ifFalse: [self error: 'size must be a power of two'].
	sinTable := sinTable asFloat32Array.
	permTable := permTable asWordArray.
	realData := Float32Array new: n.
	imagData := Float32Array new: n.
	self initializeHammingWindow: 0.54.  "0.54 for Hamming, 0.5 for hanning"

]

{ #category : #testing }
FFT >> test [  "Display restoreAfter: [(FFT new nu: 8) test].  --  Test on an array of 256 samples"
	"Initialize to pure (co)Sine Wave, plot, transform, plot, invert and plot again"
	self realData: ((1 to: n) collect: [:i | (Float pi * (i-1) / (n/8)) cos]).
	self plot: realData in: (100@20 extent: 256@60).
	self transformForward: true.
	self plot: realData in: (100@100 extent: 256@60).
	self plot: imagData in: (100@180 extent: 256@60).
	self transformForward: false.
	self plot: realData in: (100@260 extent: 256@60)
]

{ #category : #'bulk processing' }
FFT >> transformDataFrom: anIndexableCollection startingAt: index [
	"Forward transform a block of real data taken from from the given indexable collection starting at the given index. Answer a block of values representing the normalized magnitudes of the frequency components."

	| j real imag out |
	j := 0.
	index to: index + n - 1 do: [:i |
		realData at: (j := j + 1) put: (anIndexableCollection at: i)].
	realData *= window.
	imagData := Float32Array new: n.
	self transformForward: true.

	"compute the magnitudes of the complex results"
	"note: the results are in bottom half; the upper half is just its mirror image"
	real := realData copyFrom: 1 to: (n / 2).
	imag := imagData copyFrom: 1 to: (n / 2).
	out := (real * real) + (imag * imag).
	1 to: out size do: [:i | out at: i put: (out at: i) sqrt].
	^ out

]

{ #category : #transforming }
FFT >> transformForward: forward [
	| lev lev1 ip theta realU imagU realT imagT i |
	<primitive: 'primitiveFFTTransformData' module: 'FFTPlugin'>
	self permuteData.
	1 to: nu do:
		[:level |
		lev := 1 bitShift: level.
		lev1 := lev // 2.
		1 to: lev1 do:
			[:j |
			theta := j-1 * (n // lev).   "pi * (j-1) / lev1 mapped onto 0..n/2"
			theta < (n//4)  "Compute U, the complex multiplier for each level"
				ifTrue:
					[realU := sinTable at: sinTable size - theta.
					imagU := sinTable at: theta + 1]
				ifFalse:
					[realU := (sinTable at: theta - (n//4) + 1) negated.
					imagU := sinTable at: (n//2) - theta + 1].
			forward ifFalse: [imagU := imagU negated].
"
			Here is the inner loop...
			j to: n by: lev do:
				[:i |   hand-transformed to whileTrue...
"
			i := j.
			[i <= n] whileTrue:
				[ip := i + lev1.
				realT := ((realData at: ip) * realU) - ((imagData at: ip) * imagU).
				imagT := ((realData at: ip) * imagU) + ((imagData at: ip) * realU).
				realData at: ip put: (realData at: i) - realT.
				imagData at: ip put: (imagData at: i) - imagT.
				realData at: i put: (realData at: i) + realT.
				imagData at: i put: (imagData at: i) + imagT.
				i := i + lev]]].
	forward ifFalse: [self scaleData]  "Reverse transform must scale to be an inverse"
]
