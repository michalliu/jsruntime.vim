jsruntime.vim (Javascript runtime in Vim)
=============

It use [PyV8](http://code.google.com/p/pyv8/) as javascript interpreter. if PyV8 not supported, it use node, cscript, spiderMonkey as fallbacks. 

Usage
-------------

It provide the following functions

1. b:jsruntimeEvalScript

        :echo b:jsruntimeEvalScript('1+2')
        //output 3

2. b:jsruntimeEvalScriptInBrowserContext

        :call b:jsruntimeEvalScriptInBrowserContext('<html><body onload="console.log(1+2);"><p></p></body></html>')
        //output 3
