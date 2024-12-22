import RxSwift
import RxCocoa

class EditStepListViewModel {
    private let disposeBag = DisposeBag()
    
    let stepsRelay = BehaviorRelay<[Step]>(value: [])
    
    private let chapterId: String
    private let chapterUseCase: ChapterUseCaseProtocol
    private let stepUseCase: StepUseCaseProtocol
    
    init(chapterId: String, chapterUseCase: ChapterUseCaseProtocol, stepUseCase: StepUseCaseProtocol) {
        self.chapterId = chapterId
        self.chapterUseCase = chapterUseCase
        self.stepUseCase = stepUseCase
        
        fetchInitialSteps()
    }
    
    func addOtherStep(step: Step) {
        stepUseCase.createStep(step, to: chapterId) { r in
            switch r {
            case .success(let step):
                var currentSteps = self.stepsRelay.value
                currentSteps.append(step)
                self.stepsRelay.accept(currentSteps)
            case .failure(let error):
                print("addOtherStep : 스탭 추가 실패, Error : \(error)")
                // Todo: alertController 호출
            }
        }
    }
    
    private func fetchInitialSteps() {
        stepUseCase.fetchSteps(by: chapterId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let steps):
                stepsRelay.accept(steps)
            case .failure(let error):
                print("fetchInitialSteps - Error: \(error)")
            }
        }
    }
}
