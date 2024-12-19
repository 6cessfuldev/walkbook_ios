import RxSwift
import RxCocoa

class WriteNewStoryViewModel {
    
    // Inputs
    let title = BehaviorRelay<String>(value: "")
    let imageUrl = BehaviorRelay<String>(value: "")
    let description = BehaviorRelay<String>(value: "")
    let submitTapped = PublishRelay<Void>()
    
    let selectedImage = BehaviorRelay<UIImage?>(value: nil)
    
    // Outputs
    let isSubmitting: Driver<Bool>
    let submissionResult: Driver<Result<Void, Error>>
    
    private let _isSubmitting = BehaviorRelay<Bool>(value: false)
    private let _submissionResult = PublishRelay<Result<Void, Error>>()

    
    private let storyUseCase: StoryUseCaseProtocol
    private let imageUseCase: ImageUseCaseProtocol
    private let userProfileUseCase: UserProfileUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    init(storyUseCase: StoryUseCaseProtocol, imageUseCase: ImageUseCaseProtocol, userProfileUseCase: UserProfileUseCaseProtocol) {
        self.storyUseCase = storyUseCase
        self.imageUseCase = imageUseCase
        self.userProfileUseCase = userProfileUseCase
        
        self.isSubmitting = _isSubmitting.asDriver()
        self.submissionResult = _submissionResult.asDriver(onErrorJustReturn: .failure(NSError(domain: "UnknownError", code: -1, userInfo: nil)))

        setupBindings()
    }
    
    private func setupBindings() {
        bindSubmission()
        bindImageSelection()
    }
    
    private func bindSubmission() {
        submitTapped
            .filter {
                !self._isSubmitting.value
            }
            .withLatestFrom(Observable.combineLatest(title, imageUrl, description))
            .filter { !$0.0.isEmpty && !$0.2.isEmpty }
            .do(onNext: { _ in
                self._isSubmitting.accept(true)
            })
            .flatMapLatest { [weak self] title, imageUrl, description -> Observable<Result<Void, Error>> in
                guard let self = self else {
                    return Observable.just(.failure(NSError(domain: "ViewModelError", code: -1, userInfo: nil)))
                }
                let story = Story(id: nil, title: title, author: "", imageUrl: imageUrl, description: description, rootChapterId: nil)
                print("submitting story \(story)")
                return self.createStoryObservable(story)
                    .catch { error in
                        self._isSubmitting.accept(false)
                        return Observable.just(.failure(error))
                    }
            }
            .do(onNext: { _ in
                self._isSubmitting.accept(false)
            })
            .bind(to: _submissionResult)
            .disposed(by: disposeBag)
    }
    
    private func bindImageSelection() {
        selectedImage
            .compactMap { $0 }
            .distinctUntilChanged()
            .do(onNext: { _ in
                self._isSubmitting.accept(true)
            })
            .flatMapLatest { [weak self] image -> Observable<String?> in
                guard let self = self, let data = image.toData() else {
                    return Observable.just(nil)
                }
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
                    self._isSubmitting.accept(false)
                })
            }
            .subscribe(onNext: { [weak self] url in
                if let url = url {
                    self?.imageUrl.accept(url) // Update imageUrl
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func createStoryObservable(_ story: Story) -> Observable<Result<Void, Error>> {
        return Observable.create { [weak self] observer in
            self?.storyUseCase.createStory(story) { result in
                observer.onNext(result)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
