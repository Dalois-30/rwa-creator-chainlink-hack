if (
    secrets.tokenKey == ""
) {
    throw Error(
        "need token keys"
    )
}

const getAllUsersRequest = Functions.makeHttpRequest({
    method: 'GET',
    url: "https://chainlink-backend.daltek.tech/admin/users/list",
    headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'Authorization': 'Bearer ' + secrets.tokenKey,
    }
})

const [response] = await Promise.all([
    getAllUsersRequest,
])
// const responseStatus = response.statusCode
// console.log(`\nResponse status: ${responseStatus}\n`)
console.log("Users get", response)
console.log(`\n`)

// const [{ id, email, username }] = response.data
return 0
// return [{ id, email, username }]


