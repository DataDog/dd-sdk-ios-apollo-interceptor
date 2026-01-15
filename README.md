# Datadog Integration for Apollo iOS

## Getting started

> [!NOTE]
> This integration supports both Apollo iOS 1.0+ and Apollo iOS 2.0+. The setup differs between versions, so please follow the instructions for your Apollo iOS version below.

To include the integration for [Apollo iOS](https://github.com/apollographql/apollo-ios) in your project, add the following to your `Package.swift` file:

```swift
dependencies: [
    // For Apollo iOS 1.0+
    .package(url: "https://github.com/DataDog/dd-sdk-ios-apollo-interceptor", .upToNextMajor(from: "1.0.0"))
    
    // For Apollo iOS 2.0+
    .package(url: "https://github.com/DataDog/dd-sdk-ios-apollo-interceptor", .upToNextMajor(from: "2.0.0"))
]
```

Alternatively, you can add it using Xcode:
1. Go to File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/DataDog/dd-sdk-ios-apollo-interceptor`
3. Select the package version that matches your Apollo major version (choose 1.x.x for Apollo iOS 1.0+ or 2.x.x for Apollo iOS 2.0+).

## Initial setup

### For Apollo iOS 1.0+

1. Set up RUM monitoring with the [Datadog iOS SDK](https://docs.datadoghq.com/real_user_monitoring/ios/):
2. Set up network instrumentation for Apollo's built-in URLSessionClient:

```swift
import Apollo

URLSessionInstrumentation.enable(with: .init(delegateClass: URLSessionClient.self))
```

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

### For Apollo iOS 2.0+

1. Set up RUM monitoring with the [Datadog iOS SDK](https://docs.datadoghq.com/real_user_monitoring/ios/):
2. Set up network instrumentation.

Apollo 2.0 requires creating a custom URLSession delegate (unlike Apollo 1.0 which uses the built-in `URLSessionClient`):

First, create a custom URLSession delegate class:

```swift
class ApolloURLSessionDelegate: NSObject, URLSessionDataDelegate {
    // Datadog will automatically instrument this delegate
}
```

Then, enable instrumentation for your custom delegate:

```swift
URLSessionInstrumentation.enable(with: .init(delegateClass: ApolloURLSessionDelegate.self))
```

Configure your Apollo Client to use the custom URLSession with this delegate:

```swift
// Create custom URLSession with the delegate for Datadog tracking
let configuration = URLSessionConfiguration.default
let sessionDelegate = ApolloURLSessionDelegate()
let customSession = URLSession(
    configuration: configuration,
    delegate: sessionDelegate,
    delegateQueue: nil
)

// Pass the custom session to your RequestChainNetworkTransport
let networkTransport = RequestChainNetworkTransport(
    urlSession: customSession,
    interceptorProvider: NetworkInterceptorProvider(),
    store: store,
    endpointURL: url
)
```

3. Create an interceptor provider with the Datadog interceptor:

```swift
import Apollo
import DatadogApollo

struct NetworkInterceptorProvider: InterceptorProvider {
    func graphQLInterceptors<Operation>(for operation: Operation) -> [any GraphQLInterceptor] where Operation : GraphQLOperation {
        return [DatadogApolloInterceptor()] + DefaultInterceptorProvider.shared.graphQLInterceptors(for: operation)
    }
}
```
> [!NOTE]
> This lets Datadog RUM extract Operation type, name, variables and Payloads (optional) automatically from the requests to enrich GraphQL Requests RUM Resources. Note that while `query` and `mutation` operations are tracked, `subscription` operations are not.

## Sending GraphQL payloads

Sending GraphQL payloads is disabled by default. To enable it, set the `sendGraphQLPayloads` flag in the DatadogApollo interceptor constructor as shown below:

```swift
let datadogInterceptor = DatadogApolloInterceptor(sendGraphQLPayloads: true)
```

## Contributing

Contributions are welcome! For details, see the [Contributing Guide](CONTRIBUTING.md).

## License

Apache License, v2.0
