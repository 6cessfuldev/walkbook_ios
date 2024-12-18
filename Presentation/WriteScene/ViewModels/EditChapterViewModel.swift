import RxSwift
import RxCocoa

class EditChapterViewModel {
    
    // MARK: - Properties
    let chapter: BehaviorRelay<Chapter>
    let title: BehaviorRelay<String>
    let description: BehaviorRelay<String>
    let selectedImage = BehaviorRelay<UIImage?>(value: nil)
    let imageUrl: BehaviorRelay<String>
    let isSubmitting = BehaviorRelay<Bool>(value: false)
    let isImageLoading = BehaviorRelay<Bool>(value: false)
    let submitTapped = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    private let imageUseCase: ImageUseCaseProtocol
    
    // MARK: - Initializer
    
    init(chapter: Chapter?, imageUseCase: ImageUseCaseProtocol) {
        
        let initialChapter = chapter ?? Chapter(
            title: "챕터 제목",
            steps: [
                "1","2","3","4"
            ]
        )
        
        self.chapter = BehaviorRelay(value: initialChapter)
        self.title = BehaviorRelay(value: initialChapter.title)
        self.description = BehaviorRelay(value: initialChapter.description ?? "")
        self.imageUrl = BehaviorRelay(value: initialChapter.imageUrl ?? "")
        
        self.imageUseCase = imageUseCase
    }
    
    // MARK: - Input Handlers
    
    func tapBinding() {
        
        submitTapped
            .withLatestFrom(isSubmitting)
            .filter { !$0 }
            .withLatestFrom(Observable.combineLatest(title, description, imageUrl))
            .filter { (title, description, imageUrl) in
                !title.isEmpty && !description.isEmpty
            }
            .subscribe(onNext: { [weak self] title, description, imageUrl in
                self?.submitChapter(title: title, description: description, imageUrl: imageUrl)
            })
            .disposed(by: disposeBag)
        
        selectedImage
            .compactMap { $0 }
            .distinctUntilChanged()
            .do(onNext: { _ in
                self.isSubmitting.accept(true)
            })
            .flatMapLatest { [weak self] image -> Observable<String?> in
                guard let self = self, let data = image.toData() else { return Observable.just(nil) }
                return Observable.create { observer in
                    self.imageUseCase.uploadImage(data) { result in
                        switch result {
                        case .success(let url):
                            observer.onNext(url)
                            observer.onCompleted()
                        case .failure(let error):
                            print("Image upload failed: \(error)")
                            observer.onNext(nil)
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
                .do(onDispose: {
                    self.isSubmitting.accept(false)
                })
            }
            
            .subscribe(onNext: { [weak self] url in
                if let url = url {
                    self?.imageUrl.accept(url)
                }
            })
            .disposed(by: disposeBag)
        
        isSubmitting
            .subscribe(onNext: { isSubmitting in
                print("isSubmitting: \(isSubmitting)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Helpers
    
    private func submitChapter(title: String, description: String, imageUrl: String) {
        let currentChapter = chapter.value

        currentChapter.title = title
        currentChapter.description = description
        currentChapter.imageUrl = imageUrl

        chapter.accept(currentChapter)

        print("Updated chapter: \(currentChapter)")
    }
    
    func addOtherStep(step: Step) {
        let currentChapter = chapter.value
        let stepId = createStep(step: step)
        currentChapter.steps.append(stepId)
    }
    
    // TODO: Step 데이터 생성 API 호출 후 생성된 step Id 반환
    func createStep(step: Step) -> String {
        print("create Step")
        return "1"
    }
}
