import Foundation
import LoopKit

public class UnfinalizedDose {
    public typealias RawValue = [String: Any]

    private let logger = MedtrumLogger(category: "UnfinalizedDose")

    public let type: DoseType
    public let startDate: Date
    public let estimatedEndDate: Date
    public let unit: DoseUnit
    public let value: Double
    public var deliveredUnits: Double = 0
    public let insulinType: InsulinType?
    public let automatic: Bool

    public init(units: Double, duration: TimeInterval, activationType: BolusActivationType, insulinType: InsulinType?) {
        var estimatedEndDate = Date.now
        estimatedEndDate.addTimeInterval(duration)

        type = .bolus
        unit = .units
        value = units
        startDate = Date.now
        self.estimatedEndDate = estimatedEndDate
        self.insulinType = insulinType
        automatic = activationType.isAutomatic
    }

    public init?(rawValue: RawValue) {
        if let rawType = rawValue["type"] as? DoseType.RawValue, let type = DoseType(rawValue: rawType) {
            self.type = type
        } else {
            logger.warning("Couldn't convert type")
            return nil
        }

        if let rawUnit = rawValue["unit"] as? DoseUnit.RawValue, let unit = DoseUnit(rawValue: rawUnit) {
            self.unit = unit
        } else {
            logger.warning("Couldn't convert unit")
            return nil
        }

        if let value = rawValue["value"] as? Double {
            self.value = value
        } else {
            logger.warning("Couldn't convert value")
            return nil
        }

        if let rawStartDate = rawValue["startDate"] as? Date {
            startDate = rawStartDate
        } else {
            logger.warning("Couldn't convert startDate")
            return nil
        }

        if let rawEstimatedEndDate = rawValue["estimatedEndDate"] as? Date {
            estimatedEndDate = rawEstimatedEndDate
        } else {
            logger.warning("Couldn't convert estimatedEndDate")
            return nil
        }

        if let rawDeliveredUnits = rawValue["deliveredUnits"] as? Double {
            deliveredUnits = rawDeliveredUnits
        } else {
            logger.warning("Couldn't convert deliveredUnits")
            return nil
        }

        if let rawInsulinType = rawValue["insulinType"] as? InsulinType.RawValue,
           let insulinType = InsulinType(rawValue: rawInsulinType)
        {
            self.insulinType = insulinType
        } else {
            insulinType = nil
        }

        if let rawAutomatic = rawValue["automatic"] as? Bool {
            automatic = rawAutomatic
        } else {
            logger.warning("Couldn't convert automatic")
            return nil
        }
    }

    public var rawValue: RawValue {
        var raw: RawValue = [:]

        raw["type"] = type.rawValue
        raw["unit"] = unit.rawValue
        raw["value"] = value
        raw["startDate"] = startDate
        raw["estimatedEndDate"] = estimatedEndDate
        raw["deliveredUnits"] = deliveredUnits
        raw["insulinType"] = insulinType?.rawValue
        raw["automatic"] = automatic

        return raw
    }

    public func toDoseEntry(isMutable: Bool = false, useEstimatedEndDate: Bool = false) -> DoseEntry {
        var endDate = isMutable || useEstimatedEndDate ? estimatedEndDate : Date.now
        if useEstimatedEndDate, endDate > Date.now {
            // The endDate of a bolus cannot be in the future...
            endDate = Date.now
        }

        return DoseEntry(
            type: .bolus,
            startDate: startDate,
            endDate: endDate,
            value: value.rounded(toPlaces: 2),
            unit: .units,
            deliveredUnits: isMutable ? nil : deliveredUnits.rounded(toPlaces: 2),
            insulinType: insulinType,
            automatic: automatic,
            isMutable: isMutable
        )
    }
}
