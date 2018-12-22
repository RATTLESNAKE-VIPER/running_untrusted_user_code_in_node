let app = require('express')();
var request = require('request');

let ip = process.argv[2]
app.listen(6447, ip, (err) => {

    if (err) return console.log('something bad happened' + err);
    console.log(`server is listening on ${ip}:${6447}`);

});

let opts = {
    url: 'https://www.quora.com/How-trustworthy-is-faircent-com'
};

app.get('/check', (req, res) => {
    console.log('GET: /check ');
    request(opts, (e, r, b) => {
        console.log(r.statusCode);
        res.status(200).send('ok');
        restart();
    });
});

const restart = async () => {
    process.nextTick(() => {
        console.log(`restarting server`)
        process.exit();
    })
}


