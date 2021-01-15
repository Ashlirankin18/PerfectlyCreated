//
//  NotesCollectionViewCell.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/8/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

/// <#Description#>
final class NotesCollectionViewCell: UICollectionViewCell {
    
    /// Contains the information needed to configure `NotesCollectionViewCell`.
    struct ViewModel {
        
        enum Configuration {
            /// Represents if the cells is not editing.
            case display
            /// Represents if the cells is editing.
            case editing
        }
        
        /// The title of the cell.
        let title: String
        
        /// The notes the user has added to the product.
        let notes: String
        
        /// The configuration the cell will take.
        let configuration: Configuration
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var notesTextView: UITextView!
    
    private var textViewHeight: CGFloat = .zero
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Single point of configuration of `NotesCollectionViewCell`.
    var viewModel: ViewModel? {
        didSet {
            
            guard let viewModel = viewModel else {
                return
            }
            titleLabel.text = viewModel.title
            notesTextView.text = viewModel.notes
            
            notesTextView.isEditable = viewModel.configuration == .editing
            notesTextView.isSelectable = viewModel.configuration == .editing
            
            if viewModel.configuration == .editing {
                borderWidth = 1.0
                borderColor = .systemIndigo
                cornerRadius = 10
            }
        }
    }
    
    /// Called when the text view text changes.
    var notesTextHandler: ((String?) -> Void)?
    
    /// Publishes changes to the textview text.
    var textViewTextDidChangePublisher: AnyPublisher<String, Never> {
        return textViewTextDidChangeSubject.eraseToAnyPublisher()
    }
    
    private var textViewTextDidChangeSubject = PassthroughSubject<String, Never>()
        
    // MARK: - NSCoding
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notesTextView.delegate = self
        
        notesTextView.textPublisher
            .sink { [weak self] text in
                self?.notesTextHandler?(text)
            }
            .store(in: &cancellables)
    }
}

extension NotesCollectionViewCell: UITextViewDelegate {
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //this assumes that collection view already correctly laid out the cell
        //to the correct height for the contents of the UITextView
        //textViewHeight simply needs to catch up to it before user starts typing
        let fittingSize = textView.sizeThatFits(CGSize(width: notesTextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        textViewHeight = fittingSize.height
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //calculate fitting size after the content has changed
        let fittingSize = textView.sizeThatFits(CGSize(width: notesTextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        //if the current height is not equal to
        if textViewHeight != fittingSize.height {
            //save the new height
            textViewHeight = fittingSize.height
        }
        
        //notify the cell's delegate (most likely a UIViewController)
        //that UITextView's intrinsic content size has changed
        //perhaps with a protocol such as this:
        textViewTextDidChangeSubject.send(textView.text)
    }
}
