

if (
    secrets.tokenKey == ""
) {
    throw Error(
        "need token keys"
    )
}

const address = args[0]
const productId = args[1]
const amount = args[2];
const amountConverted = amount * 1000000000000000000

const getBalanceOfUserAsset = Functions.makeHttpRequest({
    method: 'GET',
    url: `https://chainlink-backend.daltek.tech/stocks/user/stock/${productId}?address=${address}`,
    headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'Authorization': 'Bearer ' + secrets.tokenKey,
    }
})


const [responseGet] = await Promise.all([
    getBalanceOfUserAsset,
])

const resp = responseGet.data.data
// const valueConverted = resp.value * 1000000000000000000


if (resp.value < amount) {
    return 0
}
else {
    const quantity = amount / resp.price
    const getBalanceOfUserProduct = Functions.makeHttpRequest({
        method: 'PUT',
        url: `https://chainlink-backend.daltek.tech/stocks/user/decrement`,
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
    });
    const [response] = await Promise.all([getBalanceOfUserProduct]);
    const responseStatus = response.status;
    console.log(`\nResponse status: ${responseStatus}\n`);
    console.log("new quantity", response.data.data.quantity);
    console.log(`\n`);

    // Vérify if response.data.data.quantity exist
    const hasQuantity = response.data && response.data.data && response.data.data.quantity !== undefined;

    // Return 1 if hasQuantity is true, else return 0
    const result = hasQuantity ? amountConverted : 0;

    return Functions.encodeUint256(result);
}









