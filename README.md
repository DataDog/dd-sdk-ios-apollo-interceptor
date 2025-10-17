# Datadog Integration for Apollo iOS

## Getting started

**Note:** The integration supports Apollo iOS version 1.0+.

To include the integration for [Apollo iOS](https://github.com/apollographql/apollo-ios) in your project, add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/DataDog/dd-sdk-ios-apollo-interceptor", .upToNextMajor(from: "1.0.0"))
]
```

Alternatively, you can add it using Xcode:
1. Go to File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/DataDog/dd-sdk-ios-apollo-interceptor`
3. Select the latest version

## Initial setup

1. Set up RUM monitoring with [Datadog iOS RUM SDK](https://docs.datadoghq.com/real_user_monitoring/ios/)
2. Set up network instrumentation with the Datadog RUM SDK for iOS
3. Add the Datadog interceptor to your Apollo Client setup:

```swift
import Apollo
import DatadogApollo

class CustomInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(DatadogApolloInterceptor(), at: 0)
        return interceptors
    }
}
```

This automatically adds Datadog headers to your GraphQL requests, enabling them to be tracked by Datadog. Note that while `query` and `mutation` operations are tracked, `subscription` operations are not.

## Sending GraphQL payloads

Sending GraphQL payloads is disabled by default. To enable it, set the `sendGraphQLPayloads` flag in the DatadogApollo interceptor constructor as shown below:

```swift
let datadogInterceptor = DatadogApolloInterceptor(sendGraphQLPayloads: true)
```

## Contributing

Contributions are welcome! For details, see the [Contributing Guide](CONTRIBUTING.md).

## License

Apache License, v2.0
