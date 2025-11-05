/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2025-Present Datadog, Inc.
 */

import Foundation
import Apollo
import ApolloAPI

/// Utility for extracting GraphQL operation metadata for monitoring purposes.
internal struct GraphQLMetadataExtractor {
    /// Extracts variables from a GraphQL operation using Apollo's built-in JSON encoding.
    /// - Parameter operation: The GraphQL operation to extract variables from
    /// - Returns: JSON string representation of the variables, or nil if extraction fails
    internal func extractVariables<T: GraphQLOperation>(from operation: T) -> String? {
        let variables = operation.__variables ?? [:]

        guard !variables.isEmpty else {
            return nil
        }

        // Use Apollo's built-in JSONEncodable conversion to handle proper serialization
        let jsonEncodableDict = variables._jsonEncodableObject
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonEncodableDict, options: [])
            return String(data: jsonData, encoding: .utf8)
        } catch {
            // If serialization fails, return nil to avoid breaking the request
            return nil
        }
    }

    /// Extracts the operation type from a GraphQL operation.
    /// - Parameter operation: The GraphQL operation to analyze
    /// - Returns: The operation type string (query, mutation, subscription), or nil if unknown
    internal func extractOperationType<T: GraphQLOperation>(from operation: T) -> String? {
        let operationType = T.operationType
        switch operationType {
        case .query:
            return ApolloAPI.GraphQLOperationType.query.description
        case .mutation:
            return ApolloAPI.GraphQLOperationType.mutation.description
        case .subscription:
            return ApolloAPI.GraphQLOperationType.subscription.description
        @unknown default:
            return nil
        }
    }

    /// Extracts the full GraphQL operation query as a payload.
    /// - Parameter operation: The GraphQL operation to extract payload from
    /// - Returns: JSON string representation of the operation payload, or nil if extraction fails
    internal func extractPayload<T: GraphQLOperation>(from operation: T) -> String? {
        let operationDocument = T.operationDocument

        if let queryDocument = operationDocument.definition?.queryDocument, !queryDocument.isEmpty {
           return queryDocument
        }

        return nil
    }
}
