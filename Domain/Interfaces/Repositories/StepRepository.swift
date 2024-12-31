protocol StepRepository {
    func createStep(_ step: Step, to chapterId: String, storyId: String, completion: @escaping (Result<Step, Error>) -> Void)
    func fetchSteps(by chapterId: String, completion: @escaping (Result<[Step], Error>) -> Void)
    func updateStep(_ step: Step, to chapterId: String, storyId: String, completion: @escaping (Result<Void, Error>) -> Void)
}
