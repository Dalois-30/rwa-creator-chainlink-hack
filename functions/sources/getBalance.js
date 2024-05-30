

if (
    secrets.tokenKey == ""
) {
    throw Error(
        "need token keys"
    )
}

const address = args[0] 
const productId = args[1] 

const getBalanceOfUserProduct = Functions.makeHttpRequest({
    method: 'GET',
    url: `https://chainlink-backend.daltek.tech/stocks/user/stock/${productId}?address=${address}`,
    headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'Authorization': 'Bearer ' + secrets.tokenKey,
    }
})

const [response] = await Promise.all([
    getBalanceOfUserProduct,
])
const responseStatus = response.status
console.log(`\nResponse status: ${responseStatus}\n`)
console.log("Stock get", response.data.data)
console.log(`\n`)
const resp = response.data.data

// const [{ id, email, username }] = response.data
return Functions.encodeUint256(resp)
// return [{ id, email, username }]


