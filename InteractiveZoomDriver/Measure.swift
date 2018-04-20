//
//  Measure.swift
//  InteractiveZoomDriver
//
//  Created by muukii on 4/16/18.
//  Copyright © 2018 Jinsei Shima. All rights reserved.
//

import Foundation
import UIKit

public protocol MeasureLoggerType: class {
    func didEndMeasurement(result: Measure.Result)
}

open class Measure: Hashable {

    public struct Result {
        public let name: String
        public let startAt: TimeInterval
        public let endAt: TimeInterval
        public let time: TimeInterval
        public let threshold: TimeInterval?
        public let isThresholdExceeded: Bool

        public let file: String
        public let function: String
        public let line: UInt
    }

    public static func == (lhs: Measure, rhs: Measure) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue ^ name.hashValue
    }

    // MARK: - Properties
    open static var defaultLogger: MeasureLoggerType?

    open var logger: MeasureLoggerType? = Measure.defaultLogger

    open let name: String

    open var threshold: TimeInterval?

    open var startAt: TimeInterval?

    open var endAt: TimeInterval?

    public let file: String
    public let function: String
    public let line: UInt

    // MARK: - Initializers
    public required init(name: String, threshold: TimeInterval? = nil, file: String = #file, function: String = #function, line: UInt = #line) {

        self.name = name
        self.threshold = threshold
        self.file = file
        self.function = function
        self.line = line
    }

    @discardableResult
    open func start() -> Measure {

        startAt = CACurrentMediaTime()
        return self
    }

    @discardableResult
    open func end() -> Result {

        let _endAt = CACurrentMediaTime()

        guard let startAt = startAt else {
            assertionFailure("Measurement has not begun, please call start()")
            return Result(
                name: name + " :: Measurement has not begun, please call start()",
                startAt: TimeInterval(),
                endAt: TimeInterval(),
                time: 0,
                threshold: nil,
                isThresholdExceeded: false,
                file: file,
                function: function,
                line: line
            )
        }

        endAt = _endAt

        let time = _endAt - startAt

        let isThresholdExceeded: Bool

        if let t = threshold, time > t {
            isThresholdExceeded = true
        } else {
            isThresholdExceeded = false
        }

        let result = Result(
            name: name,
            startAt: startAt,
            endAt: _endAt,
            time: time,
            threshold: threshold,
            isThresholdExceeded: isThresholdExceeded,
            file: file,
            function: function,
            line: line
        )

        logger?.didEndMeasurement(result: result)

        print(result.time)

        return result
    }

    @discardableResult
    open func reset() -> Self {
        startAt = nil
        endAt = nil
        return self
    }

    open class func run(name: String, threshold: TimeInterval?, block: () -> Void) -> Result {

        let measure = self.init(name: name, threshold: threshold)
        measure.start()
        block()
        return measure.end()
    }
}
