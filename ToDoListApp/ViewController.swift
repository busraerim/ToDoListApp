//
//  ViewController.swift
//  ToDoListApp
//
//  Created by Büşra Erim on 2.01.2025.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK: Properties
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var models: [ToDoListItem] = []
    private var datePicker: UIDatePicker?
    private var dateTextField: UITextField?
    private var selectedDate = Date() {
        didSet {
            updateDateLabel()
            fetchItems(for: selectedDate)
        }
    }
    
    //MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        fetchItems(for: selectedDate)
    }
    
    //MARK: UI Preparation Methods
    
    private func setupView() {
        updateDateLabel()
    }
    
    private func setupTableView() {
        tableView.register(ToDoTableViewCell.nib, forCellReuseIdentifier: ToDoTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: Fetch Methods
    
    private func fetchItems(for date: Date) {
        let fetchRequest = ToDoListItem.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        fetchRequest.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            models = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Fetch error: \(error.localizedDescription)")
        }
    }
    
    private func createItem(detail: String, date: Date) {
        let newItem = ToDoListItem(context: context)
        newItem.detail = detail
        newItem.date = date
        
        do {
            try context.save()
            fetchItems(for: selectedDate)
        } catch {
            print("Error saving item: \(error.localizedDescription)")
        }
    }
    
    private func deleteItem(item: ToDoListItem) {
        context.delete(item)
        
        do {
            try context.save()
            fetchItems(for: selectedDate)
        } catch {
            print("Error deleting item: \(error.localizedDescription)")
        }
    }
    
    
    private func updateItem(item: ToDoListItem, detail: String, date: Date) {
        item.detail = detail
        item.date = date
        
        do {
            try context.save()
            fetchItems(for: selectedDate)
        } catch {
            print("Error updating item: \(error.localizedDescription)")
        }
    }
    
    //MARK: Helper Methods
    
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "tr_TR")
        dateLabel.text = formatter.string(from: selectedDate)
    }
    
    private func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(donePressed))
        let cancelButton = UIBarButtonItem(title: "Kapat", style: .plain, target: self, action: #selector(cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        return toolbar
    }
    
    private func configureDatePicker(for textField: UITextField, initialDate: Date) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "tr_TR")
        picker.date = initialDate
        
        textField.inputView = picker
        textField.inputAccessoryView = createToolbar()
        textField.text = formattedDate(from: initialDate)
        datePicker = picker
        dateTextField = textField
    }
    
    private func showTaskAlert(for item: ToDoListItem?) {
        let alert = UIAlertController(title: item == nil ? "Yeni Görev" : "Görevi Düzenle",
                                      message: "Görev Detaylarını Giriniz",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Görev Adı"
            textField.text = item?.detail
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Tarih Seçiniz"
            self.configureDatePicker(for: textField, initialDate: item?.date ?? Date())
        }
        
        let saveAction = UIAlertAction(title: "Kaydet", style: .default) { [weak self] _ in
            guard let fields = alert.textFields, fields.count >= 2,
                  let detail = fields[0].text, !detail.isEmpty,
                  let date = self?.datePicker?.date else { return }
            
            if let item = item {
                self?.updateItem(item: item, detail: detail, date: date)
            } else {
                self?.createItem(detail: detail, date: date)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Vazgeç", style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    //MARK: Actions
   
    @IBAction func addButtonTapped(_ sender: Any) {
        showTaskAlert(for: nil)
    }
    
    @objc func donePressed() {
        dateTextField?.text = formattedDate(from: datePicker?.date ?? Date())
        dateTextField?.resignFirstResponder()
    }
    
    @objc func cancelPressed() {
        dateTextField?.resignFirstResponder()
    }
    
    @IBAction func previousDayTapped(_ sender: Any) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) else { return }
        selectedDate = newDate
    }
    
    @IBAction func nextDayTapped(_ sender: Any) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else { return }
        selectedDate = newDate
    }
    
    
}

//MARK: TableView Methods

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ToDoTableViewCell.identifier, for: indexPath) as! ToDoTableViewCell
        let model = models[indexPath.row]
        cell.delegate = self
        cell.index = indexPath.row
        cell.modelIsDone = model.isCompleted
        cell.setupCell(item: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [self] (action, view, completion) in
            self.deleteItem(item: models[indexPath.row])
            completion(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Kapat", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Düzenle", style: .default, handler: { _ in
            self.showTaskAlert(for: item)
        }))
        
        sheet.addAction(UIAlertAction(title: "Sil", style: .destructive, handler: { _ in
            self.deleteItem(item: item)
        }))
        present(sheet, animated: true)
    }
}

//MARK: ToDoTableViewCellProtocol

extension ViewController: ToDoTableViewCellProtocol {
    func tappedDoneButton(index: Int, isCompleted: Bool) {
        guard index < models.count else { return }
              let item = models[index]
              item.isCompleted = isCompleted

              do {
                  try context.save()
                  fetchItems(for: selectedDate)
              } catch {
                  print("Error updating completion status: \(error.localizedDescription)")
              }
    }
}
