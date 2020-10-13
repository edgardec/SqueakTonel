Class {
	#name : #DialectStream,
	#superclass : #TextStream,
	#instVars : [
		'dialect',
		'colorTable'
	],
	#classVars : [
		'ST80ColorTable',
		'Sq00ColorTable'
	],
	#category : #'Etoys-Squeakland-System-Compiler'
}

{ #category : #'instance creation' }
DialectStream class >> dialect: dialectSymbol contents: blockWithArg [ 
	"Evaluate blockWithArg on a DialectStream of the given description"

	| stream |
	stream := self on: (Text new: 400).
	stream setDialect: dialectSymbol.
	blockWithArg value: stream.
	^ stream contents
]

{ #category : #'class initialization' }
DialectStream class >> initialize [
	"Initialize the color tables"

	self initializeST80ColorTable.
	self initializeSq00ColorTable.

"DialectStream initialize"

]

{ #category : #'class initialization' }
DialectStream class >> initializeST80ColorTable [
	"Initiialize the colors that characterize the ST80 dialect"

	ST80ColorTable := IdentityDictionary new.
	#(	(temporaryVariable blue italic)
		(methodArgument blue normal)
		(methodSelector black bold)
		(blockArgument red normal)
		(comment brown normal)
		(variable magenta normal)
		(literal	tan normal)
		(keyword darkGray bold)
		(prefixKeyword veryDarkGray bold)
		(setOrReturn black bold)) do:
			[:aTriplet |
				ST80ColorTable at: aTriplet first put: aTriplet allButFirst]

"DialectStream initialize"
]

{ #category : #'class initialization' }
DialectStream class >> initializeSq00ColorTable [
	"Initiialize the colors that characterize the Sq00 dialect"

	Sq00ColorTable := IdentityDictionary new.
	#(	(temporaryVariable black normal)
		(methodArgument black normal)
		(methodSelector black bold)
		(blockArgument black normal)
		(comment brown normal)
		(variable black normal)
		(literal	 blue normal)
		(keyword darkGray bold)
		(prefixKeyword veryDarkGray bold)
		(setOrReturn black bold)) do:
			[:aTriplet |
				Sq00ColorTable at: aTriplet first put: aTriplet allButFirst]
]

{ #category : #'color\/style' }
DialectStream >> colorTable [
	"Answer the table to use to determine colors"

	^ colorTable ifNil:
		[colorTable := dialect == #SQ00
			ifTrue:
				[Sq00ColorTable]
			ifFalse:
				[ST80ColorTable]]
]

{ #category : #access }
DialectStream >> dialect [

	^ dialect
]

{ #category : #access }
DialectStream >> setDialect: dialectSymbol [

	dialect := dialectSymbol
]

{ #category : #'color\/style' }
DialectStream >> withColor: colorSymbol emphasis: emphasisSymbol do: aBlock [
	"Evaluate the given block with the given color and style text attribute"

	^ self withAttributes: {TextColor color: (Color perform: colorSymbol).
							TextEmphasis perform: emphasisSymbol}
		do: aBlock
]

{ #category : #'color\/style' }
DialectStream >> withStyleFor: elementType do: aBlock [
	"Evaluate aBlock with appropriate emphasis and color for the given elementType"

	| colorAndStyle |
	colorAndStyle := self colorTable at: elementType.
	^ self withColor: colorAndStyle first emphasis: colorAndStyle second do: aBlock
]
