import UIKit

class CarouselFlowLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout {
    
    let activeDistance: CGFloat = 200
    let zoomFactor: CGFloat = 0.3

    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        let itemWidth = collectionView!.bounds.width * 0.8
        let itemHeight = collectionView!.bounds.height * 1
        itemSize = CGSize(width: itemWidth, height: itemHeight)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        
        // 화면 중앙 위치 계산
        let collectionViewCenter = collectionView.bounds.size.width / 2
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewCenter

        // 가장 가까운 아이템의 중간 위치 찾기
        let closestAttribute = layoutAttributesForElements(in: collectionView.bounds)?.min(by: { abs($0.center.x - proposedContentOffsetCenterX) < abs($1.center.x - proposedContentOffsetCenterX) })

        guard let closest = closestAttribute else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        
        let targetContentOffsetX = closest.center.x - collectionViewCenter
        return CGPoint(x: targetContentOffsetX, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
