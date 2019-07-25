REBOL [
	Title:   "Regression tests script for Red Compiler"
	Author:  "Boleslav Březovský"
	File: 	 %regression-test-redc.r
	Rights:  "Copyright (C) 2016 Boleslav Březovský. All rights reserved."
	License: "BSD-3 - https://github.com/red/red/blob/origin/BSD-3-License.txt"
]


; cd %../
;--separate-log-file

~~~start-file~~~ "Red Compiler Regression tests part 5"

===start-group=== "Red regressions #2001 - #2500"

	; help functions for crash and compiler-problem detection
	true?: func [value] [not not value]
	crashed?: does [true? find qt/output "*** Runtime Error"]
	compiled?: does [true? not find qt/comp-output "Error"]
	script-error?: does [true? find qt/output "Script Error"]
	compiler-error?: does [true? find qt/comp-output "*** Compiler Internal Error"]
	compilation-error?: does [true? find qt/comp-output "*** Compilation Error"]
	loading-error: func [value] [found? find qt/comp-output join "*** Loading Error: " value]
	compilation-error: func [value] [found? find qt/comp-output join "*** Compilation Error: " value]
	syntax-error: func [value] [found? find qt/comp-output join "*** Syntax Error: " value]
	script-error: func [value] [found? find qt/output join "*** Script Error: " value]
	; -test-: :--test--
	; --test--: func [value] [probe value -test- value]

	--test-- "#2007"
		; NOTE: without View support `make image!` produces a runtime error
		--compile-and-run-this-red {make image! 0x0}
		--assert not crashed?

	--test-- "#2027"
		--compile-and-run-this-red {do [a: func [b "b var" [integer!]][b]]}
		--assert script-error "invalid function definition"

	; --test-- "#2133"
	;	FIXME: still OPEN
	; 	--compile-and-run/pgm %tests/source/units/issue-2133.red
	; 	--assert not crashed?

	--test-- "#2137"
		--compile-and-run-this-red {repeat n 56 [to string! debase/base at form to-hex n + 191 7 16]}
		--assert not crashed?

	--test-- "#2143"
		--compile-and-run-this-red {
do [
	ts: [test: 10]
	t-o: object []
	make t-o ts		
]
}
		--assert not crashed?

	--test-- "#2159"
		--compile-and-run-this-red {append #{} to-hex 20}
		--assert not crashed?

	--test-- "#2162"
		--compile-and-run-this-red {write/info https://api.github.com/user [GET [User-Agent: "me"]]}
		--assert not crashed?

	--test-- "#2173"
		--compile-and-run-this-red {not parse [] [help]}
		--assert not crashed?

	--test-- "#2179"
		--compile-and-run-this-red {
test: none
parse ["hello" "world"] ["hello" set test opt "world"]
test
parse ["hello"] ["hello" set test opt "world"]
test
parse ["hello"] ["hello" set test any "world"]
test
}
		--assert not crashed?

	--test-- "#2182"
		--compile-and-run-this-red {sym: 10 forall sym []}
		--assert not crashed?

	--test-- "#2214"
		; NOTE: without View support `make image!` produces a runtime error
		--compile-and-run-this-red {make image! []}
		--assert not crashed?

	;; #2438 --> see %load-test.red

===end-group===


===start-group=== "Red regressions #2501 - #3000"

	;; for this test it doesn't matter if it errors out or returns a pair
	--test-- "#2538"
		--compile-and-run-this-red {probe system/console/size}
		--assert not crashed?

===end-group===

; ===start-group=== "Red regressions #3001 - #3500"
; ===end-group===

===start-group=== "Red regressions #3501 - #4000"
	
	;; for this test it doesn't matter if it errors out or outputs a result
	--test-- "#3714"
		
		--compile-and-run-this-red {probe system/view/metrics/dpi}
		--assert not crashed?
		
		--compile-and-run-this-red {probe system/view/screens/1/size}
		--assert not crashed?
		
		--compile-and-run-this-red {
			print mold/flat/part system/console 100
			print mold/flat/part system/console/size 100
		}
		--assert not crashed?


	--test-- "#3733"
		--compile-and-run-this-red {f: does [1] do [f/q]}
		--assert not crashed?
		--assert script-error?

		;; FIXME: this should not error out when compiled:
		--compile-and-run-this-red {
			do [f: func [/q] bind [1] context []]
			f/q
		}
		--assert not crashed?
		; --assert not script-error?

; FIXME: cannot test this until compile-time macros will be expanded by Red, not Rebol	
;	--test-- "#3773"
;		;; see the same triad interpreted in regression-test-red.red...
;
;		;; context? should not accept a string
;		--compile-and-run-this-red {
;			#macro ctx: func [x] [context? x]
;			ctx ""
;		}
;		--assert compiler-error?
;
;		;; this is reduced like: (mc 'mc) => (mc) => error (no arg)
;		--compile-and-run-this-red {
;			#macro mc: func [x] [x]
;			probe quote (mc 'mc)
;		}
;		--assert compiler-error?
;
;		;; :mc = func [x][x], so `mc :mc` executing `x` applies it to an empty arg list => error
;		--compile-and-run-this-red {
;			#macro mc: func [x] [x]
;			probe quote (mc :mc)
;		}
;		--assert compiler-error?


	--test-- "#3831"
		--compile-and-run-this-red {repeat x none []}
		--assert not crashed?
		--assert script-error?

		--compile-and-run-this-red {loop none []}
		--assert not crashed?
		--assert script-error?


	--test-- "#3866"
		--compile-and-run-this-red {
			f: func [x [string!]][probe x]
			f 1
		}
		--assert not crashed?
		--assert script-error?


	--test-- "#3876"
		--compile-and-run-this-red {
			count: 0.0
			vec-size: 100.0
			vec: make vector! [float! 64 100]
			count: count + 1.0
			print count
			print vec/:count
			val: (1.012345 * (count / vec-size))
			print val
			vec/:count: val
		}
		--assert not crashed?
		--assert script-error?


	--test-- "#3891"
		--compile-and-run-this-red {probe load "a<=>"}
		--assert not crashed?
		--assert syntax-error "invalid value"


===end-group===

~~~end-file~~~ 
