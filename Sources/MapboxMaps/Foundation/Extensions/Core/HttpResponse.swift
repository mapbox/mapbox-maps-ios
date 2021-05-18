@_exported import MapboxCommon
@_implementationOnly import MapboxCommon_Private

extension HttpRequestError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
}

extension HttpResponse {
    public convenience init(request: HttpRequest, result: Result<HttpResponseData, HttpRequestError>) {
        let expected: MBXExpected<AnyObject, AnyObject>
        switch result {
        case let .success(response):
            expected = MBXExpected(value: response)
        case let .failure(error):
            expected = MBXExpected(error: error)
        }

        self.init(request: request, result: expected)
    }

    public var result: Result<HttpResponseData, HttpRequestError> {

        guard let expected = __result as? MBXExpected<HttpResponseData, HttpRequestError>  else {
            fatalError("Invalid MBXExpected types or none.")
        }

        if expected.isValue() {
            return .success(expected.value!)
        } else {
            return .failure(expected.error!)
        }
    }
}
