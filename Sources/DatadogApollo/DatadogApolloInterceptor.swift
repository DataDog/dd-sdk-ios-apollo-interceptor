/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import Foundation
import Apollo
import ApolloAPI

/// Apollo interceptor that adds Datadog GraphQL monitoring headers to outgoing requests.
/// 
/// This interceptor extracts GraphQL operation metadata (name, type, variables, payload)
/// and adds them as HTTP headers that can be consumed by Datadog RUM monitoring.
public class DatadogApolloInterceptor: ApolloInterceptor, Identifiable {
    /// Unique identifier for this interceptor
    public let id: String = UUID().uuidString

    /// Whether to include the full GraphQL payload in headers
    private let sendGraphQLPayloads: Bool

    /// Utility for extracting operation metadata
    private let metadataExtractor = GraphQLMetadataExtractor()

    /// Initializes the interceptor.
    /// - Parameters:
    ///   - sendGraphQLPayloads: Whether to include the full GraphQL operation payload in headers. Defaults to false.
    public init(sendGraphQLPayloads: Bool = false) {
        self.sendGraphQLPayloads = sendGraphQLPayloads
    }

    /// Intercepts the Apollo request and adds Datadog GraphQL monitoring headers.
    /// - Parameters:
    ///   - chain: The interceptor chain to continue processing
    ///   - request: The Apollo request to process
    ///   - response: The response from previous interceptors
    ///   - completion: Completion handler to call when processing is done
    public func interceptAsync<Operation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) where Operation: GraphQLOperation {
        // Extract operation metadata
        let operation = request.operation
        let operationName = type(of: operation).operationName
        let operationType = metadataExtractor.extractOperationType(from: operation)
        let operationVariables = metadataExtractor.extractVariables(from: operation)

        // Add GraphQL operation name header
        request.addHeader(name: GraphQLHeaders.operationNameHeader, value: operationName)

        // Add GraphQL operation type header if available
        if let operationType = operationType {
            request.addHeader(name: GraphQLHeaders.operationTypeHeader, value: operationType)
        }

        // Add GraphQL variables header if available
        if let operationVariables = operationVariables {
            request.addHeader(name: GraphQLHeaders.variablesHeader, value: operationVariables)
        }

        // Add GraphQL payload header if enabled and available
        if sendGraphQLPayloads {
            if let operationPayload = metadataExtractor.extractPayload(from: operation) {
                request.addHeader(name: GraphQLHeaders.payloadHeader, value: operationPayload)
            }
        }

        // Continue with the modified request
        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
}
