//
//  ViewController.swift
//  downloadManagerTest
//
//  Created by Masam Mahmood on 5.02.2020.
//  Copyright © 2020 xyz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var Appdata : [Appointment]?
    var AppDetailData : AppointmentDetail?
    fileprivate var fileDownLoadDataArray:[DownLoadData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib.init(nibName: "ChildTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ChildTableViewCell")
        
        appointmentData()
        
    }
    
    
    // MARK: - Data Services.
    func appointmentData(){
        
        if let url = Bundle.main.url(forResource: "Appointment", withExtension: "json") {
            do {
                
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(ResponseData.self, from: data)
                self.Appdata = jsonData.appointments
                
                for i in Appdata! {
                    self.detailData(AppId: i.id ?? 0, AppName: i.projectName!)
                }
                self.tableView.reloadData()
            } catch {
                print("error:\(error)")
            }
        }
        
    }
    
    func detailData(AppId: Int, AppName: String){
        
        if let url = Bundle.main.url(forResource: "AppointmentDetail", withExtension: "json") {
            do {
                
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(AppointmentDetail.self, from: data)
                self.AppDetailData = jsonData
                
                for param in AppDetailData?.sectionList ?? [] {
                    for item in param.items! {
                        
                        if item.actionType == 2 {
                            let filename = item.actionUrl ?? ""
                    
                            let data = DownLoadData(with: AppName, and: item.actionUrl ?? "")
                            fileDownLoadDataArray.append(data)
                        }
                    }
                }

            } catch {
                print("error:\(error)")
            }
        }
        
    }
    
    
    @IBAction func btnDownload(_ sender: Any) {
        for downloadItem in fileDownLoadDataArray{
            
            downloadItem.groupDownloadON = true
        }
        tableView.reloadData()
    }

}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 33
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10   
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileDownLoadDataArray.count //Appdata?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChildTableViewCell", for: indexPath) as! ChildTableViewCell
        //let dic = Appdata?[indexPath.row]
        
        //cell.fileNameLabel.text = dic?.projectName
        
        let downloadData = fileDownLoadDataArray[indexPath.row]
        cell.configureCell(with: downloadData)
        cell.cellDelegate = self
        
        return cell
    }
    
    
}


extension ViewController: DownLoadTableViewCellDelegate {
    func downloadCompleted() {
        print("Download Done")
    }
    
    func downloadFailedWithError(message: String) {
        print("Error:  \(message)")
    }
    
    
}
