/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at Datadog (https://www.datadoghq.com/).
* Copyright 2019-Present Datadog, Inc.
*/

import UIKit
import DatadogApollo

internal class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Test that DatadogApollo APIs are visible and can be instantiated:
        let interceptor = DatadogApolloInterceptor()
        let interceptorWithPayloads = DatadogApolloInterceptor(sendGraphQLPayloads: true)
        
        // Verify the interceptors are not nil
        if interceptor as Any? != nil && interceptorWithPayloads as Any? != nil {
            print("✓ DatadogApolloInterceptor successfully created")
            print("✓ DatadogApolloInterceptor with payloads successfully created")
        }

        addLabel()
    }

    private func addLabel() {
        let label = UILabel()
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(label)

        label.text = "Testing DatadogApollo..."
        label.textColor = .white
        label.sizeToFit()
        label.center = view.center
    }
}

