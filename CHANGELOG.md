# Unreleased

- [FIX] Use string representation for `GraphQLNullable.none` to distinguish from `.null`

# 2.0.0 / 17-12-2025

Initial release of Datadog Integration for Apollo iOS supporting Apollo 2.0+.

Provides an Apollo interceptor that enriches Datadog RUM Resource events with GraphQL-specific information by extracting operation metadata and injecting it as custom headers.

