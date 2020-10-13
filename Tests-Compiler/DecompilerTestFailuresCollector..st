"
(| dtfc |
dtfc := DecompilerTestFailuresCollector new.
(dtfc class superclass organization listAtCategoryNamed: #tests) do:
	[:s| dtfc perform: s].
dtfc failures)

(Transcript nextPut: ${.
self do: [:mr| Transcript print: mr actualClass; nextPut: $.; space; store: mr methodSymbol; nextPut: $.; cr; flush].
Transcript nextPut: $}; flush)

eem 12/24/2017 11:05
#(#BrowserCommentTextMorph #showPane #SyntaxErrorNotification)
#(#CodeHolder #getSelectorAndSendQuery:to:with: #SyntaxErrorNotification)
#(#DecompilerTests #testDecompileUnreachableParameter #Error)
#(#MVCToolBuilder #setLayout:in: #SyntaxErrorNotification)
#(#PNGReadWriter #copyPixelsGray: #SyntaxErrorNotification)
#(#SHMCClassDefinition #withAllSuperclassesDo: #SyntaxErrorNotification)

eem 7/1/2009 16:13
{AdditionalMethodState. #keysAndValuesDo:.
AdditionalMethodState. #propertyKeysAndValuesDo:.
AdditionalMethodState. #at:ifAbsent:.
AdditionalMethodState. #removeKey:ifAbsent:.
AdditionalMethodState. #at:ifAbsentPut:.
AdditionalMethodState. #setMethod:.
AdditionalMethodState. #at:put:.
AdditionalMethodState. #pragmas.
AdditionalMethodState. #includesProperty:.
AdditionalMethodState. #properties.
AdditionalMethodState. #hasLiteralSuchThat:.
AdditionalMethodState. #propertyValueAt:ifAbsent:.
AdditionalMethodState. #hasLiteralThorough:.
Array. #hasLiteralSuchThat:.
BitBltSimulation. #initDither8Lookup.
BlockNode. #sizeCodeExceptLast:.
BlockNode. #emitCodeExceptLast:encoder:.
Categorizer. #changeFromCategorySpecs:.
Categorizer. #elementCategoryDict.
CColorPicker. #colors:.
CCustomDrawListCostume. #drawListOn:in:.
ChangeList. #browseCurrentVersionsOfSelections.
ClosureTests. #testToDoInsideTemp.
Cogit. #computeMaximumSizes.
Cogit. #outputInstructionsAt:.
Cogit. #generateMapAt:start:.
CogVMSimulator. #printFrameThing:at:.
CogVMSimulator. #str:n:cmp:.
CoInterpreter. #validStackPageBaseFrames.
CoInterpreter. #markAndTraceTraceLog.
CoInterpreter. #mapTraceLog.
CoInterpreter. #checkStackIntegrity.
CoInterpreter. #mapStackPages.
CoInterpreter. #updateStackZoneReferencesToCompiledCodePreCompaction.
CoInterpreter. #ceActivateFailingPrimitiveMethod:.
CoInterpreterStackPages. #initializeStack:numSlots:pageSize:stackLimitOffset:stackPageHeadroom:.
CompiledMethod. #=.
CompiledMethod. #getPreambleFrom:at:.
CompiledMethod. #hasLiteralThorough:.
CompiledMethod. #hasLiteralSuchThat:.
CPopUpMenuCostume. #drawMenu:on:in:.
CroquetParticipant. #dropFiles:.
CTextParagraph. #selectionRectsFrom:to:.
CWheelWidgetCostume. #drawOn:in:.
Dictionary. #scanFor:.
Float. #printPaddedWith:to:.
FMSound. #mixSampleCount:into:startingAt:leftVol:rightVol:.
Form. #transformColors:.
FTPClient. #getDataInto:.
GIFReadWriter. #nextImageWithPlugin.
GraphMorph. #drawDataOn:.
GZipReadStream. #on:from:to:.
HTTPServiceDispatcher. #errorReportFor:stack:on:.
HttpUrl. #checkAuthorization:retry:.
Integer. #benchSwitch:.
Interpreter. #primitiveClosureValueWithArgs.
Interpreter. #primitivePerformAt:.
Interpreter. #primitiveDoPrimitiveWithArgs.
Interpreter. #primitiveNewMethod.
InterpreterStackPages. #initializeStack:numSlots:pageSize:stackLimitOffset:stackPageHeadroom:.
JPEGReadWriter. #decodeBlockInto:component:dcTable:acTable:.
KeyedIdentitySet. #scanFor:.
KeyedSet. #scanFor:.
LargeIntegersPlugin. #isNormalized:.
LargeIntegersPlugin. #cBytesCopyFrom:to:len:.
LargeIntegersPlugin. #cDigitMultiply:len:with:len:into:.
LiteralDictionary. #scanFor:.
LoopedSampledSound. #mixSampleCount:into:startingAt:leftVol:rightVol:.
MethodDictionary. #scanFor:.
MP4BoxInfoParser. #parseMP4BoxOutput:.
MP4BoxNHMLTrack. #computeDTSDeltas.
MultiByteBinaryOrTextStream. #next:.
MultiByteFileStream. #next:.
MViewPane. #reconstructEnabledDocuments.
MViewPane. #reconstructOpenDocuments.
MViewPane. #reconstructSelectionList.
NewParagraph. #selectionRectsFrom:to:.
Object. #instanceFields.
OldSocket. #getResponseNoLF.
PasteUpMorph. #dropFiles:.
PlotMorphGrid. #bestStep:.
PluckedSound. #reset.
PluggableDictionary. #scanFor:.
PluggableSet. #scanFor:.
PluggableTabButtonMorph. #calculateArcLengths.
PluggableTabButtonMorph. #drawTabOn:.
PNGReadWriter. #copyPixelsGray:.
PNMReadWriter. #readPlainRGB.
PNMReadWriter. #readBWreverse:.
PNMReadWriter. #nextPutRGB:.
PNMReadWriter. #nextPutBW:reverse:.
PopUpMenu. #readKeyboard.
QFloorFan. #initialize.
QMinimalForum. #demoDesksUnused.
QNetVidReorderingBuffer. #popFramesForCTS:.
QNetVidTrackStreamer. #sampleIndexWithCTS:.
QServiceProvider. #statusReport.
QServicesPane. #forumMenuInto:.
QUserListItem. #drawOn:in:.
QVMProfiler. #computeHistograms:.
QVMProfiler. #selectSymbolsInRange.
QwaqParticipantUI. #onDropFiles:.
RelativeInstructionPrinter. #print:.
RemoteHandMorph. #appendNewDataToReceiveBuffer.
SchizophrenicClosureFormatStackInterpreter. #primitiveClosureValueWithArgs.
Set. #do:.
Set. #scanFor:.
SHParserST80. #isBinary.
ShootoutMall. #processVisitors.
ShortIntegerArray. #writeOn:.
SparseLargeArray. #analyzeSpaceSaving.
StackInterpreter. #validStackPageBaseFrames.
StackInterpreter. #divorceAllFrames.
StackInterpreter. #checkStackIntegrity.
StackInterpreter. #primitiveDoPrimitiveWithArgs.
StackInterpreter. #reverseDisplayFrom:to:.
StackInterpreter. #printOop:.
StackInterpreter. #mapStackPages.
StackInterpreter. #primitiveNewMethod.
StackInterpreter. #primitiveClosureValueWithArgs.
StrikeFontSet. #displayStringR2L:on:from:to:at:kern:.
String. #howManyMatch:.
Text. #asHtmlFragmentTextStyle:useBreaks:.
TextURL. #actOnClickFor:.
TFractalTerrain. #heightAt:.
TFractalTerrain. #makeFaces.
TFractalTerrain. #makeVertices.
TFractalTerrain. #makeTextureUV.
TFractalTerrain. #makeVertexNormals.
TFrame. #computeUnionSphere.
TMethod. #emitCCommentOn:.
TRFBStreamOutput. #handleRequest:.
TTCFontReader. #processCharacterMappingTable:.
TTContourConstruction. #segmentsDo:.
TTensor. #projectionIntegrate:.
TTFontReader. #processHorizontalMetricsTable:length:.
TTFontReader. #processCharacterMappingTable:.
TWaves. #step.
Vector. #copyFrom:.
Vector. #asVector3.
VectorColor. #copyFrom:.
WeakKeyDictionary. #scanForNil:.
WeakKeyDictionary. #scanFor:.
WeakSet. #scanFor:.
WeakSet. #scanForLoadedSymbol:.
}
"
Class {
	#name : #DecompilerTestFailuresCollector,
	#superclass : #DecompilerTests,
	#instVars : [
		'failures'
	],
	#category : #'Tests-Compiler'
}

