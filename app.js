
function ping() {
    console.log(Math.random());
}

function start(err) {
    if (err) throw err;
    setInterval(ping, 10000);
}


start(null);