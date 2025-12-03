struct SubscribePacketResponse {}

class SubscribePacket: MedtrumBasePacket, MedtrumBasePacketProtocol {
    typealias T = SubscribePacketResponse

    let commandType: UInt8 = CommandType.SUBSCRIBE
    let mimimumDataSize: Int = 0

    func getRequestBytes() -> Data {
        UInt64(4095).toData(length: 2)
    }

    func parseResponse() -> SubscribePacketResponse {
        SubscribePacketResponse()
    }
}
