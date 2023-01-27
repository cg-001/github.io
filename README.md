# github.io
## 简介
### 皮皮软件
一些用tcltk语言编写的小工具软件。some widges for memorize.
这些小软件的作用是：
1. 记忆诗词shici.tcl,shici.db，
2. 记忆外语单词words.tcl,words.db,for recite foreign language words.
3. 高效笔记本notes.tcl,notes.db. efficiency notes for record.
4. 高效打字软件并可以用于熟悉外语句型typewriter.tcl。
5. 任务提示tasktable.tcl tasktables.tcl 


## 使用方式：
1. 下载download *.tcl,*.db,*.txt.

2. 下载download tcltk语言，websit：https://www.tcl.tk/software/tcltk/ ，for BAWT Multi-platform，
3. 用wish.exe打开上述tcl文件即可。
- 在tcltk的bin文件夹下面，
- - wish.exe是支持tk GUI界面与tcl语言的程序，
- - tclsh.exe是只支持tcl语言的程序。


## 程序功能：
在中部text组件中：
- Control-t 随机得到一句(个)诗、笔记、单词，
- Control-k 删除输入日文单字时，其中的中文拼音符号，如ā á ǎ à ō 等，保存在words.txt文件中。
- Control-m 得到单词名称。

- Control-z表示undo，
- Control-y表示redo.

在底部输入组件中：
- Control-f 搜索，
- Control-l可以搜索单个句子。
- Control-i 添加记录到数据库
- 输入id数字并按回车键 更新数据库中的内容，需要输入整数。
- Control-j 诗词飞花令，按Control-j 启动，按回车键输入诗句玩飞花令。



## 版本
2023.1.27
- 对一些代码进行了优化。

2021.11.21
- 改变底部输入框中的control-u键为回车键，因为这样更简单快捷，也不会也control-i搞错，变成新增记录。

2021.10.26
- 增加了words外语单词中只列出单词名称的功能。
- 修改了外语单词、诗词、笔记中搜索功能。


2021.09.30
- 增加诗词飞花令、外语单词自动过滤不需要加入的中文拼音符号，增加过滤已经记得非常熟悉的诗词功能。
- Control-l可以搜索单个句子功能。


2021.09.21
- 修改了获取当前目录的命令。

任务提示pipi .windows ver 1.0000 2021.09.20
- 任务提示软件tasktable.tcl tasktables.tcl 

pipi. windows ver 1.0000 2021.09.13
- 打字与外语学习软件 typewriter.tcl。

pipi. windows ver 1.00100 2021.09.03
- 改正了搜索每一行时只搜索第一个相同词的问题。

pipi. windows ver 1.0011 2021.08.30
1. 改变了诗词shici.tcl添加记录时的判断是否已经有相同的内容。
2. 美颜一，在练习时，可以随机改变组件字体的颜色。

pipi  windows ver 1.010 2021.08.23
1. 改进了界面函数，相比ver 1.0，可以调整界面的大小。
2. 搜索时可以用颜色显示出搜索词，并可以一次搜索多个词，用空格分开。

pipi  windows ver 1.0 2021.08.09
- 非常简洁的背单词、诗词、笔记本。
