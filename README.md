# TLogger Swift

Fast and user-friendly logging utility for Swift. Easy to use, just import a file or package and write messages or overwrite the existing print function. You can find almost all necessary functions: error levels, trace messages, write to disk, load and format logs callback.


	> (001) 22:34.029 ProjectName [ content ] 💬 To do something about... 
	> (002) 22:34.031 ProjectName [ imports ] ✅ Job done!
	> (003) 22:34.031 ProjectName [ testing ] ⛔️ ERROR: File missing!

	
Its special design allows the simplest implementation, just use this function call: 
	
```Swift
	TLogger.log("I have an important remark...")
```


or use the simpler and shorter function, which only works in #Debug mod

```Swift
	tlog("I have an important remark...")
```

Its unique feature is that it can log by letter, it can add words to a line already started, and it saves it immediately to a file, so if there is a crash, the last and important message is still there. 

```Swift
	tlog("...and", join: true)
```

Use the groups to organise your messages, or use the levels modifier to display coloured icons to make important messages easier to see. You can also use levels to make messages only appear above the level you have set.

```Swift
	tlog("Nothing special", level: .none)
	tlog("To do something about...", level: .comment)
	tlog("Job done", level: .done)
	tlog("ERROR: File missing !", level: .error)
```	


If you want to use the messages elsewhere in your program, you can do so with a callback function. You just need to add this line to your program: 

```Swift
	TLogger.shared.delegate = self
```

A very useful feature is that the program reads back the previous LOG on startup and you can use this anywhere without a console.

```Swift
	TLogger.reloadLog(erase: true)
```

You can configure a lot of things: the information to be displayed and the order in which it is displayed. The name and location of the log file. The different symbols and formatting styles. 

```Swift
	TLogger.logfile = "Error.log"
	
	TLogger.orderWrite = [.all]
	TLogger.formatWrite = "yyyy-MM-dd HH:mm:ss.SSS"
	
	TLogger.orderPrint = [.serial, .date, .message]
	TLogger.formatPrint = "mm:ss.SSS"
	TLogger.printLevel = .warning
	
	TLogger.signSeparator = " ⁃ "
	TLogger.signSerial = ")"
	TLogger.signNull = "∅"
	TLogger.signPart = "|"
	TLogger.signIndent = "  "
```	

If you use the print override function (uncomment first), you don't even have to rewrite anything in the existing program code, it will save the messages.

```Swift
public func print(_ items: String..., file: String = #file, line: Int = #line, sender: String = #function, separator: String = " ", terminator: String = "") {
	#if DEBUG
		
	let message = items.map { "\($0)" }.joined(separator: separator)
	TLogger.log(message, file: file, line: line, sender: sender)
		
	#endif
	}
```

Use indentation to better see which function called which other function while running.

```Swift
	tlog("Main function called", indent: .plus)
		tlog("1..")
		tlog("2..")
		tlog("Another function called", indent: .plus)
				tlog("3")
				tlog("4")
				tlog("Function loop ended", indent: .reset)
```				
				

	
