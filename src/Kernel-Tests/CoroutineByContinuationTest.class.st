Class {
	#name : #CoroutineByContinuationTest,
	#superclass : #CoroutineTest,
	#category : #'Kernel-Tests-Methods'
}

{ #category : #test }
CoroutineByContinuationTest >> coroutineOn: aBlock [

	^ CoroutineByContinuation on: aBlock
]
