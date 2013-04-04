jsruntime.vim (Run javascript code directly in Vim)
=============

It use [PyV8](http://code.google.com/p/pyv8/) as javascript interpreter. if PyV8 not supported, it use node, cscript, spiderMonkey as fallbacks. 

Installation
-------------

Copy everything inside autoload to __autoload__ directory of your vim

Note
----
It is a basic library. It does nothing if no other plugin calls it. If you are a vim plugin developer and want to use this library.
You need to check if this library exist

        try
            call javascript#runtime#evalScript("")
            let jsruntimePluginAvailable = 1
        catch E117
            let jsruntimePluginAvailable = 0
        endtry
        
        if jsruntimePluginAvailable
            " your code
        endif

This library is often used with [jsoncodecs.vim](https://github.com/michalliu/jsoncodecs.vim).

        javascript#runtime#evalScript(jsoncodecs#dump_string(getline(1,'$')))

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
   
    renew\_context is not guaranteed support, if not support renew\_context will be simply ignored, please

    read __javascript\#runtime\#supportLivingContext__ for more.
    
2. javascript\#runtime\#evalScriptInBrowserContext    

   because we only implement browser interface using PyV8, so if PyV8 is not supported, this function will not exist, check existence before use
        
        // vim script
        if exists('javascript#runtime#evalScriptInBrowserContext')
            // do what you like
        endif

    sample
    
        :call javascript#runtime#evalScriptInBrowserContext('<html><body onload="console.log(1+2);"><p></p></body></html>')
        //output 3

3. javascript\#runtime\#isSupportLivingContext    

    you can use __javascript\#runtime\#isSupportLivingContext__ to check whether living_context is supported by jsruntime
