Class {
	#name : #BytecodeDecodingTests,
	#superclass : #LongTestCase,
	#category : #'Tests-Compiler'
}

{ #category : #tests }
BytecodeDecodingTests >> testPCPreviousTo [
	"Check that the pcPreviousTo machinery answers the truth for all bytecodes."
	self systemNavigation allSelect:
		[:m| | ec is prevPC prevBlockCreationPC exclude encoder extensionOffset |
		m isQuick ifFalse:
			[ec := m encoderClass.
			 is:= InstructionStream on: m.
			 exclude := OrderedCollection new.
			 m embeddedBlockClosures do:
				[:ebc| | bm followingpc |
				bm := ebc method. "Will differ for FullBlocks/SistaV1 regime"
				followingpc := ebc endPC + (ec bytecodeSize: (bm at: ebc endPC)).
				exclude addLast: ebc startpc; addLast: followingpc.
				self assert: nil
					equals: (ec pcPreviousTo: ebc startpc in: bm for: nil).
				bm isCompiledBlock  ifFalse:
					[self assert: (ec pcOfBlockCreationBytecodeForBlockStartingAt: ebc startpc in: m)
						equals: (ec pcPreviousTo: followingpc in: bm for: nil)]].
			encoder := m encoderClass.
			extensionOffset := 0.
			is scanFor:
				[:b|
				(exclude includes: is pc) ifFalse:
					[self assert: prevPC equals: (ec pcPreviousTo: is pc in: m for: nil)].
				prevPC := is pc - extensionOffset.
				extensionOffset := (encoder isExtension: is nextByte)
										ifTrue: [extensionOffset + 2]
										ifFalse: [0].
				b = ec createClosureCode ifTrue: [prevBlockCreationPC := prevPC].
				false]].
		 false]
]

{ #category : #tests }
BytecodeDecodingTests >> testWillReallyStore [
	"Check that the willReallyStore machinery answers the truth for all bytecodes."
	self systemNavigation allSelect:
		[:m| | is sawITV pnac |
		m isQuick ifFalse:
			[sawITV := false. pnac := m encoderClass pushNewArrayCode.
			 is:= InstructionStream on: m.
			 is scanFor:
				[:b|
				sawITV
					ifTrue:
						[self assert: (m encoderClass isSyntheticStoreAt: is pc in: m for: nil)]
					ifFalse:
						[self deny: (m encoderClass isSyntheticStoreAt: is pc in: m for: nil)].
				"The only bytecode following a pushNewArrayCode that creates an empty array should be a synthetic store."
				sawITV := b = pnac and: [is secondByte <= 127].
				false]].
		 false]
]
