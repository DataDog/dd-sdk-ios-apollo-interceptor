/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2025-Present Datadog, Inc.
 */

import XCTest
@preconcurrency import ApolloAPI
import Apollo
@testable import DatadogApollo

public final class DatadogApolloURLSessionTests: XCTestCase {
    func testURLSessionInitialization() throws {
        let delegate = DatadogApolloDelegate()
        let config = URLSessionConfiguration.default
        let urlSession = DatadogApolloURLSession(configuration: config, delegate: delegate)

        XCTAssertNotNil(urlSession)
    }

    func testChunksMethodReturnsAsyncSequence_WithDelegateCallbacks() async throws {
        let delegate = DatadogApolloDelegate()
        let config = URLSessionConfiguration.ephemeral
        let urlSession = DatadogApolloURLSession(configuration: config, delegate: delegate)

        // Use a data URL to test delegate callbacks without requiring network access
        let testData = "test data".data(using: .utf8)!
        let base64 = testData.base64EncodedString()
        let dataURL = URL(string: "data:text/plain;base64,\(base64)")!
        let request = URLRequest(url: dataURL)

        let (sequence, response) = try await urlSession.chunks(for: request)

        // Verify we got a sequence and response
        XCTAssertNotNil(sequence, "Should return an async sequence")
        XCTAssertNotNil(response, "Should return a response")

        // Verify we can iterate the sequence and collect data
        var collectedData = Data()
        var iterator = sequence.makeAsyncIterator()
        while let chunk = try await iterator.next() {
            if let dataChunk = chunk as? Data {
                collectedData.append(dataChunk)
            }
        }

        // Verify we received the correct data through delegate callbacks
        XCTAssertEqual(collectedData, testData, "Should receive data through delegate callbacks")
    }

    func testChunksMethodHandlesInvalidURL() async throws {
        let delegate = DatadogApolloDelegate()
        let config = URLSessionConfiguration.ephemeral
        let urlSession = DatadogApolloURLSession(configuration: config, delegate: delegate)

        // Use an invalid/unreachable URL
        let invalidURL = URL(string: "https://invalid.invalid.invalid.test")!
        let request = URLRequest(url: invalidURL)

        // Should throw an error for unreachable host
        do {
            _ = try await urlSession.chunks(for: request)
        } catch {
            // Expected - network error for invalid host
            XCTAssertNotNil(error)
        }
    }
}
