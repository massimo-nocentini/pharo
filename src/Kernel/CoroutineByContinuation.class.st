"
A CoroutineCont is a coroutine.

Instance Variables
	block:		<Object>
	cont:		<Object>
	first:		<Object>

block
	- block that contains the coroutine code

cont
	- continuation where the coroutine stopped execution

"
Class {
	#name : #CoroutineByContinuation,
	#superclass : #Coroutine,
	#category : #'Kernel-Methods'
}

{ #category : #accessing }
CoroutineByContinuation >> value: aValue [

	^ cont
		  ifNil: [ 
			  block
				  cull: [ :coroutine :value | 
					  Continuation currentDo: [ :executionFlow | 
						  self swapContext: executionFlow.
						  coroutine value: value ] ]
				  cull: aValue
				  cull: self ]
		  ifNotNil: [ 
			  | contTmp |
			  contTmp := self swapContext: nil.
			  contTmp value: aValue ]
]
