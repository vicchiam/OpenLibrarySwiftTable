//
//  DetalleVC.swift
//  OpenLibrarySwiftTable
//
//  Created by Victor Chisvert Amat on 3/1/16.
//  Copyright © 2016 Victor Chisvert Amat. All rights reserved.
//

import UIKit
import CoreData

class DetalleVC: UIViewController {
    
    var isbn : String = ""
    var contexto : NSManagedObjectContext? = nil

    @IBOutlet weak var lblIsbn: UILabel!
    
    @IBOutlet weak var lblTitulo: UILabel!
    
    @IBOutlet weak var lblAutor: UILabel!
    
    @IBOutlet weak var imgPortada: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        lblIsbn.text = isbn
        obtenerLibro()
    }
    
    func obtenerLibro(){
        let EntidadLibro = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        let consulta = EntidadLibro?.managedObjectModel.fetchRequestFromTemplateWithName("getLibroPorIsbn", substitutionVariables: ["isbn":self.isbn])
        do{
            let Libro = try self.contexto?.executeFetchRequest(consulta!)
            if(Libro!.count>0){
                
                let titulo = Libro![0].valueForKey("titulo") as! String
                self.lblTitulo.text = titulo
                
                let portada = Libro![0].valueForKey("portada")
                if(portada != nil){
                    self.imgPortada.image = UIImage(data: portada as! NSData)
                }
                
                var autores = [String]()
                let Autores = Libro![0].valueForKey("tiene") as! Set<NSObject>
                for Autor in Autores{
                    let nombre = Autor.valueForKey("nombre") as! String
                    autores.append(nombre)
                }
                
                lblAutor.text=autores.joinWithSeparator("\n")
                
                return // No hace falta obtener nada mas
            }
        }
        catch{
            print("Error getLibroPorIsbn")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
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
    */
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
