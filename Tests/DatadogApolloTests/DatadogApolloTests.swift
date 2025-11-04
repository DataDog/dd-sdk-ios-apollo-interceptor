/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2025-Present Datadog, Inc.
 */

import XCTest
@preconcurrency import ApolloAPI
import Apollo
@testable import DatadogApollo

public final class DatadogApolloInterceptorTests: XCTestCase {
    // MARK: - Factory Tests

    func testCreateInterceptor() throws {
        // Test creating interceptor with default settings
        let interceptor1 = DatadogApolloInterceptor()
        XCTAssertNotNil(interceptor1)

        // Test creating interceptor with payload enabled
        let interceptor2 = DatadogApolloInterceptor(sendGraphQLPayloads: true)
        XCTAssertNotNil(interceptor2)
    }

    // MARK: - Header Constants Tests

    func testGraphQLHeadersConstants() throws {
        // Verify header constants match Android implementation
        XCTAssertEqual(GraphQLHeaders.operationNameHeader, "_dd-custom-header-graph-ql-operation-name")
        XCTAssertEqual(GraphQLHeaders.operationTypeHeader, "_dd-custom-header-graph-ql-operation-type")
        XCTAssertEqual(GraphQLHeaders.variablesHeader, "_dd-custom-header-graph-ql-variables")
        XCTAssertEqual(GraphQLHeaders.payloadHeader, "_dd-custom-header-graph-ql-payload")
    }

    // MARK: - GraphQL Operation Tests

    func testExtractPayloadWithEmptyOperationName() throws {
        let extractor = GraphQLMetadataExtractor()
        let operation = MockEmptyOperation()
        let result = extractor.extractPayload(from: operation)
        XCTAssertNotNil(result) // Should still create an empty JSON payload

        // Should have empty operationName but still be valid JSON
        guard let payload = result else {
            XCTFail("Expected non-nil payload")
            return
        }
        XCTAssertFalse(payload.contains("operationName"))
        XCTAssertFalse(payload.contains("variables"))
    }

    func testExtractVariablesFromQueryOperation() throws {
        let extractor = GraphQLMetadataExtractor()
        let variables: [String: GraphQLOperationVariableValue] = ["userId": "123", "active": true]
        let operation = MockQueryOperation(variables: variables)

        let result = extractor.extractVariables(from: operation)
        XCTAssertNotNil(result)
        guard let variables = result else {
            XCTFail("Expected non-nil variables")
            return
        }
        XCTAssertTrue(variables.contains("userId"))
        XCTAssertTrue(variables.contains("123"))
        XCTAssertTrue(variables.contains("active"))
    }

    func testExtractVariablesFromOperationWithNoVariables() throws {
        let extractor = GraphQLMetadataExtractor()
        let operation = MockNoVariablesOperation()

        let result = extractor.extractVariables(from: operation)
        XCTAssertNil(result) // Should return nil for empty variables
    }

    func testExtractOperationTypeFromOperations() throws {
        let extractor = GraphQLMetadataExtractor()
        let operation1 = MockQueryOperation()
        let operation2 = MockMutationOperation()
        let operation3 = MockSubscriptionOperation()

        let result1 = extractor.extractOperationType(from: operation1)
        let result2 = extractor.extractOperationType(from: operation2)
        let result3 = extractor.extractOperationType(from: operation3)

        XCTAssertEqual(result1, "query")
        XCTAssertEqual(result2, "mutation")
        XCTAssertEqual(result3, "subscription")
    }

    func testExtractPayloadContainsQueryDocument() throws {
        let extractor = GraphQLMetadataExtractor()
        let operation = MockQueryOperation(variables: ["userId": "123"])

        let result = extractor.extractPayload(from: operation)
        XCTAssertNotNil(result)

        guard let payload = result else {
            XCTFail("Expected non-nil payload")
            return
        }

        // Payload should contain the GraphQL query document
        XCTAssertTrue(payload.contains("query GetUser"))
        XCTAssertTrue(payload.contains("user(id: $userId)"))
    }

    // MARK: - GraphQL Variables Tests

    func testExtractVariablesWithGraphQLEnum() throws {
        // Test that GraphQLEnum types are properly serialized to JSON
        let extractor = GraphQLMetadataExtractor()
        let operation = MockOperationWithGraphQLEnum(id: "test-123", enumValue: .optionB)

        let result = extractor.extractVariables(from: operation)

        XCTAssertNotNil(result)
        guard let variables = result else {
            XCTFail("Expected non-nil variables")
            return
        }

        // Verify the enum is serialized as its string value
        XCTAssertTrue(variables.contains("OPTION_B"))
        XCTAssertTrue(variables.contains("test-123"))
    }

    func testExtractVariablesWithNonASCIICharacters() throws {
        // Test that non-ASCII characters are properly handled in variables
        let extractor = GraphQLMetadataExtractor()
        let variables: [String: GraphQLOperationVariableValue] = [
            "userId": "user-123",
            "name": "José García",
            "city": "São Paulo",
            "description": "Test with émojis 🎉 and spëcial çhars"
        ]
        let operation = MockQueryOperation(variables: variables)

        let result = extractor.extractVariables(from: operation)

        XCTAssertNotNil(result)
        guard let variablesJson = result else {
            XCTFail("Expected non-nil variables")
            return
        }

        // Verify non-ASCII characters are preserved in the JSON output
        XCTAssertTrue(variablesJson.contains("José García"))
        XCTAssertTrue(variablesJson.contains("São Paulo"))
        XCTAssertTrue(variablesJson.contains("🎉"))
        XCTAssertTrue(variablesJson.contains("émojis"))
        XCTAssertTrue(variablesJson.contains("spëcial"))
        XCTAssertTrue(variablesJson.contains("çhars"))
    }
}
