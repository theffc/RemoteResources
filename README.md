# RemoteResources
Simple HTTP Networking abstraction in Swift that emphasizes typing of resources

This work was strongly inspired by [Moya](https://github.com/Moya/Moya) and by [Networking](https://github.com/bocato/Networking).

The major objectives of this Http layer is to:

- Be simple enough to facilitate understanding
- Let the endpoint/resource defines which type of response it accepts
- Only focus on Http requests
- Use protocols extensively to allow testing and extension
