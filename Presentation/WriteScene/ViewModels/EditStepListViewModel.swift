import RxSwift
import RxCocoa
import CoreLocation

class EditStepListViewModel {
    private let disposeBag = DisposeBag()
    
    let stepsRelay = BehaviorRelay<[Step]>(value: [])
    
    private let chapterId: String
    private let chapterUseCase: ChapterUseCaseProtocol
    private let stepUseCase: StepUseCaseProtocol
    private let imageUseCase: ImageUseCaseProtocol
    
    init(chapterId: String, chapterUseCase: ChapterUseCaseProtocol, stepUseCase: StepUseCaseProtocol, imageUseCase: ImageUseCaseProtocol) {
        self.chapterId = chapterId
        self.chapterUseCase = chapterUseCase
        self.stepUseCase = stepUseCase
        self.imageUseCase = imageUseCase
        
        fetchInitialSteps()
    }
    
    func addOtherStep(step: Step, completion: @escaping (Result<Void, Error>) -> Void) {
        stepUseCase.createStep(step, to: chapterId) { r in
            switch r {
            case .success(let step):
                var currentSteps = self.stepsRelay.value
                currentSteps.append(step)
                self.stepsRelay.accept(currentSteps)
                completion(.success(()))
            case .failure(let error):
                print("addOtherStep : 스탭 추가 실패, Error : \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func addImageTypeStep(image: UIImage, location: CLLocationCoordinate2D?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let imgData = image.toData() else {
            print("변환된 데이터 없음 ")
            return
        }
        imageUseCase.uploadImage(imgData) { r in
            switch r {
            case .success(let url):
                let step = Step(type: .image(url), location: location)
                self.stepUseCase.createStep(step, to: self.chapterId) { r in
                    switch r {
                    case .success(let step):
                        var currentSteps = self.stepsRelay.value
                        currentSteps.append(step)
                        self.stepsRelay.accept(currentSteps)
                        completion(.success(()))
                    case .failure(let error):
                        print("addOtherStep : 스탭 추가 실패, Error : \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("이미지 업로드 실패 \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func addAudioTypeStep(audioURL: URL, location: CLLocationCoordinate2D?, completion: @escaping (Result<Void, Error>) -> Void) {
        
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
