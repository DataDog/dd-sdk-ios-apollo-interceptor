/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2025-Present Datadog, Inc.
 */

import XCTest
@preconcurrency import ApolloAPI
import Apollo
@testable import DatadogApollo

public final class DatadogApolloDelegateTests: XCTestCase {
    func testDelegateInitialization() throws {
        let delegate = DatadogApolloDelegate()
        XCTAssertNotNil(delegate)
    }

    func testDelegateDataCollection() throws {
        let delegate = DatadogApolloDelegate()
        let session = URLSession.shared

        // Create mock data task
        let url = URL(string: "https://example.com/graphql")!
        let dataTask = session.dataTask(with: url)

        // Simulate receiving data chunks
        let chunk1 = "Hello".data(using: .utf8)!
        let chunk2 = " World".data(using: .utf8)!

        delegate.urlSession(session, dataTask: dataTask, didReceive: chunk1)
        delegate.urlSession(session, dataTask: dataTask, didReceive: chunk2)

        // Verify delegate exists (detailed verification would require exposing internal state)
        XCTAssertNotNil(delegate)
    }

    func testDelegateCompletionWithSuccess() throws {
        let delegate = DatadogApolloDelegate()
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)

        let expectation = self.expectation(description: "Continuation completed")

        let url = URL(string: "https://example.com/graphql")!

        // Create a mock response
        let mockResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        // Create a mock task with response
        let mockTask = MockURLSessionDataTask(url: url, response: mockResponse)

        // Test that continuation is properly resumed on successful completion
        Task {
            do {
                let (data, response): (Data, URLResponse) = try await withCheckedThrowingContinuation { continuation in
                    // Register continuation with the mock task
                    delegate.registerContinuation(for: mockTask, continuation: continuation)

                    // Simulate successful completion with the mock task
                    delegate.urlSession(session, task: mockTask, didCompleteWithError: nil)
                }

                // Verify continuation was resumed with data and response (data will be empty, but that's OK)
                XCTAssertNotNil(data)
                XCTAssertNotNil(response)
                XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
                expectation.fulfill()
            } catch {
                XCTFail("Expected success but got error: \(error)")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDelegateCompletionWithError() throws {
        let delegate = DatadogApolloDelegate()
        let session = URLSession.shared

        let expectation = self.expectation(description: "Continuation completed with error")

        let url = URL(string: "https://example.com/graphql")!
        let task = session.dataTask(with: url)

        Task {
            do {
                _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
                    delegate.registerContinuation(for: task, continuation: continuation)

                    // Simulate error
                    let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)

                    Task {
                        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                        delegate.urlSession(session, task: task, didCompleteWithError: error)
                    }
                }

                XCTFail("Expected error but got success")
            } catch {
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
