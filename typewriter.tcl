
#打字软件

cd "g:/project/tcltk" ;
#工作目录，

proc initial {} {

	set winwidth 800
	set winheigh 660
	
	set tply 100
	set tplx 150
	
	set tplwidth 168
	set tplheigh $winheigh		
	
	set winy $tply
	set winx [expr $tplx + $tplwidth ]
	
	wm geometry . ${winwidth}x${winheigh}+$winx+$winy
	wm minsize . 500 350	
	
	set strtitle "\xe6\x89\x93\xe5\xad\x97\xe8\xbd\xaf\xe4\xbb\xb6"
	set tt [encoding convertfrom  utf-8 $strtitle]
	wm title . "$tt pipi.dazhi version 1.0000"
	
	font create mefont -size 26
	
	frame .f -background blue 
	text .f.t -width 30 -height 10   -font mefont  -yscrollcommand { .f.scroll set } 
	scrollbar .f.scroll -command { .f.t yview }


	frame .f1 -background red
	label .f1.l  -text "Entry" -width 100
	entry .f1.e  
	button .f1.b -text "Press" -command {createtoplevel }


	toplevel .tpl
	wm geometry .tpl ${tplwidth}x${tplheigh}+$tplx+$tply
	frame .tpl.f 
	text .tpl.t -bg gray85  -font mefont
	
	set strtpltitle "\xe7\xbb\x9f\xe8\xae\xa1"
	set tpltt  [encoding convertfrom  utf-8 $strtpltitle]
	wm title .tpl $tpltt
	
	#source -encoding  utf-8 pingbici.dll
	#.f.t insert  end $pingbici

	
}

initial;


#动态修改程序大小
bind . <Configure> {
	set hei [winfo  height .]
	set wid [winfo width .]

	set labelheight 30
	set labelwidth 100
	
	place .f -x 1 -y 1 -width [expr $wid-1] -height [expr $hei-$labelheight-1]
	place .f.t -x 2 -y  2 -width [expr $wid-25] -height [expr $hei-$labelheight-4] 
	place .f.scroll -x  [expr $wid-25] -y 2 -width  25 -height  [expr $hei-$labelheight-4] 

	place .f1 -x 1 -y   [expr $hei-$labelheight-1] -width [expr $wid-1]  -height [expr $hei-$labelheight-1] 
	place   .f1.l -x 1  -rely 0.001 -width $labelwidth -height $labelheight
	place   .f1.e  -x $labelwidth  -rely 0.001  -width [expr $wid-$labelwidth*2-2] -height $labelheight
	place   .f1.b -x [expr $wid-$labelwidth-1] -rely 0.001 -width $labelwidth   -height $labelheight 
	
	#动态修改toplevel .tpl大小
	set tplhei [winfo  height .tpl]
	set tplwid [winfo width .tpl]
	set tply  [winfo y .] 
	set tplx  [expr [winfo x .]-$tplwid]
	#place .tpl.f -x 1 -y $tply -width $tplwid -height $hei
	#place .tpl.t -x 1 -y $tply  -width $tplwid -height $hei
	wm geometry .tpl ${tplwid}x${hei}+$tplx+$tply

}

	#动态修改toplevel .tpl大小
bind .tpl <Configure> {
	set hei [winfo  height .tpl]
	set wid [winfo width .tpl]
	
	set winwid [winfo width .]
	
	set tplx [winfo x .]
	set tply [winfo y .tpl]
	
	place .tpl.f -x 1 -y  1 -width $wid -height $hei 
	place .tpl.t -x 1 -y  1 -width $wid -height $hei 
	
	#wm geometry . ${winwid}x${hei}+$tplx+$tply
	
}	





	#.f1.e 中离开按键时。高亮度显示打错的字。
#
proc show {} {
	#set currentline 1
	#set currentcol 0

bind .f1.e <KeyRelease> {
	
	#同步显示输入sync,yview moveto
	#.f.t sync 
	#.f.t yview moveto .1

	#输入字符串str
	set str [.f1.e get]
	.f1.e delete 0 end
	
	#得到输入字符串长度
	set lenstr [string length $str]	

	#当前打字文本的字符串strtext
	set strtext [.f.t get 1.0 end]
	#得到当前text的总行数
	set lines [.f.t count -displaylines 1.0 end]	

	#当前行字符串
	set currentlinestr [.f.t get $currentline.0 $currentline.end] 
	#得到当前行字符串长度
	set lencurrentlinestr [string length $currentlinestr]
	
	
	#当前列加上输入字符串长度
	set ccol [expr $currentcol + $lenstr]
	
	set nstr 0
		
	#如果str与.f.t中字符串strtext不相同，显示红色，否则颜色不变。
	if {$currentline<=$lines} {
	
		#输入值是否在同一行里，
		#是，ccol加输入值长度，否，当前行数增加一。
		if {$ccol<=$lencurrentlinestr  } {
			#输入值str是否与当前位置的字符串相同，nstr 等于0为不同。
			set nstr [string equal -length $lenstr \
			            $str [string range $currentlinestr $currentcol $ccol ]]
		
			#设置tag，用来改变颜色
			set tagx "tag$currentline$currentcol"
			.f.t tag add $tagx  $currentline.$currentcol $currentline.$ccol								
			if { $nstr != 0 } { 
				#输入字符串与当前文本相同,颜色不变。
					#输入字符串与当前文本不同，显示红色。
				.f.t tag configure $tagx -background green -foreground black
		
		
			} else {
				.f.t tag configure $tagx -background red -foreground black
		
		};#$nstr != -1
		#增加当前列的数字
		set currentcol [expr $currentcol + $lenstr]
		
	} else {
				#修改当前行数增加一
				set currentline [expr $currentline+1]
				set currentcol 0
				
	
	};#$ccol<$lencurrentlinestr
	
		#在tpl.t中显示打字统计	
		.tpl.t delete 1.0 end 
	
		.tpl.t insert end "\nlines:$lines"
		.tpl.t insert end "\nnstr:$nstr"
		.tpl.t insert end "\nlenstr:$lenstr"
		.tpl.t insert end "\nstr:$str"
		.tpl.t insert end "\ncurrentline:$currentline"
		.tpl.t insert end "\nlencurrentlinestr:$lencurrentlinestr"
		.tpl.t insert end "\ncurrentcol:$currentcol"
		.tpl.t insert end "\nnstr:$nstr"
		.tpl.t insert end "\nccol:$ccol"

	};#$currentline<=$lines
}
}


set i 1
proc createtoplevel {} {
		global i
		set x [ expr int(rand()*100)]
		set y [ expr int(rand()*100)]
	#	.f.t insert  end "\n$i: $x+$y"
		incr i


	
	#当前行	
	global currentline
	set currentline 1
	#当前列
	global currentcol
	set currentcol 0

	set aa [.f.t get 1.0 end]
	.f.t delete 1.0 end
	.f.t insert end $aa
	show

}

