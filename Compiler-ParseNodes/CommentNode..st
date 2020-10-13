Class {
	#name : #CommentNode,
	#superclass : #ParseNode,
	#category : #'Compiler-ParseNodes'
}

{ #category : #visiting }
CommentNode >> accept: aVisitor [
	^aVisitor visitCommentNode: self
]
