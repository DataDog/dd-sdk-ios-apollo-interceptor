# Unreleased

# 2.0.1 / 08-01-2026

- [IMPROVEMENT] Add `DatadogApolloDelegate` and `DatadogApolloURLSession` for Apollo iOS v2 network instrumentation support. See [#41][]
- [FIX] Use string representation for `GraphQLNullable.none` to distinguish from `.null`. See [#39][]

# 2.0.0 / 17-12-2025

Initial release of Datadog Integration for Apollo iOS supporting Apollo 2.0+.

Provides an Apollo interceptor that enriches Datadog RUM Resource events with GraphQL-specific information by extracting operation metadata and injecting it as custom headers.

[#39]: https://github.com/DataDog/dd-sdk-ios-apollo-interceptor/pull/39
[#41]: https://github.com/DataDog/dd-sdk-ios-apollo-interceptor/pull/41