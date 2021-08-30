# github.io
## 简介
这里是一些用tcltk语言编写的小工具软件。
这些小软件的作用是：
1. 记忆诗词shici.tcl,shici.db，
2. 记忆外语单词words.tcl,words.db,
3. 简洁型笔记本notes.tcl,notes.db.



## 使用方式：
1. 下载shici.tcl,shici.db,words.tcl,words.db,notes.tcl,notes.db.
1.1. 修改shici.tcl,words.tcl,notes.tcl中工作目录部分，改成它们所在的文件夹，
1.2. shici.db,words.db,notes.db是sqlite3语言建立的数据库，如果想变为空数据库，可以删掉，然后用tcltk中的wish打开，即可自动生成新的数据库。
2. 下载tcltk语言，网站在：https://www.tcl.tk/software/tcltk/ ，推荐下载BAWT Multi-platform，因为我使用的是这个，在tcltk的bin文件夹下面，wish就是支持tk界面与tcl语言的程序，tclsh就是只支持tcl语言的程序。
3. 用wish.exe打开上述tcl文件即可。


## 程序功能：
有text组件中：
- Control-t 随机得到一句(个)诗、笔记、单词，
- ctrl-z表示undo，
- ctrl-y表示redo.

在底部输入组件中：
- Control-f 搜索，
- Control-i 添加记录到数据库
- Control-u 更新数据库中的内容，需要输入整数。



## 版本
pipi. windows ver 1.0011 2021.0830
1. 改变了诗词shici.tcl添加记录时的判断是否已经有相同的内容。
2. 美颜一，在练习时，可以随机改变组件字体的颜色。

pipi  windows ver 1.010 2021.08.23
1. 改进了界面函数，相比ver 1.0，可以调整界面的大小。
2. 搜索时可以用颜色显示出搜索词，并可以一次搜索多个词，用空格分开。

pipi  windows ver 1.0 2021.08.09
- 非常简洁的背单词、诗词、笔记本。
