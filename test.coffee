app=require './app.coffee'
assert=require 'assert'
tests=require 'gqtest'

it=tests.it
xit=tests.xit
run=tests.doRun
th=this
db=null
opt=null
hand=null
next=null
log=console.log

getRandomInt=(min,max)->
  return Math.floor(Math.random() * (max - min + 1)) + min

rndid=getRandomInt(1,10000)

# dummy test for code integrity
it "should be able to run",(done)->
  done()

# create db

it "should be able to create db",(done)->
  db=app.createDB()
  opt=(req,res,next,db)->
    res.send 200,"OK"
  hand=app.handler db,opt
  next=(req,res)->
    res.send 200,"OK"
  done()

it "should be able to clean db",(done)->
  req={method:"delete",body:{query:{"index":rndid},multi:true}}
  res={send:(status,result)->
    log status
    log result
    assert.equal status,200
    done()
  }
  hand req,res,next

it "should be able to make field unique",(done)->
  req={method:"uniqueindex",body:{field:"index"}}
  res={send:(status,result)->
    log status
    log result
    assert.equal status,200
    done()
  }
  hand req,res,next

# post
it "should be able to post new entry",(done)->
  req={method:"post",body:{data:{index:rndid,value:"abc"}}}
  res={send:(status,result)->
    log status
    log result
    assert.equal status,200
    assert.equal result.value,"abc"
    done()
  }
  hand req,res,next

# get
it "should be able to get entry",(done)->
  req={method:"get",body:{query:{index:rndid}}}
  res={send:(status,result)->
    log status
    log result
    assert.equal status,200
    assert.equal result[0].value,"abc"
    done()
  }
  hand req,res,next

# head
it "should be able to head entry",(done)->
  req={method:"head",body:{query:{index:rndid}}}
  res={send:(status,result)->
    log status
    log result
    assert.equal status,200
    assert.equal result,1
    done()
  }
  hand req,res,next

# update
it "should be able to update entry",(done)->
  req={method:"update",body:{query:{index:rndid},data:{$set:{value:"def"}}}}
  res={send:(status,result)->
    log status
    log result
    assert.equal status,200
    assert.equal result,1
    done()
  }
  hand req,res,next

# upsert
it "should be able to upsert entry",(done)->
  req={method:"upsert",body:{query:{index:rndid},data:{index:rndid,value:"ghi"}}}
  res={send:(status,result)->
    log status
    log result
    assert.equal status,200
    assert.equal result.num,1
    done()
  }
  hand req,res,next

# delete
it "should be able to delete entry",(done)->
  req={method:"delete",body:{query:{index:rndid},multi:true}}
  res={send:(status,result)->
    log status
    log result
    assert.equal status,200
    assert.equal result,1
    done()
  }
  hand req,res,next

# opt
it "should be able to do opt operation",(done)->
  req={method:"opt",body:{data:{index:rndid}}}
  res={send:(status,result)->
    log status
    log result
    assert.equal status,200
    assert.equal result,"OK"
    done()
  }
  next=done
  hand req,res,next

# no method
it "should be able to handle no method",(done)->
  req={method:"none",body:{data:{index:rndid}}}
  res={send:(status,result)->
    log status
    log result
    assert.equal status,200
    assert.equal result,"OK"
    done()
  }
  next=(req,res)->
    res.send 200,"OK"
  hand req,res,next

xit "should be able to get abc",(done)->
  assert.equal app.abc,"abc"
  done()

run()