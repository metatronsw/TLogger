//
//  T-Logger
//  Swift Logging utility by Metatron
//


import Foundation


protocol TLogDelegate: AnyObject {
	func callbackLog(_ log: TLogger.Entry)
}


public enum TLogLevel: Int, Comparable {
	case none, info, debug, low, mid, high, mark, comment, done, blue, green, yellow, orange, red, null, warning, error, crash
	
	var ico: String {
		switch self {
			case .none:    return ""
			case .info:    return ""
			case .debug:   return ""
			case .low:     return ""
			case .mid:     return ""
			case .high:    return ""
			case .mark:    return "🔘"
			case .comment: return "💬"
			case .done:    return "✅"
			case .blue:    return "🔵"
			case .green:   return "🟢"
			case .yellow:  return "🟡"
			case .orange:  return "🟠"
			case .red:     return "🔴"
			case .null:    return "🚫"
			case .warning: return "⚠️"
			case .error:   return "⛔️"
			case .crash:   return "📛"
		}
	}
	
	public static var `default`: Self {
		.debug
	}
	
	public static func < (lhs: Self, rhs: Self) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
	
}


public enum TLogIndent {
	case none, plus, minus, reset
}



/**
 Call the shared Tlogger, write - print and send to delegate.
 
 - parameter items: Any object that can be described.
 - parameter group: Free to use value
 - parameter file, line, sender: Automatic name of the function calling the log.
 - parameter level: Show icons, and set the visibility in console
 - parameter indent: Set the indentation
 - parameter join: Join text to the previous message
 - note This function call works only in `#Debug` mode.
 */
public func tlog(_ items: Any?..., group: String = "", file: String = #file, line: Int = #line, sender: String = #function, level: TLogLevel = TLogLevel.default, indent: TLogIndent = TLogIndent.none, join: Bool = false, separator: String = " ", terminator: String = "") {
#if DEBUG
	
	var message = ""
	for word in items { message.append(String(describing: word ?? TLogger.signNull ) + separator) }
	
	if join { TLogger.shared.app(message, level: level) }
	else    { TLogger.shared.add(message, group: group, file: file, line: line, sender: sender, level: level, indent: indent) }
	
#endif
}


/*
 /// Optional - override print method
public func print(_ items: String..., file: String = #file, line: Int = #line, sender: String = #function, separator: String = " ", terminator: String = "") {
#if DEBUG
	let message = items.map { "\($0)" }.joined(separator: separator)
	TLogger.shared.add(message, file: file, line: line, sender: sender)
#endif
}
*/




/**
 TLogger is a simple logging framework. It initializes automatically and works between all classes.
 
 1. Parameters must be **double** type
 2. Handle return type because it is optional.
 ```
 TLogger.shared.delegate = self
 tlog("Hello world !")
 ```
 */
final public class TLogger {
	
	/**
	 Call the shared Tlogger, write - print and send to delegate
	 - parameter items: Any object that can be described.
	 - parameter group: Free to use value
	 - parameter file, line, sender: Automatic name of the function calling the log.
	 - parameter level: Show icons, and set the visibility in console
	 - parameter indent: Set the indentation
	 - parameter join: Join text to the previous message
	
	 - note Set the delegate for get messages directly
	 
	 ```
	 Tlog("Simple message")    //  viewDidLoad() ⁃ Simple message
	 Tlog("Error", Level: .error )   //  🛑 viewDidLoad() ⁃ Error
	 Tlog("Warning", Level: . warning)   //  ⚠️ viewDidLoad() ⁃ Warning
	 Tlog("Comment", Prefix: "", Sender: nil)   //  Comment
	 ```

	 ```
	 log("Message")    // viewDidLoad() ⁃ Message
	 join("and", join: true)    // viewDidLoad() ⁃ Message and
	 join("comment", join: true)  // viewDidLoad() ⁃ Message and comment
	 ```
	 */
	public static func log(_ items: Any?..., group: String = "", file: String = #file, line: Int = #line, sender: String = #function, level: TLogLevel = TLogLevel.default, indent: TLogIndent = TLogIndent.none, join: Bool = false, separator: String = " ", terminator: String = "")  {
		
		var message = ""
		for word in items { message.append(String(describing: word ?? TLogger.signNull ) + separator) }
		
		if join { TLogger.shared.app(message, level: level) }
		else    { TLogger.shared.add(message, group: group, file: file, line: line, sender: sender, level: level, indent: indent) }
	}
	
	
	
