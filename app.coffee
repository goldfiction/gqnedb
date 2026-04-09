Datastore = require 'nedb'
log=console.log
db=null

@createDB=(path)->
  db = new Datastore { filename: (path||'./db/nedb.json'), autoload: true }
  db.persistence.setAutocompactionInterval 120000
  log("nedb loaded...")
  return db

@getDB=()->
  return db

cleanStr=(str)->
  return str.trim().toLowerCase()

@handler=(db,opt)->
  return (req,res,next)->
    method=cleanStr req.method
    if method=="get"
      db.find req.body.query,(err,docs)->
        if err
          log err
          res.send 404,"Server error."
        else
          res.send 200,docs
    
    else if method=="head"
      db.count req.body.query,(err,count)->
        if err
          log err
          res.send 404,"Server error."
        else
          res.send 200,count
    
    else if method=="post"
      db.insert req.body.data,(err,result)->
        if err
          log err
          res.send 404,"Server error."
        else
          res.send 200,result
    
    else if method=="upsert"
      db.update req.body.query,req.body.data,{upsert:true},(err,num,upsert)->
        if err
          log err
          res.send 404,"Server error."
        else
          res.send 200,{num:num,upsert:upsert}
        
    else if method=="all"||method=="put"||method=="update"||method=="patch"  #use put to do entire doc, use patch to update
      db.update req.body.query,req.body.data,{multi:true},(err,result)->
        if err
          log err
          res.send 404,"Server error."
        else
          res.send 200,result
          
    else if method=="delete"||method=="remove"||method=="del"
      db.remove req.body.query,{multi:(!!req.body.multi)},(err,num)->
        if err
          log err
          res.send 404,"Server error."
        else
          db.persistence.compactDatafile();
          res.send 200,num
    
    else if method=="index"
      db.ensureIndex {fieldName:req.body.field},(err)->
        if err
          log err
          res.send 404,"Server error."
        else
          res.send 200,"OK"
    
    else if method=="uniqueindex"
      db.ensureIndex {fieldName:req.body.field,unique:true,sparse:true},(err)->
        if err
          log err
          res.send 404,"Server error."
        else
          res.send 200,"OK"
    
    else if method=="opt" # other operations
      if !!opt
        opt req,res,next,db
      else
        next req,res
    else
      next req,res





