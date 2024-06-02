

if (
    secrets.tokenKey == ""
) {
    throw Error(
        "need token keys"
    )
}

const address = args[0] 
const assetId = args[1] 

const getBalanceOfUserAsset = Functions.makeHttpRequest({
    method: 'GET',
    url: `https://chainlink-backend.daltek.tech/stocks/user/stock/${assetId}?address=${address}`,
    headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'Authorization': 'Bearer ' + secrets.tokenKey,
    }
})

const [response] = await Promise.all([
    getBalanceOfUserAsset,
])
const responseStatus = response.status
console.log(`\nResponse status: ${responseStatus}\n`)
console.log("Stock get", response.data.data)
// console.log(`\n`)
const resp = response.data.data.value

// const [{ id, email, username }] = response.data
return Functions.encodeUint256(Math.round(resp * 1000000000000000000))
// return [{ id, email, username }]


