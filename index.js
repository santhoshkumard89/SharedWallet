
// ==============================================================================

const express = require("express");
const app = express();

app.set('view engine', 'ejs');

const { Web3 } = require('web3');
let web3 = new Web3(Web3.givenProvider || "http://127.0.0.1:8545");
const contractJson = require("./build/contracts/SharedWallet.json");
const ContractAddress = contractJson.networks[20230710].address;
var contract = new web3.eth.Contract(contractJson.abi,ContractAddress);

const bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({extended:true}));

var accounts;
var owner;
var guardians=[];
var guardiansCount;
var contractBal;
var ownerBal;
var evts=[];

// ==============================================================================

app.get("/",async (req,res)=>{
    await web3.eth.getAccounts().then((result)=>{
        accounts = result;
    });
    
    await contract.methods.owner()
    .call()
    .then((result)=>{
        owner =result;
    })

    await web3.eth.getBalance(owner)
    .then((result) => {
        ownerBal = web3.utils.fromWei(result, "ether");
    });

    await contract.methods.contractBalance()
    .call()
    .then((result)=>{
        contractBal = result;
    })    
    
    await contract.methods.guardianCounter()
    .call()
    .then((result)=>{
        guardiansCount = Number(result);
    })

    res.render('getAccounts',{
        accounts: accounts, 
        owner: owner, 
        guardians: guardians, 
        contractBal: contractBal,
        ownerBal: ownerBal,
        evts: evts
    });
})

// ==============================================================================

app.post("/Guardian",async (req,res)=>{

    var guardiansData = [];
    for(var i=0; i<guardiansCount;i++){
        await contract.methods.guardians(i)
        .call()
        .then((result)=>{
            // console.log(result);
            guardiansData.push(result)
        })
    }
    // console.log(guardiansData);
    guardians = guardiansData;

    res.redirect("/");

})

// ==============================================================================

app.post("/",async(req,res)=>{
    var acc = req.body.acc;
    if(acc != 0){
        await contract.methods.setGuardians(acc)
        .send({from:owner})
        .then((result)=>{
            console.log(result);
            // req.send(result);
        })
    }
    // res.render("Guardian set Success");
    res.redirect("/");
})

// ==============================================================================

app.post("/UpdateGuardian",async (req,res)=>{
    console.log(req.body);
    await contract.methods.updateGuardians(req.body.address,req.body.index)
    .send({from:owner})
    .then((result)=>{
        console.log(result);
        // req.send(result);
    })

    res.redirect("/");
})

// ==============================================================================

app.post("/UpdateOwner",async (req,res)=>{
    console.log(req.body);
    await contract.methods.setNewOwner(req.body.NewOwner)
    .send({from:req.body.sender})
    .then((result)=>{
        console.log(result);
        // req.send(result);
    })

    res.redirect("/");
})

// ==============================================================================

app.post("/SendETHtoContract",async (req,res)=>{
    // console.log(req.body.amount);

    await web3.eth.sendTransaction({
        from: owner,
        to: ContractAddress,
        value: req.body.amount
    })
    .then((result) => {
        console.log(result);
    });

    res.redirect("/");
})

// ==============================================================================

app.post("/AllowanceDetails",async (req,res)=>{
    // console.log(req.body.account);
    
    await contract.getPastEvents("allowanceDetails",{
        filter: {_address: req.body.account},
        fromBlock: 0,
        toBlock: 'latest'
    })
    .then(function(events){
        evts = cleanEvents(events);
        // console.log(events);
    })

    res.redirect("/");

})

function cleanEvents(evts){
    var events_array = [];
    for(let i=0;i<evts.length;i++){
        var events_dict = {};
        events_dict["_address"] = evts[i].returnValues._address;
        events_dict["_amount"] = evts[i].returnValues._amount;
        events_dict["_balance"] = evts[i].returnValues._balance;
        events_dict["_description"] = evts[i].returnValues._description;
        
        events_array.push(events_dict);
        
    }
    
    // console.log(events_array);
    return events_array;
};

// ==============================================================================

app.post("/SetAllowance",async (req,res)=>{
    var addr = req.body.address;
    var amount = req.body.amount;
    await contract.methods.setAllowance(addr, amount)
    .send({from:owner})
    .then((result)=>{
        console.log(result);
        // req.send(result);
    })

    res.redirect("/");
})

// ==============================================================================

app.listen(3000,()=>{
    console.log("Node on port 3000!");
});

// ==============================================================================