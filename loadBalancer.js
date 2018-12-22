
global.config = require('./config');

const app = require('express')();
const redis = require('redis');
const { promisify } = require('util');

const request = promisify(require('request'));
const client = redis.createClient(global.config.REDIS);


const execute = async (req, res) => {

    let ip = await getVmIP();

    if (!ip) {
        console.log('all machine are busy')
        res.send('all machine are busy');
    } else {
        console.log(`executing code in ${ip}`)
        let opts = {
            url: 'http://' + ip + ':6447/check'
        }

        let [err, body] = await wait(request, null, opts);
        console.log(`----err data: ${err}, ${body}`);
        putVmIP(ip);
        return res.send(body);
    }

}

const getVmIP = async () => {
    let [err, ip] = await wait(client.lpop, client, config.IP_KEY);
    if (err || !ip) {
        console.error(`error in redis.lpop ${err}, ip ${ip}`);
        return false;
    } else {
        return ip;
    }

}

const putVmIP = async (ip) => {
    let [err, data] = await wait(client.rpush, client, config.IP_KEY, ip);
    if (err || !data) {
        console.error(`error in redis.rpush ${err}, ip ${data}`);
        return false;
    } else {
        console.log(`ip: ${ip} made available`);
        return data;
    }

}

app.listen(config.PORT, (error) => console.log(`listening on ${config.PORT}, error: ${error}`));

app.get('/execute', execute)

const wait = (func, context, ...args) => {
    try {

        if (func && typeof (func.then) === 'function') {
            return func.apply(context, args).then((data) => {
                return [null, data];
            })
                .catch((err) => [err]);
        }

        if (typeof (func) === 'function') {
            let f = func;
            f = promisify(f);
            return f.apply(context, args).then((data) => {
                return [null, data];
            })
                .catch((err) => [err]);
        }

    } catch (error) {
        logger.log(`error caught in wait: ${error}`)
        return [error];
    }

    throw Error('only function and promise is allowed to apply on wait');
}


