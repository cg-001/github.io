

#工作目录。
set gzml [file dirname [ file nativename  [info script]]]
cd $gzml

package require sqlite3
sqlite3 db notes.db


#初始化
proc initial {} {

	#notesname：id、笔记名称
	#notesneirong：内容 
    db eval {create table IF NOT EXISTS notes (
				 id INTEGER PRIMARY KEY ASC,\
				     notesname varchar(30) NOT NULL,\
				     notesneirong text NOT NULL
				 );
    }
    #电脑屏幕分辨率
    set xsw [winfo screenwidth .]
    set xsh [winfo screenheight .]
    
    set mwidth [expr int($xsw*0.7)]
    set mheight [expr  int($xsh*0.7)]
    

    wm minsize .  500 120
    wm geometry . ${mwidth}x${mheight}+150+150  ;#窗口左上角在150.150处。

    #标题：皮皮笔记
    set tstr "\xe7\x9a\xae\xe7\x9a\xae\xe7\xac\x94\xe8\xae\xb0";

# "皮皮笔记 测试版 ".encode()
  #  set tstr "\xe7\x9a\xae\xe7\x9a\xae\xe7\xac\x94\xe8\xae\xb0 \xe6\xb5\x8b\xe8\xaf\x95\xe7\x89\x88 ";
  
  set tt [encoding convertfrom  utf-8 $tstr]
  wm title . "$tt pipi.notes windows ver 1.00110"


    set upframe [frame .f -width $mwidth -height $mheight ;]
    set uptitle [label .f.ltitle -text "title"]

    font create textfont -size 26 -weight bold

    set upttext [text .f.t  -width 43 -height 15 -bg grey70 -font textfont  -undo true -yscrollcommand { .f.scroll set } ]
    #-width 43 -height 15text长宽为15与43个字符的宽度。

    set upscrollbar [scrollbar .f.scroll -command { .f.t yview }]


    set bottomFrame [frame .f1]

    set bottoml [label .f1.l -text "Enter:" ]

    set bottome [entry .f1.e -width 80 ]

    set bottomBPress [button .f1.b -text "Press" -command show]

	#当单击时改变组件的颜色
	global flag
	set flag 0
	global color
	set color {purple	"rosy brown" red blue black green SteelBlue orchid navy "dark blue"}
	global colorZhujian
	set colorZhujian {.f.ltitle .f1.l .f1.e .f1.b}
	bind . <KeyPress> {
		set flag [expr int(rand()*[llength $colorZhujian])]
		set color1 [expr int(rand()*[llength $color])]
		
		set strCZ [lindex $colorZhujian $flag ]
		$strCZ configure -fg [ lindex $color $color1]
	};#bind

}

#调用初始化函数来初始化界面。
initial





