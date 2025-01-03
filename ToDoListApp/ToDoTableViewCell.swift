//
//  ToDoTableViewCell.swift
//  ToDoListApp
//
//  Created by Büşra Erim on 2.01.2025.
//

import UIKit

protocol ToDoTableViewCellProtocol: AnyObject {
    func tappedDoneButton(index: Int, isCompleted: Bool)
}

class ToDoTableViewCell: UITableViewCell {

    //MARK: Outlets

    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    //MARK: Properties

    static let identifier = "ToDoTableViewCell"
    static let nib = UINib(nibName: "ToDoTableViewCell", bundle: nil)
    weak var delegate: ToDoTableViewCellProtocol?
    var modelIsDone: Bool = false
    var index: Int = 0
   
    //MARK: LifeCycle Methods

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: Helper Methods

    public func setupCell(item: ToDoListItem) {
        if item.isCompleted {
            doneButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            doneButton.tintColor = .systemGreen
            self.contentView.backgroundColor = .systemGray5
        } else {
            doneButton.setImage(UIImage(systemName: "circle"), for: .normal)
            doneButton.tintColor = .systemBlue
            self.contentView.backgroundColor = .white
            
        }
        self.modelIsDone = item.isCompleted
        detailLabel.text = item.detail
    }
    
    //MARK: Actions

    @IBAction func tappedDoneButton(_ sender: Any) {
        delegate?.tappedDoneButton(index: self.index, isCompleted: !modelIsDone )
    }
}