	/**
	 Read from the saved logfile.
	 # Notes: #
	 If the parameter is empty, use the Default.log file.
	 # Example #
	 ```
	 Tlogger.loadFile("Error.log")
	 ```
	 */
	public static func reloadLog(_ file: String? = nil, erase: Bool = false) {
		
		TLogger.shared.readFile(file)
		if erase { TLogger.shared.eraseFile(file) }
	}
	
	/**
	 Erase the saved logfile.
	 # Notes:
	 If the parameter is empty, use the Default.log file.
	 # Example
	 ```
	 Tlogger.eraseFile("Error.log")
	 ```
	 */
	public static func eraseLog(_ file: String? = nil) {
		
		TLogger.shared.eraseFile(file)
	}
	
	
	
	
	
	
	/// Shared singleton
	public static let shared = TLogger()
	
	
	/// Setst the callback
	weak var delegate: TLogDelegate?
	
	
	/// Sets the reading time format
	public static var formatPrint = "mm:ss.SSS"
	
	
	/// Sets the write output time format
	public static var formatWrite = "yyyy-MM-dd HH:mm:ss.SSS"
	
	
	/// Sets the log file
	public static var file: String  {
		get { TLogger.fileDest }
		set(f) {
			TLogger.fileDest = TLogger.docDir.appending("/" + f)
			TLogger.shared.setFile(TLogger.fileDest)
		}
	}
	
	
	
	private static var formaterDisplay: DateFormatter {
		let formater = DateFormatter()
		formater.dateFormat = formatPrint
		formater.locale = .current
		return formater
	}
	
	private static var formaterWrite: DateFormatter {
		let formater = DateFormatter()
		formater.dateFormat = formatWrite
		formater.locale = .current
		return formater
	}
	
	private static let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
	
	private static var fileDest: String = TLogger.docDir.appending("/Debuging.log")
	
	
	
	private let queue = DispatchQueue(label: "com.t-logger.write")
	
	
	
	
	
	
	public enum LogOrder: String, CaseIterable {
		
		case serial, date, file, filepath, line, sender, function, group, level, message, dash, space, all
		
		static var defaults: [LogOrder] {
			return [ .serial, .date, .file, .line, .sender, .group, .level, .message ]
		}
		
	}
	
	
	private static var _orderPrint: [LogOrder] = LogOrder.defaults
	public static var orderPrint: [LogOrder] {
		get { _orderPrint }
		set(p) {
			if p.contains(.all) { _orderPrint = LogOrder.defaults }
			else { _orderPrint = p }
		}
	}
	
	private static var _orderWrite: [LogOrder] = LogOrder.defaults
	public static var orderWrite: [LogOrder] {
		get { _orderWrite }
		set(w) {
			if w.contains(.all) { _orderWrite = LogOrder.defaults }
			else { _orderWrite = w }
			TLogger.shared.setWrite()
		}
	}
	
	public static var printLevel = TLogLevel.none
	public static var signNull = "∅"
	public static var signDash = "⁃"
	public static var signSerial = (prefix: "(", suffix: ")")
	public static var signBracket = (prefix: "[ ", suffix: " ]")
	public static var signSeparator = " \u{2063}" // INVISIBLE SEPARATOR
	public static var signNewLine = "\u{00AD}\n" // INVISIBLE SEPARATOR
	public static var signIndent = "  "
	
	
	
	private var fileSet = false
	private var writeSet = false
	
	private var count = 0
	
	
	
	
	private init() {
		
		setFile(TLogger.fileDest)
		
	}
	
	
	private func setFile(_ file: String) {
		
		var text = ""
		fileSet = true
		
		if FileManager.default.fileExists(atPath: file) {
			Swift.print("Log file: \(file)")
			
			if let attr = try? FileManager.default.attributesOfItem(atPath: file) {
				let fileSize = attr[FileAttributeKey.size] as! UInt64
				if fileSize > 2 { text = "\n\n\n" }
			}
			
			
		} else { // NewFile
			
			if (FileManager.default.createFile(atPath: file, contents: nil, attributes: nil)) {
				Swift.print("Log file \(file) created successfully.")
			} else {
				Swift.print("ERROR: File not created !")
				fileSet = false
				return
			}
		}
		
		
		if fileSet {
			let fileHandle = FileHandle(forWritingAtPath: file)
			fileHandle?.seekToEndOfFile()
			if let data = text.data(using: .utf8) { fileHandle?.write(data) }
			fileHandle?.closeFile()
		}
		
		setWrite()
	}
	
