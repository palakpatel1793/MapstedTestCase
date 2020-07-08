//
//  ViewController.swift
//  MapstedTestCase
//
//  Created by Palak Patel on 2020-07-07.
//  Copyright © 2020 Palak Patel. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import DropDown

class ViewController: UIViewController {

    
    // MARK: - OUTLET CONNECTION
    @IBOutlet weak var btnManufacturer: UIButton!
      @IBOutlet weak var btnCategory: UIButton!
      @IBOutlet weak var btnCountry: UIButton!
      @IBOutlet weak var btnState: UIButton!
      @IBOutlet weak var btnItem: UIButton!

      @IBOutlet weak var manufacturerCostLabel: UILabel!
      @IBOutlet weak var categoryCostLabel: UILabel!
      @IBOutlet weak var countryCostLabel: UILabel!
      @IBOutlet weak var stateCostLabel: UILabel!
      @IBOutlet weak var itemNumberLabel: UILabel!
      @IBOutlet weak var buildingNameLabel: UILabel!
    
    // MARK: - VARIBALE DECLARATION
    
    var buildingData = [Int : Any]()
    var manufacturerDictCost = [String : Double]()
    var categoryIdDictCost = [Int : Double]()
    var countryDictCost = [String: Double]()
    var stateDictCost = [String: Double]()
    var itemDictCount = [Int: Int]()
    
