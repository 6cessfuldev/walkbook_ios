class ChapterTreeBuilder {
    static func buildTree(flatChapters: [ChapterModel]) -> NestedChapter? {
        
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

        for flatChapter in flatChapters {
            guard let currentNode = flatChapter.id.flatMap({ chapterLookup[$0] }) else { continue }
            
            let childNodes = flatChapter.childChapters.compactMap { chapterLookup[$0] }
            currentNode.childChapters.append(contentsOf: childNodes)
        }
        
        let rootChapter = flatChapters.first { flatChapter in
            flatChapters.allSatisfy { flatChapter.id != nil && !$0.childChapters.contains(flatChapter.id!) }
        }.flatMap { return $0.id == nil ? nil : chapterLookup[$0.id!] }

        return rootChapter
    }
}
