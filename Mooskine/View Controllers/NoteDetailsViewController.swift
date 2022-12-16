//
//  NoteDetailsViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

class NoteDetailsViewController: UIViewController {
    /// A text view that displays a note's text
    @IBOutlet weak var textView: UITextView!

    /// The note being displayed and edited
    var note: Note!
    var dataController:DataController!
    /// A closure that is run when the user asks to delete the current note
    var onDelete: (() -> Void)?

    /// A date formatter for the view controller's title text
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let creationDate = note.creationDate{
            navigationItem.title = dateFormatter.string(from: creationDate)
        }
        textView.attributedText = note.attributedText
        
        // keyboard toolbar configuration
        configureToolbarItems()
        configureTextViewInputAccessoryView()
    }

    @IBAction func deleteNote(sender: Any) {
        presentDeleteNotebookAlert()
    }
}

// -----------------------------------------------------------------------------
// MARK: - Editing

extension NoteDetailsViewController {
    func presentDeleteNotebookAlert() {
        let alert = UIAlertController(title: "Delete Note", message: "Do you want to delete this note?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: deleteHandler))
        present(alert, animated: true, completion: nil)
    }

    func deleteHandler(alertAction: UIAlertAction) {
        onDelete?()
    }
}

// -----------------------------------------------------------------------------
// MARK: - UITextViewDelegate

extension NoteDetailsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        note.attributedText = textView.attributedText
        //try? note.managedObjectContext?.save()
        try? dataController.viewContext.save()
    }
}


// MARK: - Toolbar

extension NoteDetailsViewController {
    /// Returns an array of toolbar items. Used to configure the view controller's
    /// `toolbarItems' property, and to configure an accessory view for the
    /// text view's keyboard that also displays these items.
    func makeToolbarItems() -> [UIBarButtonItem] {
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped(sender:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let bold = UIBarButtonItem(image: UIImage(named: "toolbar-bold" ), style: .plain, target: self, action: #selector(boldTapped(sender:)))
        let underline = UIBarButtonItem(image: UIImage(named: "toolbar-underline") , style: .plain, target: self, action: #selector(underlineTapped(sender:)))
        let cow = UIBarButtonItem(image: UIImage(named:"toolbar-cow") , style: .plain, target: self, action: #selector(cowTapped(sender:)))
        return [trash, space, bold,space,underline,space,cow]
    }

    /// Configure the current toolbar
    func configureToolbarItems() {
        toolbarItems = makeToolbarItems()
        navigationController?.setToolbarHidden(false, animated: false)
        }

    /// Configure the text view's input accessory view -- this is the view that
    /// appears above the keyboard. We'll return a toolbar populated with our
    /// view controller's toolbar items, so that the toolbar functionality isn't
    /// hidden when the keyboard appears
    func configureTextViewInputAccessoryView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        toolbar.items = makeToolbarItems()
        textView.inputAccessoryView = toolbar
    }

    @IBAction func deleteTapped(sender: Any) {
        showDeleteAlert()
    }
    @IBAction func boldTapped(sender: Any) {
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        newText.addAttribute(.font, value: UIFont(name: "OpenSans-Bold", size: 22), range: textView.selectedRange)
        let selectedTextRange = textView.selectedTextRange
        textView.attributedText = newText
        //textView.selectedTextRange = selectedTextRange
        note.attributedText = textView.attributedText
        try? dataController.viewContext.save()
    }
    @IBAction func underlineTapped(sender: Any) {
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        let attributes:[NSAttributedString.Key:Any] = [.foregroundColor: UIColor.red,.underlineStyle: 1,.underlineColor: UIColor.red]
        newText.addAttributes(attributes, range: textView.selectedRange)
        let selectedTextRange = textView.selectedTextRange
        textView.attributedText = newText
        //textView.selectedTextRange = selectedTextRange
        note.attributedText = textView.attributedText
        try? dataController.viewContext.save()
        
    }
    @IBAction func cowTapped(sender: Any) {
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        let selectRange = textView.selectedRange
        let selectText = textView.attributedText.attributedSubstring(from: selectRange)
        let cowText = Pathifier.makeMutableAttributedString(for: selectText, withFont: UIFont(name: "AvenirNext-Heavy", size: 56)!, withPatternImage: UIImage(named: "texture-cow")!)
        newText.replaceCharacters(in: selectRange, with: cowText)

        textView.attributedText = newText
        textView.selectedRange = NSMakeRange(selectRange.location, 1)
        //textView.selectedTextRange = selectedTextRange
        note.attributedText = textView.attributedText
        try? dataController.viewContext.save()
    }

    // MARK: Helper methods for actions
    private func showDeleteAlert() {
        let alert = UIAlertController(title: "Delete Note?", message: "Are you sure you want to delete the current note?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.onDelete?()
        }

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
}
