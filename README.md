# Datadog Integration for Apollo iOS

## Getting started

**Note:** The integration supports Apollo iOS version 1.0+.

To include the integration for [Apollo iOS](https://github.com/apollographql/apollo-ios) in your project, add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/DataDog/dd-sdk-ios-apollo", .upToNextMajor(from: "1.0.0"))
]
```

Or add it through Xcode:
1. Go to File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/DataDog/dd-sdk-ios-apollo`
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
        interceptors.insert(DatadogApollo.createInterceptor(), at: 0)
        return interceptors
    }
}
```

This automatically adds Datadog headers to your GraphQL requests, allowing them to be tracked by Datadog. Note that while `query` and `mutation` type operations are tracked, `subscription` operations are not.

## Sending GraphQL payloads

GraphQL payload sending is disabled by default. To enable it, set the `sendGraphQLPayloads` flag in the DatadogApollo interceptor constructor as follows:

```swift
let datadogInterceptor = DatadogApollo.createInterceptor(sendGraphQLPayloads: true)
```

## Contributing

For details on contributing, read the [Contributing Guide](CONTRIBUTING.md).

## License

Apache License, v2.0
