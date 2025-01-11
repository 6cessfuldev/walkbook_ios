import RxSwift
import RxCocoa
import CoreLocation

class EditStepListViewModel {
    private let disposeBag = DisposeBag()
    
    let stepsRelay = BehaviorRelay<[Step]>(value: [])
    
    private let chapterId: String
    private let rootChapter: NestedChapter
    private let storyUseCase: StoryUseCaseProtocol
    private let chapterUseCase: ChapterUseCaseProtocol
    private let stepUseCase: StepUseCaseProtocol
    private let mediaUseCase: MediaUseCaseProtocol
    
    init(chapterId: String, rootChapter: NestedChapter, storyUseCase: StoryUseCaseProtocol, chapterUseCase: ChapterUseCaseProtocol, stepUseCase: StepUseCaseProtocol, mediaUseCase: MediaUseCaseProtocol) {
        self.chapterId = chapterId
        self.rootChapter = rootChapter
        
        self.storyUseCase = storyUseCase
        self.chapterUseCase = chapterUseCase
        self.stepUseCase = stepUseCase
        self.mediaUseCase = mediaUseCase
        
        fetchInitialSteps()
    }
    
    func addOtherStep(step: Step, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let storyId = rootChapter.storyId else {
            completion(.failure(NSError(domain: "Not Found story ID", code: -1, userInfo: nil)))
            return
        }
        
        stepUseCase.createStep(step, chapterId: chapterId, storyId: storyId) { r in
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
            print("이미지 데이터 변환 실패")
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "이미지 데이터 변환 실패"])))
            return
        }
        
        mediaUseCase.uploadImage(imgData) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let url):
                let step = Step(type: .image(url), location: location)
                self.saveStep(step: step, completion: completion)
                
            case .failure(let error):
                print("이미지 업로드 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func addAudioTypeStep(audioURL: URL, location: CLLocationCoordinate2D?, completion: @escaping (Result<Void, Error>) -> Void) {
        mediaUseCase.uploadAudio(audioURL) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let url):
                let step = Step(type: .audio(url), location: location)
                self.saveStep(step: step, completion: completion)
                
            case .failure(let error):
                print("오디오 업로드 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func updateStep(stepId: String, step: Step, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let storyId = rootChapter.storyId else {
            completion(.failure(NSError(domain: "Not Found story ID", code: -1, userInfo: nil)))
            return
        }
        self.stepUseCase.updateStep(step, chapterId: self.chapterId, storyId: storyId, completion: completion)
    }
    
    
    private func saveStep(
        step: Step,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let storyId = rootChapter.storyId else {
            completion(.failure(NSError(domain: "Not Found story ID", code: -1, userInfo: nil)))
            return
        }
        
        self.stepUseCase.createStep(step, chapterId: chapterId, storyId: storyId) { [weak self] stepResult in
            guard let self = self else { return }
            
            switch stepResult {
            case .success(let step):
                var currentSteps = self.stepsRelay.value
                currentSteps.append(step)
                self.stepsRelay.accept(currentSteps)
                completion(.success(()))
            case .failure(let error):
                print("saveStep : 스탭 추가 실패, Error : \(error)")
                completion(.failure(error))
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
