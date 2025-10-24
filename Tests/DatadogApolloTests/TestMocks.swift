/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2025-Present Datadog, Inc.
 */

import Foundation
@preconcurrency import ApolloAPI

// MARK: - Mock Data Structures

/// Mock schema for testing
internal enum MockSchema: SchemaMetadata {
    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
        return ApolloAPI.Object(typename: typename, implementedInterfaces: [])
    }

    static var configuration: any ApolloAPI.SchemaConfiguration.Type { MockSchemaConfiguration.self }
}

/// Mock schema configuration  
internal enum MockSchemaConfiguration: ApolloAPI.SchemaConfiguration {
    static func cacheKeyInfo(for type: Object, object: ObjectData) -> CacheKeyInfo? {
        return nil
    }
}

/// Mock root selection set for GraphQL operations  
internal final class MockData: RootSelectionSet {
    typealias Schema = MockSchema

    let __data: DataDict

    required init(_dataDict: DataDict) {
        self.__data = _dataDict
    }

    convenience init() {
        self.init(_dataDict: DataDict(data: [:], fulfilledFragments: Set()))
    }

    static var __parentType: any ApolloAPI.ParentType {
        ApolloAPI.Object(typename: "Query", implementedInterfaces: [])
    }

    static var __selections: [ApolloAPI.Selection] { [] }
}

// MARK: - Mock GraphQL Operations for Testing

/// Mock query operation for testing GraphQL metadata extraction
internal class MockQueryOperation: GraphQLOperation {
    typealias Data = MockData

    static let operationName: String = "GetUser"
    static let operationType: GraphQLOperationType = .query
    static let operationDocument: ApolloAPI.OperationDocument = .init(
        definition: .init("query GetUser($userId: ID!) { user(id: $userId) { id name } }")
    )

    var __variables: [String: GraphQLOperationVariableValue]?

    init(variables: [String: GraphQLOperationVariableValue]? = nil) {
        self.__variables = variables
    }
}

/// Mock mutation operation for testing GraphQL metadata extraction
internal class MockMutationOperation: GraphQLOperation {
    typealias Data = MockData

    static let operationName: String = "UpdateUser"
    static let operationType: GraphQLOperationType = .mutation
    static let operationDocument: ApolloAPI.OperationDocument = .init(
        definition: .init("mutation UpdateUser($userId: ID!, $name: String!) { updateUser(id: $userId, name: $name) { id name } }")
    )

    var __variables: [String: GraphQLOperationVariableValue]?

    init(variables: [String: GraphQLOperationVariableValue]? = nil) {
        self.__variables = variables
    }
}

/// Mock subscription operation for testing GraphQL metadata extraction
internal class MockSubscriptionOperation: GraphQLOperation {
    typealias Data = MockData

    static let operationName: String = "UserUpdated"
    static let operationType: GraphQLOperationType = .subscription
    static let operationDocument: ApolloAPI.OperationDocument = .init(
        definition: .init("subscription UserUpdated { userUpdated { id name } }")
    )

    var __variables: [String: GraphQLOperationVariableValue]?

    init(variables: [String: GraphQLOperationVariableValue]? = nil) {
        self.__variables = variables
    }
}

/// Mock operation with empty operation name for testing edge cases
internal class MockEmptyOperation: GraphQLOperation {
    typealias Data = MockData

    static let operationName: String = ""
    static let operationType: GraphQLOperationType = .query
    static let operationDocument: ApolloAPI.OperationDocument = .init(
        definition: .init("{ viewer { id } }")
    )

    var __variables: [String: GraphQLOperationVariableValue]?

    init(variables: [String: GraphQLOperationVariableValue]? = nil) {
        self.__variables = variables
    }
}

/// Mock operation with no variables for testing
internal class MockNoVariablesOperation: GraphQLOperation {
    typealias Data = MockData

    static let operationName: String = "GetAllUsers"
    static let operationType: GraphQLOperationType = .query
    static let operationDocument: ApolloAPI.OperationDocument = .init(
        definition: .init("query GetAllUsers { users { id name } }")
    )

    var __variables: [String: GraphQLOperationVariableValue]? = nil
}