	private func setWrite() {
		
		writeSet = fileSet && !TLogger.orderWrite.isEmpty
		
	}
	
	
	
	
	public struct IndentManager {
		
		static var space = ""
		
		static func set(_ indent: TLogIndent) {
			
			switch indent {
				case .none: return
				case .plus: space.append(TLogger.signIndent)
				case .minus: if space.count > TLogger.signIndent.count { space = String(space.prefix(TLogger.signIndent.count))  } else { fallthrough }
				case .reset: space = ""
			}
		}
		
		static func set(_ indent: Int) {
			guard indent >= 0 else { space = "" ; return }
			space = String(repeating: " ", count: indent)
		}
		
	}
	
	
	
	public struct Entry {
		
		var serial  : Int
		var date    : Date
		var file    : String?
		var line    : Int?
		var sender  : String?
		var indent  : Int
		var group   : String?
		var level   : TLogLevel
		var message : String
		
		
		var description: String {
			return "\(serial) \(date) \(group ?? "") \(file ?? "") \(line ?? 0) \(sender ?? "") \(indent) \(level) \(message)"
		}
		
		var encoded: String {
			
			var output = ""
			for elem in TLogger.orderWrite {
				switch elem {
					case .space: output.append(" ")
					case .dash: output.append(TLogger.signDash)
					case .serial: output.append(String(serial) + TLogger.signSeparator)
					case .date: output.append(TLogger.formaterWrite.string(from:date) + TLogger.signSeparator)
					case .file: let parts = file?.components(separatedBy: "/") ; if let filename = parts?.last { output.append(String(filename + TLogger.signSeparator)) }
					case .filepath: output.append((file ?? "") + TLogger.signSeparator )
					case .line: output.append((self.line == nil ? "" : String(format: "%d", self.line!) + TLogger.signSeparator))
					case .sender: output.append((sender ?? "") + TLogger.signSeparator)
					case .function: output.append((sender ?? "") + TLogger.signSeparator)
					case .group: output.append((group ?? "") + TLogger.signSeparator )
					case .level: output.append(String(format: "%02lu %@%@", level.rawValue, level.ico, TLogger.signSeparator) )
					case .message: output.append(String(repeating: " ", count: indent) + message)
					default: break
				}
			}
			return output
		}
		
		var composed: String {
			
			var output = ""
			for elem in TLogger.orderPrint {
				
				if !output.isEmpty { output.append(" ") }
				
				switch elem {
					case .space: output.append(" ")
					case .dash: output.append(TLogger.signDash)
					case .serial: output.append(String(format:"%@%03d%@", TLogger.signSerial.prefix, serial, TLogger.signSerial.suffix) )
					case .date: output.append(TLogger.formaterDisplay.string(from:date))
					case .group: output.append(group ?? "")
					case .file: let parts = file?.components(separatedBy: "/") ; if let filename = parts?.last { output.append(String(filename.dropLast(6)) ) }
					case .filepath: output.append((file ?? "") )
					case .line: if let num = line { output.append(String(format:"%4d", num)) }
					case .sender: if let send = sender?.components(separatedBy:"(" ) { output.append(TLogger.signBracket.prefix + send[0] + TLogger.signBracket.suffix ) }
					case .function: output.append((sender ?? "") )
					case .level: output.append(level.ico)
					case .message: output.append(message)
					default: break
				}
			}
			
			return IndentManager.space + output
		}
		
	}
	
	
	
	
	
