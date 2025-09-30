/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation
import Apollo
import ApolloAPI

/// Datadog Apollo GraphQL monitoring integration.
///
/// This package provides Apollo interceptors to automatically add GraphQL operation metadata
/// as HTTP headers for monitoring and debugging purposes with Datadog RUM.
///
/// The interceptor automatically adds the following headers to GraphQL requests:
/// - `x-datadog-graphql-operation-name`: The name of the GraphQL operation
/// - `x-datadog-graphql-operation-type`: The type of operation (query, mutation, subscription)
/// - `x-datadog-graphql-variables`: JSON string of operation variables (if present)
/// - `x-datadog-graphql-payload`: Full operation payload including query and variables (optional)
///
public enum DatadogApollo {
    /// Creates a Datadog GraphQL interceptor for Apollo.
    /// - Parameters:
    ///   - sendGraphQLPayloads: Whether to include the full GraphQL operation payload in headers. Defaults to false.
    public static func createInterceptor(sendGraphQLPayloads: Bool = false) -> DatadogApolloInterceptor {
        return DatadogApolloInterceptor(sendGraphQLPayloads: sendGraphQLPayloads)
    }
}
