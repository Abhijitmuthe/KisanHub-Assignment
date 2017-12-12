//
//  ViewController.swift
//  KisanHubFileParser
//
//  Created by VM on 06/12/17.
//  Copyright © 2017 Abhijit Muthe. All rights reserved.
//

import UIKit
import Alamofire

class FilterFileViewController: UIViewController{

    @IBOutlet var btn: UIButton!
    var KeyDictionary:NSMutableDictionary = [:];
    var destfile:URL? = nil;
    let baseUrl = "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/"
    
    let month = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    
    override func viewDidLoad() {
            super.viewDidLoad()
        
            let uk = NSMutableDictionary();
            uk.setValue("Tmax/date/UK.txt", forKey:"Max Temp");
            uk.setValue( "Tmin/date/UK.txt", forKey:"Min Temp");
            uk.setValue("Tmean/date/UK.txt", forKey:"Mean Temp" );
            uk.setValue("Sunshine/date/UK.txt", forKey:"Sunshine" );
            uk.setValue("Rainfall/date/UK.txt", forKey:"Rainfall" );
            KeyDictionary.setValue(uk, forKey: "UK");
        
            let england = NSMutableDictionary();
            england.setValue("Tmax/date/England.txt", forKey:"Max Temp");
            england.setValue( "Tmin/date/England.txt", forKey:"Min Temp");
            england.setValue("Tmean/date/England.txt", forKey:"Mean Temp" );
            england.setValue("Sunshine/date/England.txt", forKey:"Sunshine" );
            england.setValue("Rainfall/date/England.txt", forKey:"Rainfall" );
            KeyDictionary.setValue(england, forKey: "England");
        
            let Wales = NSMutableDictionary();
            Wales.setValue("Tmax/date/Wales.txt", forKey:"Max Temp");
            Wales.setValue( "Tmin/date/Wales.txt", forKey:"Min Temp");
            Wales.setValue("Tmean/date/Wales.txt", forKey:"Mean Temp" );
            Wales.setValue("Sunshine/date/Wales.txt", forKey:"Sunshine" );
            Wales.setValue("Rainfall/date/EWales.txt", forKey:"Rainfall" );
            KeyDictionary.setValue(Wales, forKey: "Wales");
        
            let Scotland = NSMutableDictionary();
            Scotland.setValue("Tmax/date/Scotland.txt", forKey:"Max Temp");
            Scotland.setValue( "Tmin/date/Scotland.txt", forKey:"Min Temp");
            Scotland.setValue("Tmean/date/Scotland.txt", forKey:"Mean Temp" );
            Scotland.setValue("Sunshine/date/Scotland.txt", forKey:"Sunshine" );
            Scotland.setValue("Rainfall/date/Scotland.txt", forKey:"Rainfall" );
            KeyDictionary.setValue(Scotland, forKey: "Scotland");
        
            downloadFile();
        
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        }
    
    func downloadFile()
    {
         var fileurl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
         fileurl.appendPathComponent("weather.csv")
         destfile = fileurl;
        
        
         for (key,value) in KeyDictionary
         {
    
                let RegionSubValueKey = value as! NSDictionary;
                let Region = key as! String
            
            for (key,value) in RegionSubValueKey
            {
            
                
                let url = URL(string: baseUrl + (value as! String) );
            
                let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                    let fileName = Region + (key as! String) + ".txt"
                    var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    documentsURL.appendPathComponent(fileName)
                    return (documentsURL, [.removePreviousFile])
                }
        
              Alamofire.download(url!, to: destination).responseData { response in
                if let destinationUrl = response.destinationURL {
                    
                    print(destinationUrl);
             
                   self.open(path: destinationUrl,region: Region,regionSubValueKey: key as! String);
                    
                  }
               }
            }
            
         }
        
      }
     func open(path:URL,region:String,regionSubValueKey:String) {

        
        
        do
         {
            
            let data = try String(contentsOf: path, encoding: .utf8)
            var lineIterator = 0; // to avoid first 8 text lines
           
             data.enumerateLines(invoking: { (line, stop) -> () in
    
                if(lineIterator < 8)
                {
                    lineIterator += 1;
                }
                else
                {
                    let lineData = (line.condensedWhitespace).components(separatedBy: "\t");
                    var monthIterater = 0;
                    
                        
                        var charArray = Array(line.characters);
                        charArray.append("\0");
                        var charIterator = 0;
                        var spaceCounter = 0;
                        var str = "";
                        charArray.removeFirst(4);
                        while(true)
                        {
                            if(charArray[charIterator] == "\0")
                            {
                                break;
                            }
                            
                            if(charArray[charIterator] != " ")
                            {
                                str.append(charArray[charIterator]);
                            }
                            else{
                                
                                if(str.characters.count > 1)
                                {
                                    if(monthIterater < 12)
                                    {
                                      let finalStr =  region + "," + regionSubValueKey + "," + lineData[0] + "," + self.month[monthIterater] + "," + str + "\n" ;
                                        
                                          self.writeFile(dataString: finalStr);
                                           str = "";
                                           spaceCounter = 0;
                                           monthIterater += 1;
                                      }
                                    else
                                    {
                                        break;
                                    }
                                 
                                 }
                                
                                if(spaceCounter > 4)
                                {
                                    let finalStr =  region + "," + regionSubValueKey + "," + lineData[0] + "," + self.month[monthIterater] + "," + "N/A" + "\n" ;
                                     self.writeFile(dataString: finalStr);
                                    spaceCounter = 0;
                                    monthIterater += 1
                                    
                                    if(monthIterater > 11)
                                    {
                                        break
                                        
                                    }
                                    
                                    
                                }
                                
                                spaceCounter += 1;
                                
                             }
                            charIterator += 1;
                            
                         }
       
                   }
             })

          
        
        }
        catch(let exep){
            print(exep)
            
        }
   
    
    }

    func writeFile(dataString:String)
    {
        
        let finalData = dataString.data(using: .utf8);
        
        
        if FileManager.default.fileExists(atPath: (self.destfile?.path)!) {
            if let fileHandle = try? FileHandle(forUpdating: self.destfile!) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(finalData!)
                fileHandle.closeFile()
            }
        } else {
            try! finalData?.write(to: self.destfile!, options: Data.WritingOptions.atomic)
        }
        
    }

}



extension String {
    var condensedWhitespace: String {
        let components = self.components(separatedBy: "  ")
        
        return components.filter { !$0.isEmpty }.joined(separator: "\t")
    }
}
