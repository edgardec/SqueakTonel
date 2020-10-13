Class {
	#name : #PackageAPIHelpBuilder,
	#superclass : #HelpBuilder,
	#category : #'HelpSystem-Core-Builders'
}

{ #category : #building }
PackageAPIHelpBuilder >> build [ 
	|pTopic|
	topicToBuild := (HelpTopic named: rootToBuildFrom bookName).
	rootToBuildFrom packages do: [:package|
		pTopic := HelpTopic named: package.
		topicToBuild addSubtopic: pTopic.
		self buildPackageTopic: pTopic.
		
	]

]

{ #category : #building }
PackageAPIHelpBuilder >> buildPackageTopic: pTopic [

	(PackageInfo named: pTopic title) classes
		sort: [ :cl1 :cl2 | cl1 name < cl2 name ];
		do: [ :aClass| 
			| classTopic |
			classTopic := ClassAPIHelpBuilder
				buildHierarchicalHelpTopicFrom: aClass
				withSubclasses: false
				withMethods: true.
			pTopic addSubtopic: classTopic ]
]
