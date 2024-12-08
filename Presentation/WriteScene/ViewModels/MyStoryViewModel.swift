import RxSwift
import RxCocoa

class MyStoryViewModel {

    let storyData: Observable<[Story]>
    
    private let storyUseCase: StoryUseCaseProtocol
    private let disposeBag = DisposeBag()
    private let storyDataSubject = BehaviorSubject<[Story]>(value: [])
    
    init(storyUseCase: StoryUseCaseProtocol) {
        self.storyUseCase = storyUseCase
        
        self.storyData = storyDataSubject.asObservable()
        
        fetchStories()
    }
    
    private func fetchStories() {
        storyUseCase.fetchStories { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let stories):
                self.storyDataSubject.onNext(stories)
            case .failure(let error):
                print("Error fetching stories: \(error)")
            }
        }
    }
}
