" Maintainer: yf.liu <sophia.smth@gmail.com>
" Description: javascript runtime in vim powered by google V8 and PyV8 http://code.google.com/p/pyv8/
"
" Version: 1.0

let s:save_cpo = &cpo
set cpo&vim

" plugin path
let s:install_dir = expand("<sfile>:p:h")

" See if we have python and PyV8 is installed
let s:python_support = 0

if has('python')
    python << EOF
import sys,os,vim
#if sys.version_info[:2] < (2,7):
#    vim.command("jsruntime.vim complains \"Vim must be compiled with Python 2.7, you have %s\"" % sys.version)
sys.path.insert(0, vim.eval('s:install_dir'))

try:
  # PyV8 js runtime use minimal namespace to avoid conflict with other plugin
  import platform
  if platform.system() == "Darwin":
    from PyV8Mac import PyV8
  else:
    from PyV8 import PyV8
  vim.command('let s:python_support = 1')
except ImportError,e:
    err = str(e)
    if err.startswith("libboost_python.so.1.50.0"):
        print "Hint:" 
        print "(PyV8) - A Javascript interpreter can be enabled by execute the follwing command"
        print " "
        print "sudo ln -s %s /usr/lib" % os.path.join(vim.eval("s:install_dir"),'PyV8','libboost_python.so.1.50.0')
        print " "
    else:
        print "PyV8 is not supported "
        print e
EOF
endif

if s:python_support
    python << EOF
import re
class VimJavascriptConsole(PyV8.JSClass):

    def __init__(self):
        pass

    def _out(self,obj,name=''):
        if not obj:
            obj = "undefined"
        print '%s%s' % (name,obj)

    def log(self, obj='', *args):
        # console.log("%s%s",1,2) should output '12'
        # console.log("%s") should output '%s' without errors
        try:
            output = str(obj) % args
        except:
            output = str(obj)
        return self._out(output,name="LOG: ")

    def debug(self, obj='', *args):
        try:
            output = str(obj) % args
        except:
            output = str(obj)
        return self._out(output,name="DEBUG: ")

    def info(self, obj='', *args):
        try:
            output = str(obj) % args
        except:
            output = str(obj)
        return self._out(output,name="INFO: ")

    def warn(self, obj='', *args):
        try:
            output = str(obj) % args
        except:
            output = str(obj)
        return self._out(output,name="WARN: ")

    def error(self, obj='', *args):
        try:
            output = str(obj) % args
        except:
            output = str(obj)
        return self._out(output,name="ERROR: ")

    def trace(self, *args):
        pass

class VimJavascriptRuntime(PyV8.JSClass):

    def __init__(self):
        self._console = VimJavascriptConsole()

    def alert(self, msg):
        """Displays an alert box with a message and an OK button"""
        if not msg:
            msg = "undefined"
        print "ALERT: ", msg

    @property
    def console(self):
        return self._console

    @property
    def context(self):
        if not hasattr(self,"_context"):
            self._context = PyV8.JSContext(self)
            self._context.enter()
        return self._context

    def evalScript(self, script):
        if not isinstance(script, unicode):
            script = unicode(script, vim.eval("&encoding"))
        # pyv8 likes unicode
        # script = script.encode("utf-8")
        with self.context as ctxt:
            return ctxt.eval(script)

# vim javascript runtime instance
jsRuntimeVim = VimJavascriptRuntime()

# PyV8 js runtime in browser context
# Think a tab in a real browser
import PyWebBrowser.w3c
import PyWebBrowser.browser
class BrowserTab(object):
    def __init__(self,url='about:blank',html='<html><head></head><body><p></p></body></html>'):
        if not isinstance(html, unicode):
            html = unicode(html, vim.eval("&encoding"))
        self.doc = PyWebBrowser.w3c.parseString(html)
        self.win = PyWebBrowser.browser.HtmlWindow(url,  self.doc)
EOF
    let s:js_interpreter = 'pyv8'
else
    if has('win32')
        let s:js_interpreter='cscript /NoLogo'
        let s:runjs_ext='wsf'
    else
        let s:runjs_ext='js'
        if exists("$JS_CMD")
            let s:js_interpreter = "$JS_CMD"
        elseif executable('node')
            let s:js_interpreter = 'node'
        "elseif executable('/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc')
            "let s:js_interpreter = '/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc'
        elseif executable('js')
            let s:js_interpreter = 'js'
        else
            echoerr 'jsruntime.vim complains Not found a valid JS interpreter. nodeJs is recommended.'
            let s:js_interpreter = 'NotAvailable'
			" finish will cause a lot of functions not found
            " finish
        endif
    endif
endif

" a flag to other plugin to know does jsruntime support living context
function! javascript#runtime#isSupportLivingContext()
    return s:js_interpreter == 'pyv8'
endfunction

" something you need to know as a vim scripter
" :help CR-used-for-NL
" http://vim.wikia.com/wiki/Newlines_and_nulls_in_Vim_script
function! javascript#runtime#evalScript(script,...)
    let result=''
    if !exists("a:1")
        let renew_context = 0
    else
        let renew_context = a:1
    endif

    " pyv8 eval
    if s:js_interpreter == 'pyv8'
    python << EOF
import vim,json
if int(vim.eval('renew_context')) and jsRuntimeVim:
    #print 'context cleared'
    jsRuntimeVim.context.leave()
    jsRuntimeVim = VimJavascriptRuntime()
try:
    ret = jsRuntimeVim.evalScript(vim.eval('a:script'))
    # javascript function not return anything
    if not ret:
        ret = 'undefined'
    else:
        ret = str(ret) #call toString methond
    vim.command('let result=%s' % json.dumps(ret))
except Exception,e:
#    with open("jsruntimedebug.txt","w") as fp:
#        fp.write(str(e))
#        fp.close()
    vim.command('echoerr \"There\'s a problem while evaluating javascript code\"')
    vim.command('echo \"Javascript Interpreter => %s\"' % vim.eval('s:js_interpreter'))
    vim.command('echo \"Details => %s\"' % e)
    vim.command('let result=\'\'')

EOF
    else
        let s:cmd = s:js_interpreter . ' "' . s:install_dir . '/jsrunner/runjs.' . s:runjs_ext . '"'
        let result = system(s:cmd, a:script)
        "call writefile(["returned",result,"script",a:script],'jsruntimedebug.txt')
        if v:shell_error
           echoerr "There\'s a problem while evaluating javascript code"
           echo "Javascript Interpreter => " . s:js_interpreter . "\nDetails => " . result
        end
    endif
    return result
endfunction

" clean the context
function! javascript#runtime#clean()
    if s:js_interpreter == 'pyv8'
    python << EOF
import vim,json
if jsRuntimeVim:
    #print 'context cleared'
    jsRuntimeVim.context.leave()
    jsRuntimeVim = VimJavascriptRuntime()
EOF
	endif
endfunction	

if s:js_interpreter == 'pyv8'
    function! javascript#runtime#evalScriptInBrowserContext(script)
    python << EOF
NewTab=BrowserTab(url='http://localhost:8080/path?query=key#frag',html=vim.eval("a:script"))
NewTab.win.fireOnloadEvents()
EOF
    endfunction
endif

let &cpo = s:save_cpo
