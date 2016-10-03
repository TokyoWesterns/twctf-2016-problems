var express = require('express');
var morgan = require('morgan');
var bodyParser = require('body-parser');
var cors = require('cors');
var app = express();
var data = require('./data').data;
app.disable('x-powered-by');
app.use(morgan('dev', { immediate: true }));
app.use(bodyParser.json({limit: '50mb'}));
app.use(cors());

app.post('/check', function(req, res) {
  console.log(req.body.level);
  if(req.body.level == 'easy' ||
     req.body.level == 'normal' ||
     req.body.level == 'lunatic') {
    map = data[req.body.level];
    var result = Array(map.height);
    for(var y = 0; y < map.height; y++) {
      result[y] = Array(map.width);
      for(var x = 0; x < map.width; x++) {
        result[y][x] = 0;
      }
    }
    var dx = [0,1,2,1,0,-1,-2,-1], dy = [-2,-1,0,1,2,1,0,-1];
    for(var y = 0; y < map.height; y++) {
      for(var x = 0; x < map.width; x++) {
        if(req.body.clicked[y * map.width + x] === '1') {
          for(var i = 0; i < 8; i++) {
            var nx = x + dx[i], ny = y + dy[i];
            if(0 <= nx && nx < map.width &&
                0 <= ny && ny < map.height) {
              result[ny][nx] ^= 1;
            }
          }
        }
      }
    }
    var resstr = '';
    for(var y = 0; y < map.height; y++) {
      for(var x = 0; x < map.width; x++) {
        resstr += result[y][x] === 1 ? '1' : '0';
      }
    }
    if(resstr === map.map) {
      resp = {result: "Correct"};
      if(req.body.level == 'easy') {
        resp.message = 'but it is too easy to give the flag.';
      }else if(req.body.level == 'normal') {
        resp.message = 'Good! The flag is TWCTF{peaceful_tea_party}';
      }else if(req.body.level == 'lunatic') {
        resp.message = 'Wonderful! The flag is TWCTF{happy_ra1ny_step}';
      }
      res.json(resp);
    } else {
      res.json({result: "Wrong"});
    }
  }else {
    res.send("Error");
  }
});
var port = process.env.PORT || 3000;
app.listen(port);
