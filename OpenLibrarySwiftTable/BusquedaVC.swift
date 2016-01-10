//
//  BusquedaVC.swift
//  OpenLibrarySwiftTable
//
//  Created by Victor Chisvert Amat on 3/1/16.
//  Copyright © 2016 Victor Chisvert Amat. All rights reserved.
//

import UIKit
import CoreData

class BusquedaVC: UIViewController ,UITextFieldDelegate{

    @IBOutlet weak var lblTitulo: UILabel!
    
    @IBOutlet weak var lblAutor: UILabel!
    
    @IBOutlet weak var imgPortada: UIImageView!
    
    @IBOutlet weak var campoTexto: UITextField!
    
    var isbn: String = ""
    
    var titulo: String = ""

    var autores: [String] = [String]()
    
    var portada: UIImage? = nil
    
    var contexto : NSManagedObjectContext? = nil
    
    var existe : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        campoTexto.delegate=self
        //campoTexto.text="0201558025"
        
        
        //Capturar evento boton vuelta atras
        self.navigationItem.hidesBackButton = true
        let newButton = UIBarButtonItem(title: "< Volver", style: .Plain, target: self, action: "volver:")
        self.navigationItem.leftBarButtonItem = newButton
        
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        
    }
    
    func volver(sender: UIBarButtonItem){
        //Si existe=true el libro ya ha sido obtenido de la BBDD
        if(self.titulo == "" || self.existe){
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        let alert=UIAlertController(title: "Guardar", message: "¿Deseas guardar el libro?", preferredStyle: .Alert)
        let yesAction=UIAlertAction(title: "Guardar", style: .Default){ (action) in
            print("SI")
            self.guardarLibro()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        let noAction=UIAlertAction(title: "Descartar", style: .Default){ (action) in
            print("NO")
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func buscar(isbn : String) {
        print(isbn)
        self.isbn=isbn
        self.titulo=""
        self.autores = [String]()
        self.portada = nil
        self.existe=false
        
        //Buscar en la BBDD
        let EntidadLibro = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        let consulta = EntidadLibro?.managedObjectModel.fetchRequestFromTemplateWithName("getLibroPorIsbn", substitutionVariables: ["isbn":self.isbn])
        do{
            let Libro = try self.contexto?.executeFetchRequest(consulta!)
            if(Libro!.count>0){
                self.existe=true
                
                let titulo = Libro![0].valueForKey("titulo") as! String
                self.titulo = titulo
                
                let portada = Libro![0].valueForKey("portada")
                if(portada != nil){
                    self.portada = UIImage(data: portada as! NSData)
                }
                
                let Autores = Libro![0].valueForKey("tiene") as! Set<NSObject>
                for Autor in Autores{
                    let nombre = Autor.valueForKey("nombre") as! String
                    self.autores.append(nombre)
                }
                
                lblTitulo.text = self.titulo
                lblAutor.text=self.autores.joinWithSeparator("\n")
                if(self.portada != nil){
                    imgPortada.image=self.portada
                }
                return // No hace falta obtener nada mas
            }
        }
        catch{
            print("Error getLibroPorIsbn")
        }
        
        
        //Buscar en OpenLibrary
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(self.isbn)"
        let url = NSURL(string: urls)
        let datos = NSData(contentsOfURL: url!)
        
        if(datos == nil){
            mostrarAlerta("Error", mensaje: "No se ha podido realizar la conexión")
            return
        }
        
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            let dicc1 = json as! NSDictionary
            if(dicc1.allValues.count == 0){
                mostrarAlerta("Advertencia", mensaje: "ISBN no encontrado")
                return
            }
            let first = dicc1.allValues[0]
            let dicc2 = first as! NSDictionary
            
            let title=dicc2["title"]
            if(title != nil){
                self.titulo=title as! String
            }
            
            lblTitulo.text=self.titulo
            
            let authors=dicc2["authors"]
            if(authors != nil){
                let authors_array=authors as! NSArray
                if(authors_array.count>0){
                    for autor in authors_array {
                        let aux = autor as! NSDictionary
                        let nombre = aux["name"]!
                        self.autores.append("\(nombre)")
                    }
                }
            }
            
            lblAutor.text=self.autores.joinWithSeparator("\n")
            
            var portadaURL=""
            let cover = dicc2["cover"]
            if cover != nil {
                let aux=cover as! NSDictionary
                let medium = aux["medium"]
                if(medium != nil){
                    portadaURL=medium as! String
                }
            }
            
            if(portadaURL != ""){
                ponerImagen(portadaURL)
            }
            
        }
        catch {
            mostrarAlerta("Error", mensaje: "Los datos no son validos")
        }

        
    }
    
    func ponerImagen(url : String){
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        let image=UIImage(data: data!)
        if(image == nil){
            mostrarAlerta("Error", mensaje: "Error al obtener la portada")
        }
        imgPortada.image=image
        self.portada=image!
    }
    
    func guardarLibro(){
        if(self.titulo != ""){
            //Guarda el libro en el arreglo de la Vista Tabla
            libros.append([self.titulo,self.isbn])
            
            //Guardar en BBDD
            let nuevoLibro = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
            nuevoLibro.setValue(self.isbn, forKey: "isbn")
            nuevoLibro.setValue(self.titulo, forKey: "titulo")
            if(self.portada != nil){
                nuevoLibro.setValue(UIImagePNGRepresentation(self.portada!), forKey: "portada")
            }
            
            var autores = Set<NSObject>()
            for autor in self.autores{
                let nuevoAutor = NSEntityDescription.insertNewObjectForEntityForName("Autor", inManagedObjectContext: self.contexto!)
                nuevoAutor.setValue(autor, forKey: "nombre")
                autores.insert(nuevoAutor)
            }
            
            if(autores.count>0){
                nuevoLibro.setValue(autores, forKey: "tiene")
            }
            
            do{
                try self.contexto?.save()
            }
            catch {
                print("Error al guardar")
            }
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String ){
        let alert=UIAlertController(title: titulo, message: mensaje, preferredStyle: .Alert)
        let okAction=UIAlertAction(title: "OK", style: .Default){ (action) in }
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //////////////////// Gestion del teclado /////////////////////////////
    
    
    //Para ocultar el teclado cuando el campo pierde el foco
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    
    // Metodo de UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if (textField.text! != "") {
            buscar(textField.text!)
        }
        return true
    }
    
    /////////////////////////////////////////////////////////////////////
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    */

}
