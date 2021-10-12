"
I collaborate with `Coroutine` objects in order to apply context switches and do not waste the creation of many `BlockClosure`s for each resuming.
"
Class {
	#name : #CoroutineResume,
	#superclass : #Object,
	#instVars : [
		'coroutine'
	],
	#category : #'Kernel-Methods'
}

{ #category : #accessing }
CoroutineResume >> coroutine: anObject [

	coroutine := anObject
]

{ #category : #evaluating }
CoroutineResume >> value: aCoroutine value: aValue [

	coroutine swapContext: thisContext sender.
	
	^ aCoroutine value: aValue resumedByCoroutine: coroutine
]
