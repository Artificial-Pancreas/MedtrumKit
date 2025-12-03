class SynchronizePacket: MedtrumBasePacket, MedtrumBasePacketProtocol {
    typealias T = SynchronizePacketResponse

    let commandType: UInt8 = CommandType.SYNCHRONIZE
    let mimimumDataSize: Int = 9

    func getRequestBytes() -> Data {
        Data()
    }

    func parseResponse() -> SynchronizePacketResponse {
        NotificationPacket().handle(
            state: PatchState(rawValue: totalData[6]) ?? .none,
            fieldMask: UInt16(totalData.subdata(in: 7 ..< 9).toUInt64()),
            syncData: totalData.subdata(in: 9 ..< totalData.count)
        )
    }
}
