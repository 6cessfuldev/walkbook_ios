import Foundation

protocol StepUseCaseProtocol {
    func createStep(_ step: Step, chapterId: String, storyId: String, completion: @escaping (Result<Step, Error>) -> Void)
    func fetchSteps(by chapterId: String, completion: @escaping (Result<[Step], Error>) -> Void)
    func updateStep(_ step: Step, chapterId: String, storyId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class DefaultStepUseCase: StepUseCaseProtocol {
    private let stepRepository: StepRepository
    
    init(stepRepository: StepRepository) {
        self.stepRepository = stepRepository
    }
    
    func createStep(_ step: Step, chapterId: String, storyId: String, completion: @escaping (Result<Step, Error>) -> Void) {
        stepRepository.createStep(step, to: chapterId, storyId: storyId, completion: completion)
    }
    
    func fetchSteps(by chapterId: String, completion: @escaping (Result<[Step], Error>) -> Void) {
        stepRepository.fetchSteps(by: chapterId, completion: completion)
    }
    
    func updateStep(_ step: Step, chapterId: String, storyId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        stepRepository.updateStep(step, to: chapterId, storyId: storyId, completion: completion)
    }
}
