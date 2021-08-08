

cd "g:/project/tcltk" ;#工作目录，words.tcl与words.db所在的文件夹。

package require sqlite3
sqlite3 db words.db


#初始化
proc initial {} {

	#wordsname：id、单词名称
	#wordsneirong：内容    
	db eval {create table IF NOT EXISTS words (
			 id INTEGER PRIMARY KEY ASC,\
				 wordsname varchar(30) NOT NULL,\
				 wordsneirong text NOT NULL
			 );
    }
    #电脑屏幕分辨率
    set xsw [winfo screenwidth .]
    set xsh [winfo screenheight .]
    
    set mwidth [expr int($xsw*0.8)]
    set mheight [expr  int($xsh*0.8)]
    
    wm maxsize . $mwidth $mheight
    wm minsize .  500 300
    wm geometry . +150+150  ;#窗口左上角在150.150处。

    #标题：皮皮单词
    set tstr "\xe7\x9a\xae\xe7\x9a\xae\xe5\x8d\x95\xe8\xaf\x8d ";
    set tt [encoding convertfrom  utf-8 $tstr]
    wm title . "$tt pipi.words recite windows ver 1.0"



    set upframe [frame .f -width $mwidth -height $mheight ;]
    set uptitle [label .f.ltitle -text "title"]

    font create textfont -size 26 -weight bold

    set upttext [text .f.t  -width 43 -height 15 -bg grey70 -font textfont  -undo true -yscrollcommand { .f.scroll set } ]
    #-width 43 -height 15text长宽为15与43个字符的宽度。

    set upscrollbar [scrollbar .f.scroll -command { .f.t yview }]


    grid $uptitle
    grid $upttext  -sticky nsew
    grid $upscrollbar -row 1 -column 3 -sticky nsew


    set bottomFrame [frame .f1]

    set bottoml [label .f1.l -text "Entry:" ]


    set bottome [entry .f1.e -width 80]

    set bottomBPress [button .f1.b -text "Press" -command entryneirong]


    grid $bottoml  -column 0 -row 0 -sticky w -columnspan 1
    grid $bottome -column 1 -row 0 -sticky nsew -columnspan 1
    grid $bottomBPress -column 12 -row 0 -sticky e  -columnspan 1

    #grid configure $bottome -columnspan 10


    grid $upframe -row 0   -sticky nsew
    grid $bottomFrame -row 1   -sticky nsew

}

#调用初始化函数来初始化界面。
initial



#按回车键时调用show函数。
bind .f1.e <<Enter1>> {show}
event add <<Enter1>> <Return>


