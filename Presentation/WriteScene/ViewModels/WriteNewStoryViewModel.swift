import RxSwift
import RxCocoa

class WriteNewStoryViewModel {
    
    // Inputs
    let title = BehaviorRelay<String>(value: "")
    let author = BehaviorRelay<String>(value: "")
    let imageUrl = BehaviorRelay<String>(value: "")
    let description = BehaviorRelay<String>(value: "")
    let submitTapped = PublishRelay<Void>()
    
    // Outputs
    let isSubmitting: Driver<Bool>
    let submissionResult: Driver<Result<Void, Error>>
    
    private let useCase: StoryUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    init(useCase: StoryUseCaseProtocol) {
        self.useCase = useCase
        
        let _isSubmitting = BehaviorRelay<Bool>(value: false)
        let _submissionResult = PublishRelay<Result<Void, Error>>()
        
        self.isSubmitting = _isSubmitting.asDriver()
        self.submissionResult = _submissionResult.asDriver(onErrorJustReturn: .failure(NSError(domain: "UnknownError", code: -1, userInfo: nil)))
        
        submitTapped
            .withLatestFrom(Observable.combineLatest(title, author, imageUrl, description))
            .filter { !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty && !$0.3.isEmpty }
            .do(onNext: { _ in _isSubmitting.accept(true) })
            .flatMapLatest { [weak self] title, author, imageUrl, description -> Observable<Result<Void, Error>> in
                guard let self = self else { return Observable.just(.failure(NSError(domain: "ViewModelError", code: -1, userInfo: nil))) }
                let story = Story(id: nil, title: title, author: author, imageUrl: imageUrl, description: description)
                return self.createStoryObservable(story)
                    .catch { error in Observable.just(.failure(error)) }
            }
            .do(onNext: { _ in _isSubmitting.accept(false) })
            .bind(to: _submissionResult)
            .disposed(by: disposeBag)
    }
    
    private func createStoryObservable(_ story: Story) -> Observable<Result<Void, Error>> {
        return Observable.create { [weak self] observer in
            self?.useCase.createStory(story) { result in
                observer.onNext(result)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
