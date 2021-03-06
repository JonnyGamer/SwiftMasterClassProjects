//
//  StringParser.swift
//  CodingCode2
//
//  Created by Jonathan Pappas on 4/29/21.
//

import Foundation

struct Regex {
    var this: String
    init(_ this: String) { self.this = this }
    func matches(_ the: String) -> Bool {
        return the.replacingAll(matching: this, with: "") != the
    }
}
extension String {
    func replacingAll(matching: Regex, with: Self) -> Self {
        return replacingOccurrences(of: matching.this, with: with, options: .regularExpression)
    }
    func replacingAll(matching: String, with: Self) -> Self {
        return replacingOccurrences(of: matching, with: with, options: .regularExpression)
    }
//    func splitAt(splitter: Self, notInside: (String, String)) -> [Self] {
//        
//    }
//    func splitAllTopLevelCommas() -> [Self] {
//        return splitAt(splitter: ",", notInside: ("(", ")"))
//    }
//    func downALevel() -> Self {
//        return self.replacingAll(matching: Regex(#"^[^\(]*\("#), with: "").replacingAll(matching: Regex(#"\)[^)]*$"#), with: "")
//    }
    
}
//
func tests() {

    //print("hello(foo, bar)".downALevel())
    //print("hello(foo, bar) wowow()()() foobar".downALevel())

}


let mindShield = """
var foo : int = 1
var bar : int = 1

foo = add(foo, 1)
print(foo, bar, print(bar, bar), foo)

print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))
print(add(add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1))), add(add(add(1, 1), add(1, 1)), add(add(1, 1), add(1, 1)))))

//func sub (int, int) -> int
//    return 0

// func sub (int, int) -> int
//    negative(add($0, $1))


"""


extension String {
    func runProgram(_ stack: SuperStack) {
        
        var d1 = Date().timeIntervalSince1970
        print("Compiling Program")
        var compiling: [StackCode] = []
        
        for line in mindShield.split(separator: "\n") {
            let line = String(line)
            if line.hasPrefix("//") { continue }
            
            compiling.append(line.parseLine())
        }
        
        print("Finished Compiling")
        print("Spent", Date().timeIntervalSince1970 - d1, "seconds to compile")
        d1 = Date().timeIntervalSince1970
        print("Running Program")
        
        compiling.run(stack.subStack())
        print("Finished Running Program")
        print("Spent", Date().timeIntervalSince1970 - d1, "seconds to run")
        print("End.")
    }
    
    func parseType() -> MagicTypes {
        return .void
    }
    
    func parseLine() -> StackCode {
        var parsing = self.split(separator: " ").map {  String($0) }
        
        
        // var n : n = n
        if (Regex(#"^var .+ : .+ = .+$"#).matches(self)) {
            return .createValue(name: parsing[1], constant: false, setTo: [ parsing[5].parseLine() ])
        }
        // let n : n = n
        else if (Regex(#"^let .+ : .+ = .+$"#).matches(self)) {
            return .createValue(name: parsing[1], constant: true, setTo: [ parsing[5].parseLine() ])
        }
        
        // func n someType -> someReturn
//        else if (Regex(#"^func .+ .+ \-\> .+"#).matches(self)) {
//
//            let funcName = self.replacingAll(matching: Regex(#"^func "#), with: "$1").replacingAll(matching: Regex(#" .+"#), with: "")
//            var funcType = self.replacingAll(matching: Regex(#"^func [^ ]+ "#), with: "")
//            let paramType = funcType.replacingAll(matching: Regex(#" \-\>.+"#), with: "")
//            let returnType = funcType.replacingAll(matching: Regex(#".+\-\> "#), with: "")
//
//            //return .functionWithParams(name: funcName, parameters: paramType.parseType(), returnType: returnType.parseType(), code: <#T##([Any]) -> [StackCode]#>)
//            //return .createValue(name: parsing[1], constant: true, setTo: [ parsing[5].parseLine() ])
//        }
        
        else if Regex(#".+ = .+"#).matches(self) {
            return .mutateValue(name: parsing[0], setTo: [ self.replacingAll(matching: Regex(#"^.+ = "#), with: "").parseLine() ])
        }

        else if Regex(#"^[0-9]+$"#).matches(self) {
            return .literal(.int, self)
        }
        
        else if Regex(#"^[^ ]+\(.*\)$"#).matches(self) {
            let foo = self.replacingAll(matching: Regex(#"\(.*\)"#), with: "")
            
            //print(Regex(#"[^\(]*(\(.*\))[^\)]*"#).matches(self))
            var functionName = self.replacingAll(matching: Regex(#"(?<=\().*(?=\))"#), with: "")
            functionName.removeLast(2)
            
            var params: [String] = [""]
            var open = 0
            for i in self {
                if i == "(" { open += 1; if open == 1 { continue } }
                if i == ")" { open -= 1; if open == 0 { continue } }
                
                
                if open > 0 {
                    if i == " ", params.last?.isEmpty == true { continue }
                    if i == ",", open == 1 {
                        params.append("")
                        continue
                    }
                    params[params.count-1].append(i)
                }
            }
            //print(params) // Neat to keep
            
            return .goToFunction(name: functionName, parameters: params.map { $0.parseLine() })
            
            print("GLUE", self)
            //return .goToFunction(name: foo, parameters: <#T##[StackCode]#>)
        }
        
        return .getValue(name: self)
        
        return .literal(.void, ())
        fatalError("Couldn't Parse Line...")
        
    }
}
