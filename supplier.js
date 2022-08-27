//const axios = require("axios")
const fs = require("fs")
const { ethers } = require("ethers")
require("dotenv").config()
const walletPrivateKey = process.env.PRIVATE_KEY
const infuraURL = process.env.POLYGON_RPC
const provider = new ethers.providers.JsonRpcProvider(infuraURL)
const wallet = new ethers.Wallet(walletPrivateKey, provider)
const abi = require("./DeAdsMain.js")
const contractAddress = "0x85D5D3e06B7005d21e4E9b82212E73d2d46C9b69"
const contract = new ethers.Contract(contractAddress, abi, provider)
const signingContract = contract.connect(wallet)
//const gasOptions = {  gasPrice: 10000000000, gasLimit: 8500000 };


const tag = "sports";
const ad = "https://www.youtube.com/watch?v=tntzYu4C_gE";
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

const sendRecommendation = async (tag,ad,correlationScore) => {
    //needs to be filed manually
    
    const trxObject = signingContract.setUserRecommendation(tag, ad,correlationScore)
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

(async() =>{
    const tags = await getTags()
    console.log(tags);
    sendRecommendation(tags[0],ad,correlationScore);
})()