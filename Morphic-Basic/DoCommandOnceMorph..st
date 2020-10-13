"
I am used to execute a once-only command. My first use was in loading/saving the current project. In such cases it is necessary to be in another project to do the actual work. So an instance of me is added to a new world/project and that project is entered. I do my stuff (save/load followed by a re-enter of the previous project) and everyone is happy.
"
Class {
	#name : #DoCommandOnceMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'target',
		'command',
		'actionBlock',
		'innerArea'
	],
	#category : #'Morphic-Basic'
}

{ #category : #accessing }
DoCommandOnceMorph >> actionBlock: aBlock [

	actionBlock := aBlock
]

{ #category : #ui }
DoCommandOnceMorph >> addText: aString [

	| t |
	t := TextMorph new 
		beAllFont: (TextStyle default fontOfSize: 26);
		contents: aString.
	self extent: t extent * 3.
	innerArea := Morph new 
		color: Color white; 
		extent: self extent - (16@16);
		position: self position + (8@8);
		lock.
	self addMorph: innerArea. 
	self addMorph: (t position: self position + t extent; lock).
]

{ #category : #initialization }
DoCommandOnceMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color blue
]

{ #category : #initialization }
DoCommandOnceMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 8
]

{ #category : #initialization }
DoCommandOnceMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	
	self useRoundedCorners
]

{ #category : #initialization }
DoCommandOnceMorph >> openInWorld: aWorld [

	self position: aWorld topLeft + (aWorld extent - self extent // 2).
	super openInWorld: aWorld
]

{ #category : #'stepping and presenter' }
DoCommandOnceMorph >> step [

	| goForIt |

	actionBlock ifNil: [^self stopStepping].
	goForIt := actionBlock.
	actionBlock := nil.
	goForIt
		on: ProgressTargetRequestNotification
		do: [ :ex | ex resume: innerArea].		"in case a save/load progress display needs a home"

]

{ #category : #'stepping and presenter' }
DoCommandOnceMorph >> stepTime [

	^1

]

{ #category : #'stepping and presenter' }
DoCommandOnceMorph >> wantsSteps [

	^actionBlock notNil

]
