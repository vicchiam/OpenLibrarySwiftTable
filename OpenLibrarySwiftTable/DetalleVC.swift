//
//  DetalleVC.swift
//  OpenLibrarySwiftTable
//
//  Created by Victor Chisvert Amat on 3/1/16.
//  Copyright © 2016 Victor Chisvert Amat. All rights reserved.
//

import UIKit

class DetalleVC: UIViewController {
    
    var isbn : String = ""

    @IBOutlet weak var lblTitulo: UILabel!
    
    @IBOutlet weak var lblAutor: UILabel!
    
    @IBOutlet weak var imgPortada: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        buscar(isbn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buscar(isbn : String) {
        
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)"
        let url = NSURL(string: urls)
        let datos = NSData(contentsOfURL: url!)
        
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            let dicc1 = json as! NSDictionary
            let first = dicc1.allValues[0]
            let dicc2 = first as! NSDictionary
            
            var titulo="Sin titulo"
            let title=dicc2["title"]
            if(title != nil){
                titulo=title as! String
            }
            
            lblTitulo.text=titulo
            
            var autores=""
            let authors=dicc2["authors"]
            if(authors != nil){
                let authors_array=authors as! NSArray
                if(authors_array.count>0){
                    for autor in authors_array {
                        let aux = autor as! NSDictionary
                        let nombre = aux["name"]!
                        autores+="\(nombre) \n"
                    }
                }
            }
            else{
                autores="Sin autor/es"
            }
            
            lblAutor.text=autores
            
            var portada=""
            let cover = dicc2["cover"]
            if cover != nil {
                let aux=cover as! NSDictionary
                let medium = aux["medium"]
                if(medium != nil){
                    portada=medium as! String
                }
            }
            
            if(portada==""){
                imgPortada.image=nil
            }
            else{
                ponerImagen(portada)
            }           
            
        }
        catch _ {
            print("Error")
        }
        
        
    }
    
    func ponerImagen(url : String){
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        let image=UIImage(data: data!)
        imgPortada.image=image
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
