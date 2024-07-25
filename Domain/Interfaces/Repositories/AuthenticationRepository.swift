protocol AuthenticationRepository {
    func signInWithApple(nonce: String, completion: @escaping (Result<String, Error>) -> Void)
}
