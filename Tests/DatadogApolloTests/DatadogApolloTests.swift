/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import XCTest
@preconcurrency import ApolloAPI
import Apollo
@testable import DatadogApollo

public final class DatadogApolloInterceptorTests: XCTestCase {
    // MARK: - Factory Tests

    func testCreateInterceptor() throws {
        // Test creating interceptor with default settings
        let interceptor1 = DatadogApollo.createInterceptor()
        XCTAssertNotNil(interceptor1)
        XCTAssertNotNil(interceptor1.id)

        // Test creating interceptor with payload enabled
        let interceptor2 = DatadogApollo.createInterceptor(sendGraphQLPayloads: true)
        XCTAssertNotNil(interceptor2)
        XCTAssertNotNil(interceptor2.id)

        // Interceptors should have different IDs
        XCTAssertNotEqual(interceptor1.id, interceptor2.id)
    }

    // MARK: - Header Constants Tests

    func testGraphQLHeadersConstants() throws {
        // Verify header constants match Android implementation
        XCTAssertEqual(GraphQLHeaders.operationNameHeader, "_dd-custom-header-graph-ql-operation-name")
        XCTAssertEqual(GraphQLHeaders.operationTypeHeader, "_dd-custom-header-graph-ql-operation_type")
        XCTAssertEqual(GraphQLHeaders.variablesHeader, "_dd-custom-header-graph-ql-variables")
        XCTAssertEqual(GraphQLHeaders.payloadHeader, "_dd-custom-header-graph-ql-payload")
    }

    func testApolloGraphQLOperationTypeExtension() throws {
        // Test our extension on Apollo's built-in GraphQLOperationType
        XCTAssertEqual(ApolloAPI.GraphQLOperationType.query.stringValue, "query")
        XCTAssertEqual(ApolloAPI.GraphQLOperationType.mutation.stringValue, "mutation")
        XCTAssertEqual(ApolloAPI.GraphQLOperationType.subscription.stringValue, "subscription")
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

    func testExtractPayloadFromQueryOperationWithVariables() throws {
        let extractor = GraphQLMetadataExtractor()
        let variables: [String: GraphQLOperationVariableValue] = ["userId": "123", "active": true]
        let operation = MockQueryOperation(variables: variables)

        let result = extractor.extractPayload(from: operation)
        XCTAssertNotNil(result)

        guard let payload = result else {
            XCTFail("Expected non-nil payload")
            return
        }

        // Should contain operation name
        XCTAssertTrue(payload.contains("GetUser"))
        XCTAssertTrue(payload.contains("operationName"))

        // Should contain variables
        XCTAssertTrue(payload.contains("variables"))
        XCTAssertTrue(payload.contains("userId"))
        XCTAssertTrue(payload.contains("123"))
        XCTAssertTrue(payload.contains("active"))
    }

    func testExtractPayloadFromMutationOperation() throws {
        let extractor = GraphQLMetadataExtractor()
        let variables: [String: GraphQLOperationVariableValue] = ["userId": "456", "name": "John Doe"]
        let operation = MockMutationOperation(variables: variables)

        let result = extractor.extractPayload(from: operation)
        XCTAssertNotNil(result)

        guard let payload = result else {
            XCTFail("Expected non-nil payload")
            return
        }

        // Should contain operation name
        XCTAssertTrue(payload.contains("UpdateUser"))
        XCTAssertTrue(payload.contains("operationName"))

        // Should contain variables
        XCTAssertTrue(payload.contains("variables"))
        XCTAssertTrue(payload.contains("userId"))
        XCTAssertTrue(payload.contains("456"))
        XCTAssertTrue(payload.contains("name"))
        XCTAssertTrue(payload.contains("John Doe"))
    }

    func testExtractPayloadFromOperationWithNoVariables() throws {
        let extractor = GraphQLMetadataExtractor()
        let operation = MockNoVariablesOperation()

        let result = extractor.extractPayload(from: operation)
        XCTAssertNotNil(result)

        guard let payload = result else {
            XCTFail("Expected non-nil payload")
            return
        }

        // Should contain operation name
        XCTAssertTrue(payload.contains("GetAllUsers"))
        XCTAssertTrue(payload.contains("operationName"))

        // Should not contain variables section
        XCTAssertFalse(payload.contains("variables"))
    }
}
