var fs = require('fs');

var b = "" + process.pid;
fs.writeFile('/var/run/app.pid', b, start);


function ping() {
    console.log(Math.random());
}

function start(err) {
    if (err) throw err;
    setInterval(ping, 10000);
}