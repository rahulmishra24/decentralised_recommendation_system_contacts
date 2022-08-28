//const axios = require("axios")
const fs = require("fs")
const { ethers } = require("ethers")
require("dotenv").config()
const walletPrivateKey = process.env.PRIVATE_KEY
const infuraURL = process.env.POLYGON_RPC
const provider = new ethers.providers.JsonRpcProvider(infuraURL)
const wallet = new ethers.Wallet(walletPrivateKey, provider)
const abi = require("./DeAdsMain.js")
const contractAddress = "0x6dad23e530Cc360B1Fad95a6f592858C367404B3"
const contract = new ethers.Contract(contractAddress, abi, provider)
const signingContract = contract.connect(wallet)
//const gasOptions = {  gasPrice: 10000000000, gasLimit: 8500000 };


//const tag = "sports";

const correlationScore = "91";

const getTags = async () => {
    //needs to be filed manually

    const trxObject = signingContract.getTags()
    const tx = await trxObject
        .then(async function (tx) {
            console.info('Transaction sent: %o', tx);
            //await tx.wait(5);
            return tx
        })
        .catch((err) => {
            console.error('Unable to complete transaction, error: %o', err);

            console.error(`Unable to complete transaction, error: ${err}`);
        });
    return tx;
}

const sendRecommendation = async (tag, ad, correlationScore) => {
    //needs to be filed manually

    const trxObject = signingContract.setUserRecommendation(tag, ad, correlationScore)
    await trxObject
        .then(async function (tx) {
            console.info('Transaction sent: %o', tx);
            await tx.wait(5);
            return tx;
            console.log(tx)
        })
        .catch((err) => {
            console.error('Unable to complete transaction, error: %o', err);

            console.error(`Unable to complete transaction, error: ${err}`);
        });
}
// console.log(JSON.parse(data))

//{}
// const tags = getTags().then(data=>{return data})
// console.log(tags);

(async () => {
//     
//     ad["sports"] = "https://www.youtube.com/watch?v=tntzYu4C_gE";
// ad["web3"] = "https://www.youtube.com/watch?v=sQJ-XQBzEuc"
// ad["cars"] = "https://www.youtube.com/watch?v=CbLc41NcV5k"
// ad["entertainment"] = "https://www.youtube.com/watch?v=LXXkiUKDK4w"
// ad["Computer Programming"] = "https://www.youtube.com/watch?v=rHn9af16O_E"
// ad["Gaming"] = "https://www.youtube.com/watch?v=bw544NrW5ak"
   const tags = await getTags()
    console.log(tags);
    sendRecommendation("web3","https://www.youtube.com/watch?v=bw544NrW5ak","80");    
    
    
})()