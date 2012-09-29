jsruntime.vim (Javascript runtime in Vim)
=============

It use [PyV8](http://code.google.com/p/pyv8/) as javascript interpreter. if PyV8 not supported, it use node, cscript, spiderMonkey as fallbacks. 

Installation
-------------

Copy everything inside autoload to __autoload__ directory of your vim

Documentation
-------------

It provide the following functions

1. javascript#runtime#evalScript({script}, {renew_context})

        :echo javascript#runtime#evalScript('1+2')
        // output 3
    
    __renew\_context__ is a flag to indicate whether keep the context created by script before
        
        :call javascript#runtime#evalScript('a=3')  // we create a context
        :echo javascript#runtime#evalScript('a;') // we eval this script in context created before
        // output 1
        :echo javascript#runtime#evalScript('a;',1) // we eval this script in a completely new context
        // output undefined
   
    renew\_context is not guaranteed support, if not support renew\_context will be ignored
    
    you can use __javascript\#runtime\#supportLivingContext__ to check whether living_context is support

2. javascript\#runtime\#evalScriptInBrowserContext    

   because we only implement browser interface using PyV8, so if PyV8 is not supported, this function will not exist, check existence before use
        
        // vim script
        if exists('javascript#runtime#evalScriptInBrowserContext')
            // do what you like
        endif

    sample
    
        :call javascript#runtime#evalScriptInBrowserContext('<html><body onload="console.log(1+2);"><p></p></body></html>')
        //output 3
