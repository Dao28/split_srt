@echo off
setlocal enabledelayedexpansion
rem <con: color 0A & mode 120,16 & echo\
chcp 65001 >nul
set tn =0
 for %%a in (%*) do ( 
             set /a tn +=1             	
		title 正处理第 !tn! 个字幕
		set "sn=%%a"
		set "backup=!sn:~0,-4!bak.srt"
		set "fEN=<font color=#FFFFFF>{\fs10}"
		set "fCN=<font color=#a8a8a8>{\fs8}"
		set "split=--"
		set "tmp=tmp.txt"
		set o=-1
		set h=-1
		set "char=-->"
		echo.
		echo --------------字幕文件--------------
		echo !sn!
		for /f "tokens=1* delims=: eol=" %%i in ('findstr /n .* "!%%a!"') do (
			set /a o += 1
		    	if "%%j"=="" (
		    		rem 替换空白行为特殊字符，因为默认for循环会去掉空白行，导致行序是去掉空白行后的行序
		    		set txts[!o!]="!split!"
		    	) else (
		    		set txts[!o!]=%%j
		    		rem 生成时间码数组
		    		set "txt=%%j"
		    		for /l %%B in (0,1,!txt:~0,1!) do (
			        	if "!txt:~13,3!"=="!char!" (
						set /a h += 1
						set hs[!h!]=%%j
			        	)
		        	)
		    	)
	    	)
	    	echo.
	    	echo --------------备份字幕--------------
	    	copy %%a !backup! >nul
	    	echo !backup!
		echo.
		echo --------------解析字幕--------------
		set e=-1
		set c=-1
	    	for /l %%i in (0,1,!o!) do (
	    		set "txt=!txts[%%i]!"
	    		for /l %%B in (0,1,!txt:~0,1!) do (
	    				rem 如果检索结果的前两个字符跟分割符匹配
			        	if "!txt:~1,2!"=="!split!" (
			        		rem 输出英文字幕行到数组
			        		if %%i EQU 4 (
			        			rem 第一个分割符号，第一句英文是在分割符序号之前2行
			        			set /a ne = %%i - 2
			        			for /f "tokens=2 delims==" %%E in ('set txts[!ne!]') do set en=%%~nE
							if defined en (
								set /a e = 0
								set ens[!e!]=!en!
		    					)
			        		) 
			        		rem 第一个分割符号，第二句英文行号是在分割符序号之后3行
			        		set /a ne = %%i +3
						if !ne! LEQ !o! (						       
							for /f "tokens=2 delims==" %%E in ('set txts[!ne!]') do set en=%%~nE
							if defined en (
								set /a e +=1
								set ens[!e!]=!en!
			    				)
		    				)
	    					
	    					rem 输出汉字字幕行到数组，位于分割符行号之前1行
	    					set /a n = %%i -1
						if !n! GEQ 0 (						       
							for /f "tokens=2 delims==" %%N in ('set txts[!n!]') do set cn=%%~nN
							if defined cn (
								set /a c +=1
								set cns[!c!]=!cn!
		    					)
	    					)
			        	)
			)
  			call :progress %%i !o!
		)
		echo.
		echo --------------重建字幕--------------
		for /l %%i in (0,1,!h!) do (
		       set /a xx=%%i + 1
		       rem 序号
		       echo !xx! >> !tmp!
		       rem 时间码
		       echo !hs[%%i]! >> !tmp!
		       rem 英文
		       set ee=!ens[%%i]!
		       if defined ee (
				echo !fEN!!ee! >> !tmp!
			)
			rem 中文
			set nn=!cns[%%i]!
			if defined nn (
				echo !fCN!!nn! >> !tmp!
			)
			rem 空行
			echo. >> !tmp!
			call :progress %%i !h!
		)
		rem 覆盖原字幕
		move !tmp! "!%%a!" >nul
		echo.
		echo ----------------完成----------------
		echo.
		echo.
)
rem 进度条
rem https://www.reddit.com/r/Batch/comments/sgueji/how_to_relate_progress_bar_to_number_of_commands/
:progress
if "!bksp!" == "" for /f %%A in ('echo prompt $h^|cmd') do set bksp=%%A
for /l %%B in (1,1,20) do set/p a=!bksp!<nul
set/p a=[<nul
set/a p=(%1*100/%2+5)/10
for /l %%B in (1,1,!p!) do set/p a=#<nul
set/a p=10 - !p!
for /l %%B in (1,1,!p!) do set/p "a=.!bksp! "<nul
set/a p=(%1*1000/%2+5)/10
set/p a=] !p!%%<nul

endlocal
goto :eof