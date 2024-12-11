import RxSwift
import RxCocoa

class WriteNewStoryViewModel {
    
    // Inputs
    let title = BehaviorRelay<String>(value: "")
    let author = BehaviorRelay<String>(value: "")
    let imageUrl = BehaviorRelay<String>(value: "")
    let description = BehaviorRelay<String>(value: "")
    let submitTapped = PublishRelay<Void>()
    
    let selectedImage = BehaviorRelay<UIImage?>(value: nil)
    
    // Outputs
    let isSubmitting: Driver<Bool>
    let submissionResult: Driver<Result<Void, Error>>
    
    private let storyUseCase: StoryUseCaseProtocol
    private let imageUseCase: ImageUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    init(storyUseCase: StoryUseCaseProtocol, imageUseCase: ImageUseCaseProtocol) {
        self.storyUseCase = storyUseCase
        self.imageUseCase = imageUseCase
        
        let _isSubmitting = BehaviorRelay<Bool>(value: false)
        let _submissionResult = PublishRelay<Result<Void, Error>>()
        
        self.isSubmitting = _isSubmitting.asDriver()
        self.submissionResult = _submissionResult.asDriver(onErrorJustReturn: .failure(NSError(domain: "UnknownError", code: -1, userInfo: nil)))
        
        submitTapped
            .filter { 
                !_isSubmitting.value }
            .withLatestFrom(Observable.combineLatest(title, author, imageUrl, description))
            .filter { !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty && !$0.3.isEmpty }
            .do(onNext: { _ in
                _isSubmitting.accept(true)
            })
            .flatMapLatest { [weak self] title, author, imageUrl, description -> Observable<Result<Void, Error>> in
                guard let self = self else {
                    return Observable.just(.failure(NSError(domain: "ViewModelError", code: -1, userInfo: nil)))
                }
                let story = Story(id: nil, title: title, author: author, imageUrl: imageUrl, description: description)
                print("submitting story \(story)")
                return self.createStoryObservable(story)
                    .catch { error in
                        _isSubmitting.accept(false)
                        return Observable.just(.failure(error))
                }
            }
            .do(onNext: { _ in _isSubmitting.accept(false) })
            .bind(to: _submissionResult)
            .disposed(by: disposeBag)
        
        selectedImage
            .compactMap { $0 }
            .distinctUntilChanged()
            .do(onNext: { _ in
                _isSubmitting.accept(true)
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
                    _isSubmitting.accept(false)
                })
            }
            
            .subscribe(onNext: { [weak self] url in
                if let url = url {
                    self?.imageUrl.accept(url) // imageUrl 업데이트
                }
            })
            .disposed(by: disposeBag)
        
        _isSubmitting
            .subscribe(onNext: { isSubmitting in
                print("isSubmitting: \(isSubmitting)")
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
