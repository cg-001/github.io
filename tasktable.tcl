
#休息十分钟，到了每个小时的第41分钟时休息。
set resttime 41

#日程表tasktables.tcl
#cd "g:/project/tcltk" ;
#工作目录，
set gzml [file dirname [ file nativename  [info script]]]
cd $gzml

source -encoding  utf-8 tasktable.txt

font create mefont -size 26

label .l -textvariable labelText -font mefont
grid .l -sticky nsew 
label .l1 -font mefont
grid .l1 -sticky nsew 
text .t -font mefont -width 20 -height 5
grid .t -sticky nsew 
	
    #标题：皮皮任务tasktables
    set tstr "\xe7\x9a\xae\xe7\x9a\xae\xe4\xbb\xbb\xe5\x8a\xa1";
    set tt [encoding convertfrom  utf-8 $tstr]
    wm title . "$tt pipi.tasktables windows ver 1.00001"
	
proc tt {s body totime} {
	eval  $body
	after $s [info level 0]
	#after 。。。 [info level 0]可以减少cpu占用。
	global  richeng
	set time1 $totime	
	#scan 把01-08转换为数字
	set time2 [scan [ clock format [clock seconds] -format %M ]  %d ]
	set time3 [expr $time2 - $time1 ]

    #电脑屏幕分辨率
    set xsw [winfo screenwidth .]
    set xsh [winfo screenheight .]
    
    set mwidth [expr int($xsw*0.7)]
    set mheight [expr  int($xsh*0.7)]
    
	if { $time3 >=0 &&  $time3<10  } {
	#时间在定时到的前后10分钟内，提示
		.l1 configure -text "Have a rest."
		wm attributes . -topmost true 
		wm geometry .  ${mwidth}x${mheight}+100+150
		wm deiconify .
	} else {		
		.l1 configure -text ""		
		wm attributes . -topmost 0 
		wm geometry .  450x400+100+150
		wm iconify .
	}
	
	#日程表时间到了，提示。
	set time4 [clock format [clock sec] -format "%H:%M"]
	
	dict for {key value} $richeng {
		if {$key==$time4} {
			.t delete 1.0 end
			.t insert end  "$key\t$value"
			wm attributes . -topmost true 
			wm deiconify .
		}
		
	}
}

#每一个小时的41分钟时，显示休息十分钟的提示。
tt 5000 {set ::labelText [clock format [clock sec] -format %H:%M:%S] } $resttime

