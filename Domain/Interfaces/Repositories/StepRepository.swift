protocol StepRepository {
    func createStep(_ step: Step, to chapterId: String, completion: @escaping (Result<Step, Error>) -> Void)
    func fetchSteps(by chapterId: String, completion: @escaping (Result<[Step], Error>) -> Void)
    func updateStep(_ step: Step, completion: @escaping (Result<Void, Error>) -> Void)
}
