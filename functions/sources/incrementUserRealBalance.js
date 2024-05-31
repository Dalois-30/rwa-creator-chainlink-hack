

if (
    secrets.tokenKey == ""
) {
    throw Error(
        "need token keys"
    )
}

const address = args[0] 
const productId = args[1] 
const quantity = args[2]

const getBalanceOfUserProduct = Functions.makeHttpRequest({
    method: 'PUT',
    url: `https://chainlink-backend.daltek.tech/stocks/user/increment`,
    headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'Authorization': 'Bearer ' + secrets.tokenKey,
    },
    data: {
        productId: productId,
        address: address,
        quantity: quantity
    }
})

const [response] = await Promise.all([
    getBalanceOfUserProduct,
])
const responseStatus = response.status
console.log(`\nResponse status: ${responseStatus}\n`)
console.log("new quantity", response.data.data.quantity)
console.log(`\n`)
const newQuantity = response.data.data.quantity
return Functions.encodeUint256(newQuantity)


