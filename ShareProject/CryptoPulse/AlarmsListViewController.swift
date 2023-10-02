//
//  AlarmsViewController.swift
//  CyptoPulse
//
//  Created by Vitaly on 21.09.2023.
//

import UIKit

class AlarmsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var tableView = UITableView()
    var searchBar = UISearchBar()
    var filtredAlarms: [AlarmModel] = []
    var accounts = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = DataLoader(keys: "savedAlarms")
        defaults.loadUserSymbols()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateData()
        tableView.reloadData()
    }
    
    func setupUI() {
        configureNavButtons()
        configureSearchBar()
        configureTableView()
    }
    
    func updateData() {
        filtredAlarms = AlarmModelsArray.alarms
    }
    
    func configureNavButtons() {
        let eraseList = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeAlarmsFromList))
        let addAlarm = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarm))
        
        navigationItem.leftBarButtonItem = eraseList
        navigationItem.rightBarButtonItem = addAlarm
    }
    
    func configureSearchBar() {
        searchBar.delegate = self
        
        self.view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)])
    }
    
    func configureTableView() {
        tableView.register(AlarmTableViewCell.self, forCellReuseIdentifier: AlarmTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95),
            tableView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)])
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            filtredAlarms = AlarmModelsArray.alarms.filter { $0.symbol.contains(searchText.uppercased()) }
            tableView.reloadData()
        } else {
            filtredAlarms = AlarmModelsArray.alarms
            tableView.reloadData()
        }
    }
    
    @objc func addAlarm() {
        let vc = AddAlarmViewController()
        
        present(vc, animated: true)
    }
    
    @objc func removeAlarmsFromList() {
        AlarmModelsArray.alarms.removeAll()
        filtredAlarms.removeAll()
        tableView.reloadData()
//        AlarmModelsArray.alarmaLine.removeAll()
        
        let defaults = DataLoader(keys: "savedAlarms")
        defaults.saveData()
        
//        defaults.keys = "savedLines"
//        defaults.saveData()
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredAlarms.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmTableViewCell.identifier, for: indexPath) as? AlarmTableViewCell else { fatalError("Fatal error in AlarmVC CellForRow Method") }
        
        let item = filtredAlarms[indexPath.item]
        
        cell.tickerLabel.text = "\(item.symbol)"
        cell.dateLabel.text = "\(item.date)"
        cell.priceLabel.text = "Цена: \(item.alarmPrice)"
        cell.statusLabel.text = item.isActive ? "Активен" : "Не активен"
        
       return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(identifier: "DetailData") as? DetailViewController {
            detailVC.symbol = filtredAlarms[indexPath.item].symbol
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let toggleAction = self.toggleStatusAction(rowIndexPathAt: indexPath)
        let deleteAction = self.deleteRowAction(rowIndexPathAt: indexPath)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, toggleAction])
        
        return swipeActions
    }
    
    func deleteRowAction(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, _ in
            guard let self = self else { return }
            
            let itemToRemoveID = filtredAlarms[indexPath.item].id
            filtredAlarms.remove(at: indexPath.item)
            deleteItemFromStaticAlarms(id: itemToRemoveID)

            let defaults = DataLoader(keys: "savedAlarms")
            defaults.saveData()
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
        }
        action.backgroundColor = .systemRed
        action.image = UIImage(systemName: "trash")
        
        
        return action
    }
    
    func deleteItemFromStaticAlarms(id: Int) {
        for (index, item) in AlarmModelsArray.alarms.enumerated() {
            if item.id == id {
                AlarmModelsArray.alarms.remove(at: index)
            }
        }
    }
    
    func toggleStatusAction(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Переключить") { [weak self] _, _, _ in
            
            AlarmModelsArray.alarms[indexPath.item].isActive.toggle()
            self?.filtredAlarms[indexPath.item].isActive.toggle()
            
            let defaults = DataLoader(keys: "savedAlarms")
            defaults.saveData()
            
            self?.tableView.reloadData()
        }
        
        switch filtredAlarms[indexPath.item].isActive {
        case true:
            action.image = UIImage(systemName: "pause")
            action.backgroundColor = .systemGray
        case false:
            action.image = UIImage(systemName: "play")
            action.backgroundColor = .systemGreen
        }
        
        return action
    }
    
    @objc func printResponse() {
        for account in AlarmModelsArray.alarms {
            print(account)
        }
    }
    
    // метод пока не готов
//    func updateDBData() {
//        // указать конкретный объект
//        if let url = URL(string: "http://127.0.0.1:8000/api/account/1/") {
//
//            let accountData = accounts[0]
//            guard let encoded = try? JSONEncoder().encode(accountData) else {
//                print("Failed to encode alarm")
//                return
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "PUT"
//            request.addValue("application/JSON", forHTTPHeaderField: "Accept")
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
//            request.httpBody = encoded
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                  if let data = data {
//                      if let response = try? JSONDecoder().decode(Account.self, from: data) {
//                          return
//                      }
//
//                  }
//              }.resume()
//
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if error != nil {
//                    print(error!)
//                    return
//                }
//            }
//            task.resume()
//        }
//    }
    
    
    func removeDBData(remove id: Int) {
        if let url = URL(string: "http://127.0.0.1:8000/api/account/\(id)/") {
            var request = URLRequest(url: url)
            print(url)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
            }
            task.resume()
        }
    }
    
//    func addAlarmtoModelDB() {
//        if let url = URL(string: "http://127.0.0.1:8000/api/account/") {
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
//            
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if error != nil {
//                    print(error!)
//                    return
//                }
//                
//                if let data = data {
//                    if let response = try? JSONDecoder().decode(AlarmModel.self, from: data) {
//                        return
//                    }
//                }
//            }
//            task.resume()
//        }
//    }
    
    
    /*func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("Accessory path =", indexPath)
        
        let ownerCell = tableView.cellForRow(at: indexPath)
        print("Cell title =", ownerCell?.textLabel?.text ?? "nil")
    }*/
    
    
    
}