	fileprivate func add(_ message: String, group: String? = nil, file: String? = nil, line: Int? = nil, sender: String? = nil, level: TLogLevel = .default, indent: TLogIndent = TLogIndent.none) {
		
		queue.async { [weak self] in
			
			self?.count += 1
			
			if indent == .reset || indent == .minus { IndentManager.set(indent) }
			
			let data = TLogger.Entry(serial: self?.count ?? 0, date: Date(), file: file, line: line, sender: sender, indent: IndentManager.space.count, group: group, level: level, message: message)
			
			let log = "\n" + data.composed
			
			if data.level >= TLogger.printLevel { FileHandle.standardError.write(Data(log.utf8)) }
			
			DispatchQueue.main.async {
				self?.delegate?.callbackLog(data)
			}
			
			if self?.writeSet != nil { self?.writeFile(TLogger.signNewLine + data.encoded) }
			
			
			if indent == .plus { IndentManager.set(indent) }
			
			
		}
	}
	
	
	fileprivate	func app(_ text: String, level: TLogLevel = .default) {
		
		if level >= TLogger.printLevel { FileHandle.standardOutput.write(Data(text.utf8)) }
		
		let data = Entry(serial: -1, date: Date(), file: nil, line: nil, sender: nil, indent: 0, group: nil, level: level, message: text)
		
		delegate?.callbackLog(data)
		
		if writeSet { writeFile(text) }
	}
	
	
	fileprivate func writeFile(_ text: String) {
		
		//		DispatchQueue.global(qos: .background).async {
		
		let fileHandle = FileHandle(forWritingAtPath:TLogger.fileDest)
		fileHandle?.seekToEndOfFile()
		
		if let data = text.data(using: .utf8) { fileHandle?.write(data) }
		fileHandle?.closeFile()
		
		//		}
		
	}
	
	
	fileprivate func readFile(_ file: String? = nil) {
		
		let datas = loadFile(file)
		
		for data in datas {
			
			IndentManager.set(data.indent)
			
			let log = "\n› " + data.composed
			
			FileHandle.standardOutput.write(Data(log.utf8))
			
			delegate?.callbackLog(data)
		}
		
		Swift.print("")
	}
	
	
	fileprivate func loadFile(_ file: String? = nil) -> [Entry] {
		
		var content = [String]()
		
		let file = file ?? TLogger.fileDest
		
		do {
			
			let text = try String(contentsOfFile: file, encoding: .utf8)
			content = text.components(separatedBy: TLogger.signNewLine)
			content = content.dropLast()
			
		} catch {
			
			Swift.print(TLogLevel.error.ico + " ERROR: Failed to load file: \(file)")
			content = [""]
		}
		
		var datas = [Entry]()
		
		for line in content {
			
			let parts = line.components(separatedBy:TLogger.signSeparator)
			let order = TLogger.orderWrite.isEmpty ? LogOrder.defaults : TLogger.orderWrite
			
			guard parts.count >= order.count else { continue }
			
			var serial = 0
			var date = Date()
			var file = ""
			var line = 0
			var sender = ""
			var group = ""
			var level = TLogLevel(rawValue: 0)!
			var message = ""
			
			if let i = order.firstIndex(of: .serial) { serial = Int(parts[i]) ?? 0 }
			if let i = order.firstIndex(of: .date) { date = TLogger.formaterWrite.date(from: parts[i]) ?? Date() }
			if let i = order.firstIndex(of: .group) { group = parts[i] }
			if let i = order.firstIndex(of: .file) { file = parts[i] }
			if let i = order.firstIndex(of: .line) { line = Int(parts[i]) ?? 0 }
			if let i = order.firstIndex(of: .sender) { sender = parts[i] }
			if let i = order.firstIndex(of: .level) { level = TLogLevel.init(rawValue: Int(parts[i].prefix(2)) ?? 0)! }
			if let i = order.firstIndex(of: .message) { message = parts[i] }
			
			let data = Entry(serial: serial, date: date, file: file, line: line, sender: sender, indent: 0, group: group, level: level, message: message)
			
			datas.append(data)
		}
		return datas
	}
	
	
	fileprivate func eraseFile(_ file: String? = nil) {
		
		let file = file ?? TLogger.fileDest
		let str = ""
		
		do {
			
			try str.write(toFile: file, atomically: true, encoding: String.Encoding.utf8)
			// Swift.print("File erased: \(fileSrc)")
			
		} catch {
			
			Swift.print("ERROR: Failed to erase file ! ")
			Swift.print(error)
		}
	}
	
	
	
} // End