    var arrManufactureData = Array<Any>()
    let dropDown = DropDown()
      
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        getBuildingData()
        getAnalyticData()
     
    }

   
    // MARK: - FUNCTIONS
    
    func getBuildingData()
    {
        let request = Request.init(url: "http://positioning-test.mapsted.com/api/Values/GetBuildingData/", method: RequestMethod(rawValue: "GET")!) { (success:Bool, request:Request, message:NSString) -> (Void) in
            if(request.isSuccess){
                let response = request.serverData["data"] as! [[String : Any]]
                for i in 0..<response.count
                {
                    self.buildingData[response[i]["building_id"] as! Int] = response[i]
                }

            } else {
                // API failed
            }
        }
        request.startRequest()
    }

    func getAnalyticData(){
            
            let request = Request.init(url: "http://positioning-test.mapsted.com/api/Values/GetAnalyticData/", method: RequestMethod(rawValue: "GET")!) { (success:Bool, request:Request, message:NSString) -> (Void) in
                if(request.isSuccess){
                                                            
                    let response = request.serverData["data"] as! [[String : Any]]
                    var mostBuildingPurchaseDictCost = [String : Double]()
                    
                    for i in 0..<response.count
                    {
                        let manufacturerName = response[i]["manufacturer"] as! String
                        let usageStatistics = response[i]["usage_statistics"] as! [String : Any]
                        let sessionInfos = usageStatistics["session_infos"] as! [[String : Any]]
                        
                        for i in 0..<sessionInfos.count
                        {
                            
                            let purchases = sessionInfos[i]["purchases"] as! [[String : Any]]
                            let buildingId = sessionInfos[i]["building_id"] as! Int
                            let buildingInfo = self.buildingData[buildingId] as! [String : Any]
                            let country =  buildingInfo["country"] as! String
                            let state =  buildingInfo["state"] as! String
                            let buildingName = buildingInfo["building_name"] as! String
                            
                            for j in 0..<purchases.count
                            {
                                let itemCost = purchases[j]["cost"] as! Double
                                let categoryId = purchases[j]["item_category_id"] as! Int
                                let itemId = purchases[j]["item_id"] as! Int

                                // calculate cost based on manufacturer
                                if (self.manufacturerDictCost[manufacturerName] != nil) {
                                    // found, add cost
                                    self.manufacturerDictCost[manufacturerName] = self.manufacturerDictCost[manufacturerName]! + itemCost
                                } else {
                                    // not found
                                    self.manufacturerDictCost[manufacturerName] = itemCost
                                }

                                // calculate cost based on Category
                                if (self.categoryIdDictCost[categoryId] != nil) {
                                   // found, add cost
                                   self.categoryIdDictCost[categoryId] = self.categoryIdDictCost[categoryId]! + itemCost
                                } else {
                                   // not found
                                   self.categoryIdDictCost[categoryId] = itemCost
                                }
                                
                                // calculate cost based on Country
                                if (self.countryDictCost[country] != nil) {
                                   // found, add cost
                                   self.countryDictCost[country] = self.countryDictCost[country]! + itemCost
                                } else {
                                   // not found
                                   self.countryDictCost[country] = itemCost
                                }
                                
                                // calculate cost based on State
                                if (self.stateDictCost[state] != nil) {
                                   // found, add cost
                                   self.stateDictCost[state] = self.stateDictCost[state]! + itemCost
                                } else {
                                   // not found
                                   self.stateDictCost[state] = itemCost
                                }
                                
                                //calculate number of items Purchase
                                if (self.itemDictCount[itemId] != nil) {
                                   // found, add cost
                                   self.itemDictCount[itemId] = self.itemDictCount[itemId]! + 1
                                } else {
                                   // not found
                                   self.itemDictCount[itemId] = itemId
                                }
                                
                                //calculate number of mostBuildingPurchaseDictCost
                               if (mostBuildingPurchaseDictCost[buildingName] != nil) {
                                  // found, add cost
                                  mostBuildingPurchaseDictCost[buildingName] = mostBuildingPurchaseDictCost[buildingName]! + itemCost
                               } else {
                                  // not found
                                  mostBuildingPurchaseDictCost[buildingName] = itemCost
                               }
                            }
                        }
                    }
                    
                    let greatestHue = mostBuildingPurchaseDictCost.max { a, b in a.value < b.value }
                    self.buildingNameLabel.text = "\(greatestHue!.key)"
                    
                }else{
                   
                }
            }
            request.startRequest()
        }
    
    // MARK: - ACTIONS
    
    @IBAction func onClickManufacturer(_ sender: UIButton) {
        let arrManuKeys = Array(manufacturerDictCost.keys)
        self.dropDown.dataSource = arrManuKeys
        dropDown.show()
        setData(btnText: self.btnManufacturer)

        
    }
    @IBAction func onClickCategory(_ sender: UIButton) {
        let arrManuKeys = Array(categoryIdDictCost.keys)
        let a = arrManuKeys.map{String($0)}
        self.dropDown.dataSource = a
        dropDown.show()
        setData(btnText: self.btnCategory)

        
    }
    @IBAction func onClickCountry(_ sender: UIButton) {
        let arrManuKeys = Array(countryDictCost.keys)
        self.dropDown.dataSource = arrManuKeys
        dropDown.show()
        setData(btnText: self.btnCountry)

        
    }
    
    @IBAction func onClickState(_ sender: UIButton) {
        let arrManuKeys = Array(stateDictCost.keys)
        self.dropDown.dataSource = arrManuKeys
        dropDown.show()
        setData(btnText: self.btnState)
    }
    
    @IBAction func onClickItem(_ sender: UIButton) {
          let arrManuKeys = Array(itemDictCount.keys)
          let a = arrManuKeys.map{String($0)}
          self.dropDown.dataSource = a
          dropDown.show()
          setData(btnText: self.btnItem)
      }
    
    func setData(btnText:UIButton){
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                  print("Selected item: \(item) at index: \(index)")
                    btnText.setTitle("\(item)", for: .normal)
                if btnText == self.btnManufacturer
                {
                    let arrManuKeys = Array(self.manufacturerDictCost.values)
                    let valueManufacturer = Double(round(1000*arrManuKeys[index])/1000)
                    self.manufacturerCostLabel.text = "$\(valueManufacturer)"
                }
                else if btnText == self.btnCountry
                {
                    let arrManuKeys = Array(self.countryDictCost.values)
                    let valueManufacturer = Double(round(1000*arrManuKeys[index])/1000)
                    self.countryCostLabel.text = "$\(valueManufacturer)"
                }
                else if btnText == self.btnCategory
                {
                    let arrManuKeys = Array(self.categoryIdDictCost.values)
                    let valueManufacturer = Double(round(1000*arrManuKeys[index])/1000)
                    self.categoryCostLabel.text = "$\(valueManufacturer)"
                }
                else if btnText == self.btnState
                {
                    let arrManuKeys = Array(self.stateDictCost.values)
                    let valueManufacturer = Double(round(1000*arrManuKeys[index])/1000)
                    self.stateCostLabel.text = "$\(valueManufacturer)"
                }else
                {
                    let arrManuKeys = Array(self.itemDictCount.values)
                    self.itemNumberLabel.text = "\(arrManuKeys[index])"
                }
         
                    }
    }
    
    
    
    
}























