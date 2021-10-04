"
I am an utility class to support `TSeasonedSchemerContinuationTest>>#testTwoInARow`.
"
Class {
	#name : #TwoInARowStar,
	#superclass : #Object,
	#instVars : [
		'leave',
		'fill',
		'testCase'
	],
	#category : #'Kernel-Tests-Methods'
}

{ #category : #API }
TwoInARowStar >> T: anObj [
	| n |
	n := self getNext: anObj.
	^ n isNotNil
		ifTrue: [ n = anObj or: [ self T: n ] ]
		ifFalse: [ false ]
]

{ #category : #API }
TwoInARowStar >> getNext: previousObj [

	^ testCase callcc: [ :here_again | 
		  leave := here_again.
		  fill value: previousObj ]
]

{ #category : #accessing }
TwoInARowStar >> testCase: aTest [

	testCase := aTest
]

{ #category : #API }
TwoInARowStar >> tree: aTree [

	| fst |
	fst := testCase callcc: [ :here | 
		       leave := here.
		       self waddle: aTree.
		       leave value: nil ].
	^ fst isSymbol
		  ifTrue: [ self T: fst ]
		  ifFalse: [ false ]
]

{ #category : #API }
TwoInARowStar >> waddle: aTree [

	^ (aTree isNotNil and: [ aTree isMemberOf: ValueLink ]) ifTrue: [ 
		  | car cdr |
		  car := aTree value.
		  cdr := aTree nextLink.
		  (car isKindOf: Link)
			  ifTrue: [ self waddle: car ]
			  ifFalse: [ 
				  testCase callcc: [ :rest | 
					  fill := rest.
					  leave value: car ] ].
		  self waddle: cdr ]
]
