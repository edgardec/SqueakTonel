Class {
	#name : #ColoredCodeStream,
	#superclass : #TextStream,
	#instVars : [
		'dialect',
		'colorTable'
	],
	#classVars : [
		'ST80ColorTable'
	],
	#category : #'Compiler-Kernel'
}

{ #category : #'instance creation' }
ColoredCodeStream class >> contents: blockWithArg [ 
	"Evaluate blockWithArg on a DialectStream of the given description"

	| stream |
	stream := self on: (Text new: 400).
	blockWithArg value: stream.
	^ stream contents
]

{ #category : #'class initialization' }
ColoredCodeStream class >> initialize [
	"Initialize the colors that characterize the ST80 dialect"

	ST80ColorTable := IdentityDictionary new.
	#(	(temporaryVariable blue italic)
		(methodArgument blue normal)
		(methodSelector black bold)
		(blockArgument red normal)
		(comment brown normal)
		(variable magenta normal)
		(literal	orange normal)
		(keyword darkGray bold)
		(prefixKeyword veryDarkGray bold)
		(setOrReturn black bold)) do:
			[:aTriplet |
				ST80ColorTable at: aTriplet first put: aTriplet allButFirst]

"ColoredCodeStream initialize"
]

{ #category : #'color\/style' }
ColoredCodeStream >> colorTable [
	"Answer the table to use to determine colors"

	^ colorTable ifNil: [colorTable := ST80ColorTable]
]

{ #category : #'color\/style' }
ColoredCodeStream >> withColor: colorSymbol emphasis: emphasisSymbol do: aBlock [
	"Evaluate the given block with the given color and style text attribute"

	^ self withAttributes: {TextColor color: (Color perform: colorSymbol).
							TextEmphasis perform: emphasisSymbol}
		do: aBlock
]

{ #category : #'color\/style' }
ColoredCodeStream >> withStyleFor: elementType do: aBlock [
	"Evaluate aBlock with appropriate emphasis and color for the given elementType"

	| colorAndStyle |
	colorAndStyle := self colorTable at: elementType.
	^ self withColor: colorAndStyle first emphasis: colorAndStyle second do: aBlock
]
