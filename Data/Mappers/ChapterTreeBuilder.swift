class ChapterTreeBuilder {
    func buildTree(flatChapters: [ChapterModel]) -> NestedChapter? {
        
        var chapterLookup: [String: NestedChapter] = [:]
        
        flatChapters.forEach { flatChapter in
            let nestedChapter = NestedChapter(
                id: flatChapter.id,
                storyId: flatChapter.storyId,
                title: flatChapter.title,
                imageUrl: flatChapter.imageUrl,
                description: flatChapter.description,
                location: flatChapter.location?.toCoordinate(),
                radius: flatChapter.radius,
                steps: flatChapter.steps,
                childChapters: []
            )
            if let id = flatChapter.id {
                chapterLookup[id] = nestedChapter
            }
        }
        
        var rootChapter: NestedChapter?

        for flatChapter in flatChapters {
            guard let currentNode = flatChapter.id.flatMap({ chapterLookup[$0] }) else { continue }
            
            let childNodes = flatChapter.childChapters.compactMap { chapterLookup[$0] }
            currentNode.childChapters.append(contentsOf: childNodes)

            if flatChapter.storyId == nil || flatChapters.allSatisfy({ !$0.childChapters.contains(flatChapter.id ?? "") }) {
                rootChapter = currentNode
            }
        }

        return rootChapter
    }
}
