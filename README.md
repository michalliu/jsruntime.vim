jsruntime.vim
=============

一个vim里的javascript解释器，它使用[PyV8](http://code.google.com/p/pyv8/)作为解释引擎，同时它还创建了一个浏览器的上下文环境，可以让你直接在vim里运行html代码。

A javascript runtime environment in vim, it use PyV8 as interpreter, and aslo create a browser-based context to execute javascript code

使用说明(Usage)
-------------
1. 拷贝plugin下的文件到 vimfiles\plugin 下

2. 添加如下代码到你的 vimrc

        au FileType html source $VIM\vimfiles\plugin\jsruntime.vim
        au FileType javascript source $VIM\vimfiles\plugin\jsruntime.vim

命令(Command)
-------------
    :RunJS 执行当前buffer中的js代码
    :RunJSBlock {range} 执行当前buffer中的js代码块，如:RunJSBlock 3,9执行第3-9行的代码
    :RunHtml 在模拟浏览器环境中执行js代码
    :RunHtmlBlock {range} 在模拟浏览器环境中执行js代码块
