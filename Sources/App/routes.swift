import Foundation
import Vapor

final class CpuFlags: Content {
    var sign: Bool
    var zero: Bool
    var auxCarry: Bool
    var parity: Bool
    var carry: Bool
}

final class CpuState: Content {
    var a: UInt8
    var b: UInt8
    var c: UInt8
    var d: UInt8
    var e: UInt8
    var h: UInt8
    var l: UInt8
    var stackPointer: UInt16
    var programCounter: UInt16
    var cycles: UInt64
    var flags: CpuFlags
    var interruptsEnabled: Bool
}

final class Cpu: Content {
    var opcode: UInt8
    var id: String
    var state: CpuState
}

struct AddressQuery: Content {
    var address: UInt16
}

func routes(_ app: Application) throws {
    let readMemoryApi = ProcessInfo.processInfo.environment["READ_MEMORY_API"]!
    let writeMemoryApi = ProcessInfo.processInfo.environment["WRITE_MEMORY_API"]!

    app.get("status") { req -> String in
        return "Healthy"
    }

    app.get("api", "v1", "debug", "readMemory") { req -> String in
        let address = try req.query.decode(AddressQuery.self)
        return "\(address.address & 0xFF)"
    }

    app.get("api", "v1", "debug", "writeMemory") { req -> String in
        return ""
    }

    app.post("api", "v1", "execute") { req -> EventLoopFuture<Cpu> in
        let cpu = try req.content.decode(Cpu.self)
        let hl = (UInt16(cpu.state.h) << 8) | UInt16(cpu.state.l)
        let id = cpu.id

        cpu.state.cycles += 5

        switch cpu.opcode {
        case 0x40: // MOV B,B
            cpu.state.b = cpu.state.b
        case 0x41: // MOV B,C
            cpu.state.b = cpu.state.c
        case 0x42: // MOV B,D
            cpu.state.b = cpu.state.d
        case 0x43: // MOV B,E
            cpu.state.b = cpu.state.e
        case 0x44: // MOV B,H
            cpu.state.b = cpu.state.h
        case 0x45: // MOV B,L
            cpu.state.b = cpu.state.l
        case 0x46: // MOV B,(HL)
            cpu.state.cycles += 2
            return req.client.get("\(readMemoryApi)?id=\(cpu.id)&address=\(hl)").flatMapThrowing { res -> String in
                res.body!.getString(at: 0, length: res.body!.readableBytes)!
            }.map { newValue in
                cpu.state.b = UInt8(newValue)!
                return cpu
            }
        case 0x47: // MOV B,A
            cpu.state.b = cpu.state.a
        case 0x48: // MOV C,B
            cpu.state.c = cpu.state.b
        case 0x49: // MOV C,C
            cpu.state.c = cpu.state.c
        case 0x4A: // MOV C,D
            cpu.state.c = cpu.state.d
        case 0x4B: // MOV C,E
            cpu.state.c = cpu.state.e
        case 0x4C: // MOV C,H
            cpu.state.c = cpu.state.h
        case 0x4D: // MOV C,L
            cpu.state.c = cpu.state.l
        case 0x4E: // MOV C,(HL)
            cpu.state.cycles += 2
            return req.client.get("\(readMemoryApi)?id=\(cpu.id)&address=\(hl)").flatMapThrowing { res -> String in
                res.body!.getString(at: 0, length: res.body!.readableBytes)!
            }.map { newValue in
                cpu.state.c = UInt8(newValue)!
                return cpu
            }
        case 0x4F: // MOV C,A
            cpu.state.c = cpu.state.a
        case 0x50: // MOV D,B
            cpu.state.d = cpu.state.b
        case 0x51: // MOV D,C
            cpu.state.d = cpu.state.c
        case 0x52: // MOV D,D
            cpu.state.d = cpu.state.d
        case 0x53: // MOV D,E
            cpu.state.d = cpu.state.e
        case 0x54: // MOV D,H
            cpu.state.d = cpu.state.h
        case 0x55: // MOV D,L
            cpu.state.d = cpu.state.l
        case 0x56: // MOV D,(HL)
            cpu.state.cycles += 2
            return req.client.get("\(readMemoryApi)?id=\(cpu.id)&address=\(hl)").flatMapThrowing { res -> String in
                res.body!.getString(at: 0, length: res.body!.readableBytes)!
            }.map { newValue in
                cpu.state.d = UInt8(newValue)!
                return cpu
            }
        case 0x57: // MOV D,A
            cpu.state.d = cpu.state.a
        case 0x58: // MOV E,B
            cpu.state.e = cpu.state.b
        case 0x59: // MOV E,C
            cpu.state.e = cpu.state.c
        case 0x5A: // MOV E,D
            cpu.state.e = cpu.state.d
        case 0x5B: // MOV E,E
            cpu.state.e = cpu.state.e
        case 0x5C: // MOV E,H
            cpu.state.e = cpu.state.h
        case 0x5D: // MOV E,L
            cpu.state.e = cpu.state.l
        case 0x5E: // MOV E,(HL)
            cpu.state.cycles += 2
            return req.client.get("\(readMemoryApi)?id=\(cpu.id)&address=\(hl)").flatMapThrowing { res -> String in
                res.body!.getString(at: 0, length: res.body!.readableBytes)!
            }.map { newValue in
                cpu.state.e = UInt8(newValue)!
                return cpu
            }
        case 0x5F: // MOV E,A
            cpu.state.e = cpu.state.a
        case 0x60: // MOV H,B
            cpu.state.h = cpu.state.b
        case 0x61: // MOV H,C
            cpu.state.h = cpu.state.c
        case 0x62: // MOV H,D
            cpu.state.h = cpu.state.d
        case 0x63: // MOV H,E
            cpu.state.h = cpu.state.e
        case 0x64: // MOV H,H
            cpu.state.h = cpu.state.h
        case 0x65: // MOV H,L
            cpu.state.h = cpu.state.l
        case 0x66: // MOV H,(HL)
            cpu.state.cycles += 2
            return req.client.get("\(readMemoryApi)?id=\(cpu.id)&address=\(hl)").flatMapThrowing { res -> String in
                res.body!.getString(at: 0, length: res.body!.readableBytes)!
            }.map { newValue in
                cpu.state.h = UInt8(newValue)!
                return cpu
            }
        case 0x67: // MOV H,A
            cpu.state.h = cpu.state.a
        case 0x68: // MOV L,B
            cpu.state.l = cpu.state.b
        case 0x69: // MOV L,C
            cpu.state.l = cpu.state.c
        case 0x6A: // MOV L,D
            cpu.state.l = cpu.state.d
        case 0x6B: // MOV L,E
            cpu.state.l = cpu.state.e
        case 0x6C: // MOV L,H
            cpu.state.l = cpu.state.h
        case 0x6D: // MOV L,L
            cpu.state.l = cpu.state.l
        case 0x6E: // MOV L,(HL)
            cpu.state.cycles += 2
            return req.client.get("\(readMemoryApi)?id=\(cpu.id)&address=\(hl)").flatMapThrowing { res -> String in
                res.body!.getString(at: 0, length: res.body!.readableBytes)!
            }.map { newValue in
                cpu.state.l = UInt8(newValue)!
                return cpu
            }
        case 0x6F: // MOV L,A
            cpu.state.l = cpu.state.a
        case 0x70: // MOV (HL),B
            cpu.state.cycles += 2
            return req.client.post("\(writeMemoryApi)?id=\(id)&address=\(hl)&value=\(cpu.state.b)").map { res in return cpu }
        case 0x71: // MOV (HL),C
            cpu.state.cycles += 2
            return req.client.post("\(writeMemoryApi)?id=\(id)&address=\(hl)&value=\(cpu.state.c)").map { res in return cpu }
        case 0x72: // MOV (HL),D
            cpu.state.cycles += 2
            return req.client.post("\(writeMemoryApi)?id=\(id)&address=\(hl)&value=\(cpu.state.d)").map { res in return cpu }
        case 0x73: // MOV (HL),E
            cpu.state.cycles += 2
            return req.client.post("\(writeMemoryApi)?id=\(id)&address=\(hl)&value=\(cpu.state.e)").map { res in return cpu }
        case 0x74: // MOV (HL),H
            cpu.state.cycles += 2
            return req.client.post("\(writeMemoryApi)?id=\(id)&address=\(hl)&value=\(cpu.state.h)").map { res in return cpu }
        case 0x75: // MOV (HL),L
            cpu.state.cycles += 2
            return req.client.post("\(writeMemoryApi)?id=\(id)&address=\(hl)&value=\(cpu.state.l)").map { res in return cpu }
        case 0x76: // HALT handled elsewhere
            throw Abort(.badRequest)
        case 0x77: // MOV (HL),A
            cpu.state.cycles += 2
            return req.client.post("\(writeMemoryApi)?id=\(id)&address=\(hl)&value=\(cpu.state.a)").map { res in return cpu }
        case 0x78: // MOV A,B
            cpu.state.a = cpu.state.b
        case 0x79: // MOV A,C
            cpu.state.a = cpu.state.c
        case 0x7A: // MOV A,D
            cpu.state.a = cpu.state.d
        case 0x7B: // MOV A,E
            cpu.state.a = cpu.state.e
        case 0x7C: // MOV A,H
            cpu.state.a = cpu.state.h
        case 0x7D: // MOV A,L
            cpu.state.a = cpu.state.l
        case 0x7E: // MOV A,(HL)
            cpu.state.cycles += 2
            return req.client.get("\(readMemoryApi)?id=\(cpu.id)&address=\(hl)").flatMapThrowing { res -> String in
                res.body!.getString(at: 0, length: res.body!.readableBytes)!
            }.map { newValue in
                cpu.state.a = UInt8(newValue)!
                return cpu
            }
        case 0x7F: // MOV A,A
            cpu.state.a = cpu.state.a
        default:
            throw Abort(.badRequest)
        }

        return req.eventLoop.makeSucceededFuture(cpu)
    }
}
