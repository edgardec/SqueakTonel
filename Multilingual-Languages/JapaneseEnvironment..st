"
This class provides the Japanese support.  Since it has been used most other than default 'latin-1' languages, this tends to be a good place to look at when you want to know what a typical subclass of LanguageEnvironment should do.

"
Class {
	#name : #JapaneseEnvironment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-Languages'
}

{ #category : #'subclass responsibilities' }
JapaneseEnvironment class >> clipboardInterpreterClass [
	| platformName osVersion |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	platformName = 'Win32' ifTrue: [^UTF8ClipboardInterpreter].
	platformName = 'Mac OS' ifTrue: [^MacShiftJISClipboardInterpreter].
	^platformName = 'unix' 
		ifTrue: 
			[(ShiftJISTextConverter encodingNames includes: X11Encoding getEncoding) 
				ifTrue: [MacShiftJISClipboardInterpreter]
				ifFalse: [UnixJPClipboardInterpreter]]
		ifFalse: [ NoConversionClipboardInterpreter ]
]

{ #category : #'public query' }
JapaneseEnvironment class >> defaultEncodingName [
	| platformName osVersion |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	(#('Win32' 'ZaurusOS') includes: platformName) ifTrue: [^'shift-jis'].
	platformName = 'Mac OS' 
		ifTrue: 
			[^('10*' match: osVersion) 
				ifTrue: ['utf-8']
				ifFalse: ['shift-jis']].
	^'unix' = platformName ifTrue: ['euc-jp'] ifFalse: ['mac-roman']
]

{ #category : #'subclass responsibilities' }
JapaneseEnvironment class >> fileNameConverterClass [

	^ self systemConverterClass.

]

{ #category : #'language methods' }
JapaneseEnvironment class >> flapTabTextFor: aString in: aFlapTab [

	| string |
	string := super flapTabTextFor: aString.
	string isEmptyOrNil ifTrue: [^ self].
	string := aFlapTab orientation == #vertical
				ifTrue: [string copyReplaceAll: 'ー' with: '｜']
				ifFalse: [string copyReplaceAll: '｜' with: 'ー'].

	^ string.

]

{ #category : #'language methods' }
JapaneseEnvironment class >> fromJISX0208String: aString [

	^ aString collect: [:each | Character leadingChar: JapaneseEnvironment leadingChar code: (each asUnicode)].

]

{ #category : #'subclass responsibilities' }
JapaneseEnvironment class >> inputInterpreterClass [
	| platformName osVersion encoding |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	platformName = 'Win32'
		ifTrue: [^ (self win32VMUsesUnicode) ifTrue: [UTF32JPInputInterpreter] ifFalse: [WinShiftJISInputInterpreter]].
	platformName = 'Mac OS'
		ifTrue: [^ (('10*' match: osVersion)
					and: [(Smalltalk getSystemAttribute: 3) isNil])
				ifTrue: [MacUnicodeInputInterpreter]
				ifFalse: [MacShiftJISInputInterpreter]].
	platformName = 'unix'
		ifTrue: [encoding := X11Encoding encoding.
			(EUCJPTextConverter encodingNames includes: encoding)
				ifTrue: [^ UnixEUCJPInputInterpreter].
			(UTF8TextConverter encodingNames includes: encoding)
				ifTrue: [^ UnixUTF8JPInputInterpreter].
			(ShiftJISTextConverter encodingNames includes: encoding)
				ifTrue: [^ MacShiftJISInputInterpreter]].
	^ MacRomanInputInterpreter
]

{ #category : #'rendering support' }
JapaneseEnvironment class >> isBreakableAt: index in: text [

	| prev |
	index = 1 ifTrue: [^ false].
	prev := text at: index - 1.
	prev leadingChar ~= JapaneseEnvironment leadingChar ifTrue: [^ true].
	^ (('、。，．・：；？！゛゜´｀¨＾―‐／\〜‖｜…‥’”）〕］｝〉》」』】°′″℃' includes: (text at: index)) or: ['‘“（〔［｛〈《「『【°′″℃＠§' includes: prev]) not.

]

{ #category : #'subclass responsibilities' }
JapaneseEnvironment class >> leadingChar [

	^ 5.

]

{ #category : #'language methods' }
JapaneseEnvironment class >> scanMultibyteCharactersFrom: startIndex to: stopIndex in: aWideString with: aCharacterScanner rightX: rightX font: aFont [
	"scanning multibyte Japanese strings"
	^aFont scanMultibyteJapaneseCharactersFrom: startIndex to: stopIndex in: aWideString with: aCharacterScanner rightX: rightX
]

{ #category : #'subclass responsibilities' }
JapaneseEnvironment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	
	^#('ja' 'ja-etoys' )
]

{ #category : #'subclass responsibilities' }
JapaneseEnvironment class >> systemConverterClass [
	| platformName osVersion encoding |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	platformName = 'Win32'
		ifTrue: [^UTF8TextConverter].
	platformName = 'ZaurusOS'
		ifTrue: [^ShiftJISTextConverter].
	platformName = 'Mac OS' 
		ifTrue: 
			[^('10*' match: osVersion) 
				ifTrue: [UTF8TextConverter]
				ifFalse: [ShiftJISTextConverter]].
	platformName = 'unix' 
		ifTrue: 
			[encoding := X11Encoding encoding.
			encoding ifNil: [^EUCJPTextConverter].
			(encoding = 'utf-8') 
				ifTrue: [^UTF8TextConverter].				
			(encoding = 'shiftjis' or: [ encoding = 'sjis' ]) 
				ifTrue: [^ShiftJISTextConverter].				
			^EUCJPTextConverter].
	^MacRomanTextConverter
]

{ #category : #'language methods' }
JapaneseEnvironment class >> traditionalCharsetClass [

	^ JISX0208.

]
