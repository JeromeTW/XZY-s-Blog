//
//  CustomFlowLayout.swift
//  AdvancedCollectionView
//
//  Created by Jerome Hsieh on 2/18/17.
//  Copyright © 2017 NSScreencast. All rights reserved.
//

import UIKit

class CustomFlowLayout : UICollectionViewFlowLayout {
	
	var longPress: UILongPressGestureRecognizer!
	var originalIndexPath: IndexPath?
	var draggingIndexPath: IndexPath?
	var draggingView: UIView?
	var dragOffset = CGPoint.zero
	
	override func prepare() {
		super.prepare()
		installGestureRecognizer()
	}
	
	func applyDraggingAttributes(attributes: UICollectionViewLayoutAttributes) {
		attributes.alpha = 0
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		let attributes = super.layoutAttributesForElements(in: rect)
		attributes?.forEach { a in
			if let draggingIndexPath = draggingIndexPath, a.indexPath == draggingIndexPath, a.representedElementCategory == .cell {
				self.applyDraggingAttributes(attributes: a)
			}
			
		}
		return attributes
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		let attributes = super.layoutAttributesForItem(at: indexPath)
		if let attributes = attributes, indexPath == draggingIndexPath {
			if attributes.representedElementCategory == .cell {
				applyDraggingAttributes(attributes: attributes)
			}
		}
		return attributes
	}
	
	func installGestureRecognizer() {
		if longPress == nil {
			longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPress:)))
			longPress.minimumPressDuration = 0.2
			collectionView?.addGestureRecognizer(longPress)
		}
	}
	
	func handleLongPress(longPress: UILongPressGestureRecognizer) {
		let location = longPress.location(in: collectionView!)
		switch longPress.state {
		case .began: startDragAtLocation(location)
		case .changed: updateDragAtLocation(location)
		case .ended: endDragAtLocation(location)
		default:
			break
		}
	}
	
	func startDragAtLocation(_ location: CGPoint) {
		guard let cv = collectionView else {
			
			return }
		guard let indexPath = cv.indexPathForItem(at: location) else {
			return }
		guard (cv.dataSource?.collectionView!(cv, canMoveItemAt: indexPath))! else {
			if let _ = mainNavigationController.viewControllers.last as? CollectionWithEditBoxVC {	// 如果最上面的版面是固定式版面才發出通知
				let userInfo = [uIndexPath: indexPath]
				let notification = Notification(name: Notification.Name(rawValue: nLongPressingCellWithoutEditing), object: self, userInfo: userInfo)
				NotificationCenter.default.post(notification)
			}
			return
		}
		guard let cell = cv.cellForItem(at: indexPath) else {
			return }
		
		originalIndexPath = indexPath
		draggingIndexPath = indexPath
		draggingView = cell.snapshotView(afterScreenUpdates: true)
		draggingView!.frame = cell.frame
		cv.addSubview(draggingView!)
		dragOffset = CGPoint(x: draggingView!.center.x - location.x, y: draggingView!.center.y - location.y)
		
		draggingView?.layer.shadowPath = UIBezierPath(rect: draggingView!.bounds).cgPath
		draggingView?.layer.shadowColor = UIColor.black.cgColor
		draggingView?.layer.shadowOpacity = 0.8
		draggingView?.layer.shadowRadius = 10
		
		invalidateLayout()
		
		UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
			self.draggingView?.alpha = 0.95
			self.draggingView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
		}, completion: nil)
	}
	
	func updateDragAtLocation(_ location: CGPoint) {
		guard let view = draggingView else { return }
		guard let cv = collectionView else { return }
		
		view.center = CGPoint(x: location.x + dragOffset.x, y: location.y + dragOffset.y)
		
		if let newIndexPath = cv.indexPathForItem(at: location) {
			cv.moveItem(at: draggingIndexPath!, to: newIndexPath)
			draggingIndexPath = newIndexPath
		}
	}
	
	func endDragAtLocation(_ location: CGPoint) {
		guard let dragView = draggingView else { return }
		guard let indexPath = draggingIndexPath else { return }
		guard let cv = collectionView else { return }
		guard let datasource = cv.dataSource else { return }
		
		let targetCenter = datasource.collectionView(cv, cellForItemAt: indexPath).center
		
		let shadowFade = CABasicAnimation(keyPath: "shadowOpacity")
		shadowFade.fromValue = 0.8
		shadowFade.toValue = 0
		shadowFade.duration = 0.4
		dragView.layer.add(shadowFade, forKey: "shadowFade")
		
		UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
			dragView.center = targetCenter
			dragView.transform = CGAffineTransform.identity
			
			
		}) { (completed) in
			if !(indexPath == self.originalIndexPath!) {
				datasource.collectionView?(cv, moveItemAt: self.originalIndexPath!, to: indexPath)
			}
			
			dragView.removeFromSuperview()
			self.draggingIndexPath = nil
			self.draggingView = nil
			self.invalidateLayout()
		}
	}
}