#insert
bind .f1.e <Control-i> {

    set name  [string trim [.f1.e get]	]  ;#id、笔记
    #id是自动插入数据库的，不用输入。
	
	#把名字里面的回车换行符去掉，
	set name [string map {"\r\n"  "" }  $name]
	
    set neirong [.f.t get 1.0 end];#内容

    set name [string trim $name]
    set neirong  [string trim $neirong]
	
	#把单引号修改为\'，因为sql中单引号有特殊用途，不改会错。
	set name [string map {'  '' }  $name]
	set neirong [string map {'  '' }  $neirong]
	
    if {$name!="" && $neirong !=""} {
	db eval "insert  into notes values( null,'$name','$neirong');"
	.f.t delete 1.0 end
	.f1.e delete 0 end
	.f.t insert end "successful to insert."
    }
}


#搜索一个记录
bind .f1.e <Control-f> {
	#获取搜索内容
    set et [string trim [.f1.e get]	]
	if {$et!=""} {
		search $et
	}
}

#搜索一行
bind .f1.e <Control-l> {
	#获取搜索内容
    set et [string trim [.f1.e get]	]
    if {$et!=""} {
		set et "l $et"	
		search  $et
	}
}


#搜索一个记录
#多词搜索：利用空格，如：唐 王维，同时搜索唐与王维。
#利用tag高亮度显示搜索词。
#增加一个只列出有搜索单词的句子功能，et中第一个词为l(l即是line)(小L)时，
proc search {sename} {

	set et $sename
	
	#把名字里面的回车换行符去掉，
	set et [string map {"\r\n"  "" }  $et]
	
	set sp ""
	
    if {$et != ""}  {
	
	#拆分split搜索内容
	set x1 [split $et " "]
	
	#把sp里面的空值去掉。
	 foreach i $x1 {
		if {$i!=""} {lappend sp $i}
	}
	
	set lensp [llength $sp]
	
	set str "";#str作为搜索字段	
	
	#如果第一个搜索词为l(l即是line)(小L)，ii为下面for中i的起始值。
	if {[lindex $sp 0]=="l"} {
		set ii 1
		#set lensp [expr $lensp-1]
	} else {set ii 0}
	
	for {set i $ii} {$i<$lensp} {incr i} {
		set tmp [lindex $sp $i]
		#把单引号修改为\'，因为sql中单引号有特殊用途，不改会错。
		set tmp [string map {'  '' }  $tmp]
		
		if {$i<[expr $lensp-1]} {
			set str "$str (notesname like '%$tmp%' OR notesneirong like '%$tmp%' ) AND "
		} else {
			set str "$str ( notesname like '%$tmp%' OR notesneirong like '%$tmp%' ) "
		}
	}

	#x表示搜索值。
	set x [db eval "select * from notes where $str"]
									 
	#在.f.t中显示搜索内容
	#如果第一个搜索词为l(l即是line)，只显示一行，否则显示所有内容
	#如果mmi等于lensp，表明所有搜索词都在这一行。

	foreach {id ming neirong}  $x {
		if {$ii==1} {
			#1.拆分neirong，
			set flst [ split $neirong "\r\n"]
			
			#2.遍历flst，找出有搜索词的内容。
			foreach fi $flst {			
				#如果每个搜索词都在这一句当中。
				set mmi 0
				for {set i $ii} {$i<$lensp} {incr i} {
					#得到一个搜索词tmp
					set tmp [lindex $sp $i]
					if {[string first $tmp $fi 0 ]!=-1} {
						incr mmi 
					} 
						
				} 
					
				#如果在一句中有所有搜索词
				if {$mmi==[expr $lensp-1]} {
					.f.t insert end "\nid:\t$id \nMing:\t$ming \nfi:\n$fi\n\n"			
				}
			}
		} else {
			.f.t insert end "\nid:\t$id \nMing:\t$ming \nNeiRong:\n$neirong\n\n"
		} 		
	}
	.f.ltitle configure -text "Title   $et"
	
	gaoliang $ii $sp $lensp
    };#$et != ""
}

#ii：当搜索词第一个是l (即line)时，ii=1,否则为0，
#sp为搜索词， lensp为搜索词个数，sp与lensp都是去掉ii后的数。
proc gaoliang {ii sp lensp} {

	#得到当前text的总行数
	set lines [.f.t count -displaylines 1.0 end]
	
	#高亮度显示搜索词。
	#i代表搜索词的个数，以空格来分开。
	#j代表.f.t中的行数，行数从1-end。
	#k代表搜索词在.f.t中每一行的字符串里的位置。
	for {set i $ii} {$i<$lensp} {incr i} {
		set tmp [lindex $sp $i];#搜索词

		#获取搜索词长度
		set lentmp [string length $tmp]
		
		for {set j 1} {$j<=$lines} {incr j}  {
			#得到每一行的字符串linestr
			set linestr [.f.t get $j.0 $j.end] 
			#每一行字符串的长度lenlinestr
			set lenlinestr [string length $linestr]
			
			set k 0
			while {$k<$lenlinestr} {
				#获取搜索词位置
				set tmplocation [string first $tmp  $linestr $k]
				
				if {$tmplocation!=-1} {
				#==-1表示没有找到
				
				#高亮度搜索词
				set tagx tag$i$j
				#.f.t insert end "\ntagx tag$i$j\n"
				
				#k搜索词所在位置
				set k [expr $tmplocation+$lentmp]
				
				.f.t tag add $tagx \
					$j.$tmplocation $j.$k
				.f.t tag configure $tagx -background red -foreground black	
				} else {
					break
				}
			};#while k
		};#for j
	};#for i
}


#出题 
#1.得到总记录数，
#2.得到一个随机数，
#并用select 得到这个记录，并显示在组件text中
bind .f.t  <Control-t> {

    #1.得到总记录数，sums
    set sums [db eval {select count() from notes;}]

    #2.得到一个随机数，
    #int(rand()*$sums)得到0-(sums-1)之间的数。
    #而sqlite中的记录数是从1到sums。
    set r [expr int(rand()*$sums)]
    
    if {$r<$sums} {
	#用select 得到这个记录，
	set jilu [db eval "select * from notes where id=[expr $r+1]"]

	#，。！？；到utf-8
	set d1 "\xef\xbc\x8c"
	set d2 "\xe3\x80\x82"
	set d3 "\xef\xbc\x81"
	set d4 "\xef\xbc\x9f"
	set d5 "\xef\xbc\x9b"
	
	set tt1 [encoding convertfrom  utf-8 $d1]
	set tt2 [encoding convertfrom  utf-8 $d2]
	set tt3 [encoding convertfrom  utf-8 $d3]
	set tt4 [encoding convertfrom  utf-8 $d4]
	set tt5 [encoding convertfrom  utf-8 $d5]
	
	foreach {id name neirong} $jilu {
	    
	    set  m [split $neirong "$tt1$tt2$tt3$tt4$tt5 "]
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
		.f.t insert end "sums: $sums\n\n\n\n\t $str\t\n" ;
		#不用\t\n，最后两个字会颠倒。
		
	    }
	}
	
    }
}



#更新数据库
#在底部输入框中输入数字并按回车键 更新数据库中的内容。先在.f1.e中输入要更新的id号(整数)，
#建立toplevel级别的界面
#单击更新按钮，保存

bind .f1.e  <Return> {
    #获取总记录数sums
    set sums [db eval {select count() from notes;}]
    
    #获取要更新的记录的id号(整数)	，	
    set et [string trim [.f1.e get]	]
	
	#把名字里面的回车换行符去掉，
	set et [string map {"\r\n"  "" }  $et]
	
    set ett [string is  digit $et]
	
    if {$et != "" && $ett == 1 && $sums>=$et}  {
	update0
    }
}



#显示更新界面
proc update0 {} {

    toplevel .tplupdate
    wm title .tplupdate "Update...." 	
    
    frame .tplupdate.f
    
    label .tplupdate.f.ltitle 
    
    text .tplupdate.f.t -width 40 -height 12 -bg grey70 -font textfont  -undo true -yscrollcommand { .tplupdate.f.scroll set } 
    scrollbar .tplupdate.f.scroll -command { .tplupdate.f.t yview }

	frame .tplupdate.f1
    label .tplupdate.f1.l -text "id:"  
    entry .tplupdate.f1.e -width 60 

    button .tplupdate.f1.b -text "Update" -command {
	update1
    }

	#更新界面
	set xsw [winfo screenwidth .]
    set xsh [winfo screenheight .]
    
    set mwidth [expr int($xsw*0.7)]
    set mheight [expr  int($xsh*0.7)]
	
	wm geometry .tplupdate  ${mwidth}x${mheight}+150+150  ;
	wm minsize .tplupdate 500 120 
	
	#改变尺寸
	bind .tplupdate <Configure> {	
		ResizeJiemian .tplupdate
	}
	
    #获取要更新的记录的id号(整数)	，
    set et [string trim [.f1.e get]	]
    
	#把名字里面的回车换行符去掉，
	set et [string map {"\r\n"  "" }  $et]
	
    set x [db eval "select * from notes where id=$et"	]


    foreach  {id name neirong } $x {
	.tplupdate.f.ltitle configure -text "ID:$id\t$name"
	.tplupdate.f.t insert end "$neirong"
	.tplupdate.f1.e insert 0 "$name"
	.tplupdate.f1.l configure -text "$id"

    }	
}

#保存更新内容
proc update1 {} {
    #获取要更新的记录的id号(整数)	，
    set id [string trim [.tplupdate.f1.l cget -text]	]
    
    #获取笔记名
    
    set name [.tplupdate.f1.e get]
	
	#把名字里面的回车换行符去掉，
	set name [string map {"\r\n"  "" }  $name]

    #获取笔记的内容
    set neirong [.tplupdate.f.t get 1.0 end ]
	
	#把单引号修改为\'，因为sql中单引号有特殊用途，不改会错。
	set name [string map {'  '' }  $name]
	set neirong [string map {'  '' }  $neirong]
	
	set xsw [winfo screenwidth .]
    set xsh [winfo screenheight .]
    
    set mwidth [expr int($xsw*0.7)]
    set mheight [expr  int($xsh*0.7)]

    toplevel .t1
 	wm title .t1 "Update Ok."
	wm maxsize .t1 $mwidth $mheight
	wm maxsize .t1 $mwidth $mheight
	wm geometry .t1  ${mwidth}x${mheight}+150+150  ;
	
	text .t1.t -width 43 -height 15 -bg grey70 -font textfont
    place .t1.t -relx 0.001 -y 0.001 -width  [expr $mwidth-1] -height [expr $mheight-1]
    .t1.t insert end  "\t id:$id\nname:$name\nneirong:\n $neirong\n"
	 if {$name!="" && $neirong !=""} {
		db eval "update notes set  notesname='$name',notesneirong='$neirong' where id=$id"
   }
}



#按Press按钮时调用show函数。


#显示.f1.e中的字符串
proc show {} {

	#获取输入框.f1.e中的字符串
	set et  [string trim [.f1.e get]	]

	#把名字里面的回车换行符去掉，
	set et [string map {"\r\n"  "" }  $et]
	
	if {$et != ""}  {
		
		#立即显示字符串
		.f.t insert end "\n$et "    
		.f1.e delete 0 end		
	}
}

#动态修改程序大小
bind . <Configure> {
	ResizeJiemian .
}

#动态改变窗口
proc ResizeJiemian {Window} {
#当前窗口尺寸
	set hei [winfo  height $Window]
	set wid [winfo width $Window]
	if {$Window == "."} {
		set Window [string map { . ""} $Window]
	}
	set fontsize [font actual textfont -size]

	#label尺寸
	set labelheight 30
	set labelwidth 100
	
	#scroll
	set scrollwidth 25
	
	#主界面
    place $Window.f  -x 1 -y 1 -width [expr $wid-1] -height [expr $hei-$labelheight-1]
    place $Window.f1  -x 1 -y [expr $hei-$labelheight-5] -width [expr $wid-1] -height [expr $hei-$labelheight-1]    
	
	place $Window.f.ltitle -relx 0.001 -rely 0.001 -width  [expr $wid-2] -height $labelheight
    place $Window.f.t   -relx 0.001 -y [expr $labelheight+2] -width  [expr $wid-$scrollwidth-4] -height [expr $hei-$labelheight*2-4]
    place $Window.f.scroll  -x [expr $wid-$scrollwidth-1] -y [expr $labelheight+2] -width  $scrollwidth -height [expr $hei-$labelheight*2-1]

    place $Window.f1.l  -x 1 -rely 0.001 -width $labelwidth -height $labelheight 
    place $Window.f1.e -x [expr $labelwidth+1] -rely 0.001 -width [expr $wid-$labelwidth*2-5] -height $labelheight
    place $Window.f1.b -x [expr $wid-$labelwidth-2] -rely 0.001 -width $labelwidth -height  $labelheight

}

#程序功能：
#Control-t 随机得到一句笔记，
#Control-f 搜索笔记，
#l+搜索词，Control-l可以搜索单个句子。
#Control-i 添加笔记到数据库
#在底部输入框中输入数字并按回车键 更新数据库中的内容。
#所需程序
#两个
#一、notes.tcl ，tcl语言程序
#二、notes.db ，sqlite3数据库