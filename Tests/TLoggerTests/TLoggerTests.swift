    import XCTest
    @testable import TLogger

    final class TLoggerTests: XCTestCase {
			
			
			func testFile() {

//				TLogger.shared.delegate = self
				
				
				TLogger.orderPrint = [ .message]
				tlog(".message")
				
				TLogger.reloadLog()
				TLogger.eraseLog()
				
				TLogger.orderPrint = [.all]
				
				
				TLogger.log("Test message...", accessibilityArrayAttributeValues(_:index:maxCount:))
				
				Swift.print("\n\n")
				
				tlog("Nothing special", level: .none)
				tlog("To do something about...", level: .comment)
				tlog("Job done", level: .done)
				tlog("ERROR: File missing !", level: .error)
				
			}
			
			func testBasic() {
				
				tlog("String")
				let opt0: String? = nil
				let opt1: String? = ""
				tlog("Null:", opt0)
				tlog("Opt:", opt1)
				tlog("Date:", Date() )
				tlog("Objects:", [ ["a","b","c"], ["d":"D"], 123.4 ] as [Any] )
				
				Swift.print("\n\n")
			}
			
			func testIndentation() {

				
				tlog(".none", indent: .none)
				tlog(".plus", indent: .plus)
				tlog("1")
				tlog("2")
				tlog(".plus", indent: .plus)
				tlog("3")
				tlog("4")
				tlog(".plus", indent: .plus)
				tlog("5")
				tlog(".minus", indent: .minus)
				tlog("6")
				tlog(".reset", indent: .reset)
				tlog("7")
				
				Swift.print("\n\n")
			}
			
			func testLevels() {
				
				tlog("none", level: .none)
				tlog("comment", level: .comment)
				tlog("done", level: .done)
				tlog("error", level: .error)
				
				
				Swift.print("\n\n")
			}
			
			func testOrder() {
				
				TLogger.formatWrite = "mm:ss.SSS"
				TLogger.printLevel = .warning
				TLogger.orderPrint = [.serial, .date, .message]
				tlog("message")

				TLogger.orderPrint = [.sender, .message]
				tlog("sender")
				
				TLogger.orderPrint = [.level, .space, .message]
				TLogger.log(Data(), Date(), level: .error)

				Swift.print("\n\n")
			}
			
			func testJoin() {
				
				tlog("A")
				tlog("B")
				tlog("1", join: true)
				tlog("2", "3", "4", join: true)
				Swift.print("P")
				tlog("5", join: true)
				tlog("X")
				
				Swift.print("\n\n")
			}
			
    }
