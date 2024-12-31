import Foundation

class DefaultStepRepositoryImpl: StepRepository {
    private let stepRemoteDataSource: StepRemoteDataSource
    
    init(stepRemoteDataSource: StepRemoteDataSource) {
        self.stepRemoteDataSource = stepRemoteDataSource
    }
    
    func createStep(_ step: Step, to chapterId: String, storyId: String, completion: @escaping (Result<Step, Error>) -> Void) {
        stepRemoteDataSource.add(step: StepMapper.toDataModel(step), chapterId: chapterId, storyId: storyId) { r in
            switch r {
            case .success(let model):
                completion(.success(StepMapper.toEntity(model)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchSteps(by chapterId: String, completion: @escaping (Result<[Step], Error>) -> Void) {
        stepRemoteDataSource.fetchByChapterId(by: chapterId) { r in
            switch r {
            case .success(let models):
                let entities = models.map { StepMapper.toEntity($0) }
                completion(.success(entities))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateStep(_ step: Step, to chapterId: String, storyId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        stepRemoteDataSource.update(step:StepMapper.toDataModel(step), chapterId: chapterId, storyId: storyId, completion: completion)
    }
    
    
}