#insert
bind .f1.e <Control-i> {

    set name  [string trim [.f1.e get]	]  ;#id、单词
    #id、不用输入
    set neirong [.f.t get 1.0 end];#内容

    set name [string trim $name]
    set neirong  [string trim $neirong]
	
	#把单引号修改为\'，因为sql中单引号有特殊用途，不改会错。
	set name [string map {'  '' }  $name]
	set neirong [string map {'  '' }  $neirong]
	
    if {$name!="" && $neirong !=""} {
	db eval "insert  into words values( null,'$name','$neirong');"
	.f.t delete 1.0 end
	.f1.e delete 0 end
	.f.t insert end "successful to insert."
    }
}


#搜索
bind .f1.e <Control-f> {
    search
}

#搜索proc
#多词搜索：利用空格，如：唐 王维，同时搜索唐与王维。
#利用tag高亮度显示搜索词。
proc search {} {
	#获取搜索内容
    set et [string trim [.f1.e get]	]
	
    if {$et != ""}  {
	
	#拆分split搜索内容
	set sp [split $et " "]
	
	set lensp [llength $sp]
	
	set str "";#str作为搜索字段	
	
	for {set i 0} {$i<$lensp} {incr i} {
		set tmp [lindex $sp $i]
		#把单引号修改为\'，因为sql中单引号有特殊用途，不改会错。
		set tmp [string map {'  '' }  $tmp]
		if {$i<[expr $lensp-1]} {
			set str "$str (wordsname like '%$tmp%' OR wordsneirong like '%$tmp%' ) AND "
		} else {
			set str "$str ( wordsname like '%$tmp%' OR wordsneirong like '%$tmp%' ) "
		}
	}
	#.f.t insert end $str


	set x [db eval "select * from words where $str"]
	#set x [db eval "select * from words \
								     where wordsname like '%$et%' OR wordsneirong like '%$et%' "]
									 
	foreach {id ming neirong}  $x {
	    .f.t insert end "\nid:\t$id \nMing:\n$ming \nNeiRong:\n$neirong\n\n"
	}
	.f.ltitle configure -text "Title   $et"
	
	#得到当前text的总行数
	set lines [.f.t count -displaylines 1.0 end]
	
	#高亮度显示搜索词。
	for {set i 0} {$i<$lensp} {incr i} {
		set tmp [lindex $sp $i];#搜索词

		#获取搜索词长度
		set lentmp [string length $tmp]
		for {set j 0} {$j<$lines} {incr j}  {
			#获取搜索词位置
			set tmplocation [string first $tmp \
										[.f.t get $j.0 $j.end] 0]
			#.f.t insert end "\n tmp:$tmp xxx [.f.t get $j.0 $j.end]"					
			if {$tmplocation!=-1} {
			#==-1表示没有找到
			
			#高亮度搜索词
			set tagx tag$i$j
			#.f.t insert end "\ntagx tag$i$j\n"
			
			#shutmp搜索词所在位置加上搜索词的长度
			set shutmp [expr $tmplocation+$lentmp]
			
			.f.t tag add $tagx \
			    $j.$tmplocation $j.$shutmp
			.f.t tag configure $tagx -background red -foreground black
			

			
			}
		}
		
	}
    }
}


#出题 
#1.得到总记录数，
#2.得到一个随机数，
#并用select 得到这个记录，并显示在组件text中
bind .f.t  <Control-t> {

    #1.得到总记录数，sums
    set sums [db eval {select count() from words;}]

    #2.得到一个随机数，
    #int(rand()*$sums)得到0-(sums-1)之间的数。
    #而sqlite中的记录数是从1到sums。
    set r [expr int(rand()*$sums)]
    
    if {$r<$sums} {
	#用select 得到这个记录，
	set jilu [db eval "select * from words where id=[expr $r+1]"]

	#，。！？到utf-8
	set d1 "\xef\xbc\x8c"
	set d2 "\xe3\x80\x82"
	set d3 "\xef\xbc\x81"
	set d4 "\xef\xbc\x9f"
	
	set tt1 [encoding convertfrom  utf-8 $d1]
	set tt2 [encoding convertfrom  utf-8 $d2]
	set tt3 [encoding convertfrom  utf-8 $d3]
	set tt4 [encoding convertfrom  utf-8 $d4]
	
	foreach {id name neirong} $jilu {
	    
	    set  m [split $neirong "$tt1$tt2$tt3$tt4\r\n"]
	    #set  m [split $neirong "\r\n"];#以行来split拆分。
	    #.f.t insert end "\n$m\nrand:[llength $m ]";
	    
		
	    #获取list数据m中的个数
	    set le [llength $m]
	    
		#去掉m中的“”值
		set listh {}
		foreach li  $m {
			if {$li!=""} {lappend listh $li}
		}
		
	    #获取listh中第几个不为""的值。
	    set r1 [expr round( rand()*($le-1))]
	    set str [lindex $listh $r1  ]
	    
	    #显示
	    if {[string trim $str] != "" } {
		.f.ltitle configure -text "id:$id  $name";
		.f.t delete 1.0 end
		.f.t insert end "sums$sums\n\n\n\nword=$name\n\t $str\t\n"
		#不用\t\n，最后两个字会颠倒。
		
	    }
	}
	
    }
}


#更新数据库
#Control-u，先在.f1.e中输入要更新的id号(整数)，
#建立toplevel级别的界面
#单击更新按钮，保存

bind .f1.e  <Control-u> {
    #获取总记录数sums
    set sums [db eval {select count() from words;}]
    
    #获取要更新的记录的id号(整数)	，	
    set et [string trim [.f1.e get]	]
    set ett [string is  digit $et]
    if {$et != "" && $ett == 1 && $sums>=$et}  {
	update0
    }
}



#显示更新界面
proc update0 {} {

    toplevel .tplupdate
    wm title .tplupdate "Update...If conform,Please Press Control-S to update." 	
    
    frame .tplupdate.f
    
    label .tplupdate.f.ltext 
    
    text .tplupdate.f.t -width 35 -height 10 -bg grey70 -font textfont  -undo true -yscrollcommand { .tplupdate.f.scroll set } 
    scrollbar .tplupdate.f.scroll -command { .tplupdate.f.t yview }

	frame .tplupdate.f1
    label .tplupdate.f1.lId -text "id:"  
    entry .tplupdate.f1.e -width 60 

    button .tplupdate.f1.b -text "Update" -command {
	update1
    }

    
    grid .tplupdate.f
    grid .tplupdate.f.ltext 
    
    grid .tplupdate.f.t -column 0 -row 1 -sticky nsew -columnspan 3
    grid .tplupdate.f.scroll  -column 3 -row 1 -sticky nsew
    
    grid .tplupdate.f1
	grid .tplupdate.f1.lId -column 0 -row 2 -sticky w 
    grid .tplupdate.f1.e -column 1 -row 2 -sticky nswe 
    grid .tplupdate.f1.b -column 2 -row 2 -sticky nswe
    
    #获取要更新的记录的id号(整数)	，
    set et [string trim [.f1.e get]	]
    
    set x [db eval "select * from words where id=$et"	]


    foreach  {id name neirong } $x {
	.tplupdate.f.ltext configure -text "ID:$id\t$name"
	.tplupdate.f.t insert end "$neirong"
	.tplupdate.f1.e insert 0 "$name"
	.tplupdate.f1.lId configure -text "$id"

    }	
}

#保存更新内容
proc update1 {} {
    #获取要更新的记录的id号(整数)	，
    set id [string trim [.tplupdate.f1.lId cget -text]	]
    
    #获取单词名
    
    set name [.tplupdate.f1.e get]

    #获取单词的内容
    set neirong [.tplupdate.f.t get 1.0 end ]
	
	#把单引号修改为\'，因为sql中单引号有特殊用途，不改会错。
	set name [string map {'  '' }  $name]
	set neirong [string map {'  '' }  $neirong]

    toplevel .t1
 
	text .t1.t -width 43 -height 15 -bg grey70 -font textfont
    grid .t1.t
    .t1.t insert end  "\t id:$id\n $name\n $neirong\n"
    
   db eval "update words set  wordsname='$name',wordsneirong='$neirong' where id=$id"
}

#程序功能：
#Control-t 随机得到一句单词，
#Control-f 搜索单词，
#Control-i 添加单词到数据库
#Control-u 更新数据库中的内容。

#所需程序
#两个
#一、words.tcl ，tcl语言程序
#二、words.db ，slited3数据库

#窗口缩放
wm protocol . WM_RESIZE_WINDOWS  {

	puts "wm size"
	.f.t insert end "\ndfdf"
}

#显示.f1.e中的字符串
proc show {} {

	#获取输入框.f1.e中的字符串
	set et  [string trim [.f1.e get]	]
	
	if {$et != ""}  {
		#立即显示字符串
		.f.t insert end "\n$et "    
		.f1.e delete 0 end		
	}
}