{ #category : #'as yet unclassified' }
DecompilerTestFailuresCollector class >> isAbstract [

	^ true
]

{ #category : #accessing }
DecompilerTestFailuresCollector >> assert: aBoolean description: aString resumable: resumableBoolean [

	| method |
	aBoolean ifTrue: [ ^self ].
	method := thisContext sender home tempAt: 1.
	self noteFailure: TestFailure for: method
]

{ #category : #utilities }
DecompilerTestFailuresCollector >> checkDecompileMethod: oldMethod [
	
	[ super checkDecompileMethod: oldMethod ]
		on: Error
		do: [ :error | self noteFailure: error class for: oldMethod ]
]

{ #category : #accessing }
DecompilerTestFailuresCollector >> computeFailures [
	
	| tests |
	failures := nil.
	tests := (DecompilerTests organization listAtCategoryNamed: #tests) select: [ :s |
		(s beginsWith: 'testDecompilerInClasses') ].
	CurrentReadOnlySourceFiles cacheDuring: [
		tests
			do: [ :each | self perform: each ]
			displayingProgress: 'Computing failures...' ].
	^self decompilerFailures
]

{ #category : #accessing }
DecompilerTestFailuresCollector >> decompilerFailures [

	failures ifNil: [ ^#() ].
	^failures asArray sort: [ :a :b |
		| r |
		r := a first compare: b first caseSensitive: false.
		r = 1 or: [ r = 2 and: [
			(a second compare: b second caseSensitive: false) <= 2 ] ] ]
]

{ #category : #accessing }
DecompilerTestFailuresCollector >> errorClassForFailureFor: class selector: selector [

	^nil
]

{ #category : #utilities }
DecompilerTestFailuresCollector >> exceptionClassForFailureFor: class  selector: selector [
	
	^nil
]

{ #category : #accessing }
DecompilerTestFailuresCollector >> failures [
	^failures
]

{ #category : #utilities }
DecompilerTestFailuresCollector >> noteFailure: exceptionClass for: method [

	(failures ifNil: [ failures := OrderedCollection new ]) add: {
		method methodClass name.
		method selector.
		exceptionClass name }
]
