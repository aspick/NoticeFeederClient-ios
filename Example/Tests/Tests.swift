// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import NoticeFeederClient

class NoticeSpec: QuickSpec {
    override func spec() {
        describe("verifyTarget") {
            [
                ["1", "1.1", true],
                ["1.1", "1.1", true],
                ["1.1", "1.2", false],
                ["1.3", "1.2", false],
                ["1.2", "1.2.1", true],
                ["1.2.0", "1.2.1", false],
            ].forEach { (row) in
                it("target: \(row[0]), current: \(row[1]) should return: \(row[2])") {
                    let target = row[0] as! String
                    let current = row[1] as! String
                    let actual = Notice.verifyTarget(target: target, current: current)
                    let expected = row[2] as? Bool
                    expect(actual) == expected
                }
            }
        }
    }
}
