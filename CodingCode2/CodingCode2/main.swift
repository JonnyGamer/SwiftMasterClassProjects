//
//  main.swift
//  CodingCode2
//
//  Created by Jonathan Pappas on 4/29/21.
//

import Foundation

let mindShield = """
var foo: int = 1
foo = add(foo, 1)

"""

let masterStack = SuperStack()

let preProgram: [StackCode] = [
    
    // Add Function
    .functionWithParams(name: "add", parameters: .tuple([.int, .int]), returnType: .int, code: { param in [
        //.program({ print("It was too harsh \(int(param[0]) + int(param[1]))") }),
        .returnValue([ (.int, (int(param[0]) + int(param[1]))) ])
    ]}),
    
    // Print Function
    .functionWithParams(name: "print", parameters: .any, returnType: .void, code: { param in [
        .program({ magicPrint(param) }),
    ]}),
    
]
preProgram.run(masterStack)




let shortProgram: [StackCode] = [

    
    .function(name: "foo", code: [
        .program({ print("Foo was ran! Start") }),
    ]),
    
    .program({ print("Starting Program...") }),
    .goToVoidFunction(name: "foo"),
    
    .run([
        
        .function(name: "bar", code: [
            .program({ print("BAR was ran!") }),
            .goToVoidFunction(name: "foo"),
        ]),
        .goToVoidFunction(name: "bar"),
    
    ]),
    
    .goToVoidFunction(name: "bar"),
    .goToFunction(name: "print", parameters: [.literal(.str, "End of Program...")]),
    
    .goToFunction(name: "print", parameters: [.literal(.int, 5), .literal(.int, 6)]),
    
    // print(add(5, 6))
    .goToFunction(name: "print", parameters: [.goToFunction(name: "add", parameters: [.literal(.int, 5), .literal(.int, 6)])]),
    
    .goToFunction(name: "print", parameters: [.literal(.int, 5)]),
    
    // print((5 + 5) + (5 + 5))
    ._run(.print, [._run(.add, [._run(.add, [.literal(.int, 5), .literal(.int, 5)]), ._run(.add, [.literal(.int, 5), .literal(.int, 5)])])])
    
]

shortProgram.run(masterStack)