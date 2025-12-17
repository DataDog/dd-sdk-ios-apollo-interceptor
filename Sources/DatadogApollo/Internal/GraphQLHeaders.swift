/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2025-Present Datadog, Inc.
 */

import Foundation

/// Headers used internally for intercepting GraphQL requests.
internal struct GraphQLHeaders {
    static let operationNameHeader = "_dd-custom-header-graph-ql-operation-name"
    static let operationTypeHeader = "_dd-custom-header-graph-ql-operation-type"
    static let variablesHeader = "_dd-custom-header-graph-ql-variables"
    static let payloadHeader = "_dd-custom-header-graph-ql-payload"
}
