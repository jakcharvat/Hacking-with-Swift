import UIKit

let string = "This is a test string"
//let attributes: [NSAttributedString.Key : Any] = [
//    .font: UIFont.boldSystemFont(ofSize: 24),
//    .foregroundColor: UIColor.white,
//    .backgroundColor: UIColor.red
//]
//
//let attributedString = NSAttributedString(string: string, attributes: attributes)

//let attributedString = NSMutableAttributedString(string: string)
//attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
//attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
//attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
//attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
//attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))
//
//attributedString.addAttribute(.link, value: URL(string: "https://google.com")!, range: NSRange(location: 10, length: 4))


extension String {
    func withPrefix(_ prefix: String) -> String {
        if hasPrefix(prefix) { return self }
        return prefix + self
    }
    
    var isNumeric: Bool { Double(self) != nil }
    var lines: [String] { components(separatedBy: .newlines) }
}

let str = "pet"
let pf = str.withPrefix("car")
pf.isNumeric
"21".isNumeric
"This\nis\na\ntest".lines

