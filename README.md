jsruntime.vim (Javascript runtime in Vim)
=============

It use [PyV8](http://code.google.com/p/pyv8/) as javascript interpreter. if PyV8 not supported, it use node, cscript, spiderMonkey as fallbacks. 

Usage
-------------

It provide the following functions

1. b:jsruntimeEvalScript({script}, {renew_context})

        :echo b:jsruntimeEvalScript('1+2')
        // output 3
    
   renew_context is a flag to indicate whether keep the context created by script before
        
        :call b:jsruntimeEvalScript('a=3')  // we create a context
        :echo b:jsruntimeEvalScript('a;') // we eval this script in context created before
        // output 1
        :call b:jsruntimeEvalScript('a;',1) // we eval this script in new context
        // output undefined

2. b:jsruntimeEvalScriptInBrowserContext

        :call b:jsruntimeEvalScriptInBrowserContext('<html><body onload="console.log(1+2);"><p></p></body></html>')
        //output 3
