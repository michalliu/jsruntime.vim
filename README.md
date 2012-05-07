jsruntime.vim (Javascript runtime in Vim)
=============

It use [PyV8](http://code.google.com/p/pyv8/) as javascript interpreter. if PyV8 not supported, it use node, cscript, spiderMonkey as fallbacks. 

Documentation
-------------

It provide the following functions

1. b:jsruntimeEvalScript({script}, {renew_context})

        :echo b:jsruntimeEvalScript('1+2')
        // output 3
    
    __renew\_context__ is a flag to indicate whether keep the context created by script before
        
        :call b:jsruntimeEvalScript('a=3')  // we create a context
        :echo b:jsruntimeEvalScript('a;') // we eval this script in context created before
        // output 1
        :echo b:jsruntimeEvalScript('a;',1) // we eval this script in new context
        // output undefined
   
    renew\_context is not guaranteed support, if not support renew\_context will always be 1.
    
    you can use __b:jsruntime_support_living_context__ to check whether living_context is support

2. b:jsruntimeEvalScriptInBrowserContext
    
    because we only implement browser interface using PyV8, so if PyV8 is not supported, this function will not exist, check existence before use
        
        // vim script
        if exists('b:jsruntimeEvalScriptInBrowserContext')
            // do what you like
        endif

    sample
    
        :call b:jsruntimeEvalScriptInBrowserContext('<html><body onload="console.log(1+2);"><p></p></body></html>')
        //output 3