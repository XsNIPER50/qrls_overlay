const WebSocket = require('ws');
const { success, error, warn, info, log } = require('cli-msg');
const atob = require('atob');
const fs = require('fs-extra');
require('dotenv').config();

const fetch = (...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args));

// EDIT THESE VALUES IF NEEDED
let p_delay = '0';
let p_port = 49322;
let p_rocketLeagueHost = 'localhost:49122';
//

let wsClient;
let relayMsDelay = parseInt(p_delay, 10);

const wss = new WebSocket.Server({ port: p_port });
let connections = {};
info.wb('Opened WebSocket server on port ' + p_port);

wss.on('connection', function connection(ws) {
  let id = (+new Date()).toString();
  success.wb('Received connection: ' + id);
  connections[id] = {
    connection: ws,
    registeredFunctions: [],
  };

  ws.send(
    JSON.stringify({
      event: 'wsRelay:info',
      data: 'Connected!',
    })
  );

  ws.on('message', function incoming(message) {
    sendRelayMessage(id, message);
  });

  ws.on('close', function close() {
    delete connections[id];
  });
});

initRocketLeagueWebsocket(p_rocketLeagueHost);
setInterval(function () {
  if (wsClient.readyState === WebSocket.CLOSED) {
    warn.wb('Rocket League WebSocket Server Closed. Attempting to reconnect');
    initRocketLeagueWebsocket(p_rocketLeagueHost);
  }
}, 10000);

function sendRelayMessage(senderConnectionId, message) {
  let json = JSON.parse(message);
  log.wb(senderConnectionId + '> Sent ' + json.event);

  let channelEvent = json['event'].split(':');

  // forward to Discord bot server
  if (channelEvent[0] === 'discord') {
    handleDiscord(json['data'], channelEvent);
  }

  if (channelEvent[0] === 'FSEvent') {
    if (channelEvent[1] === 'TeamWrite') {
      console.log(json['data']);
      fs.writeJson('./../../TeamPresets.json', { presets: json['data'] })
        .then(() => {
          console.log('success!');
        })
        .catch((err) => {
          console.error(err);
        });
    }
    if (channelEvent[1] === 'TeamGetter') {
      fs.ensureFile('./../../TeamPresets.json')
        .then(() => {
          const packageObj = fs.readJsonSync('./../../TeamPresets.json');
          sendRelayMessage(
            0,
            JSON.stringify({
              event: 'FSEvent:TeamPresetsList',
              data: packageObj,
            })
          );
        })
        .catch((err) => {
          console.error(err);
        });
    }
  }

  if (channelEvent[0] === 'save') {
    if (channelEvent[1] === 'stats') {
      fs.ensureDir('../../gameStats')
        .then(() => {
          const event = new Date();
          fs.writeJson(
            `../../gameStats/${event
              .toISOString()
              .slice(0, 19)
              .replaceAll(':', '_')}.json`,
            json['data']
          )
            .then(() => {
              console.log('Successfully saved the game stats!');
            })
            .catch((err) => {
              console.error(err);
            });
        })
        .catch((err) => {
          console.error(err);
        });
    }
  }

  if (channelEvent[0] === 'wsRelay') {
    if (channelEvent[1] === 'register') {
      if (connections[senderConnectionId].registeredFunctions.indexOf(json['data']) < 0) {
        connections[senderConnectionId].registeredFunctions.push(json['data']);
        info.wb(senderConnectionId + '> Registered to receive: ' + json['data']);
      } else {
        warn.wb(
          senderConnectionId +
            '> Attempted to register an already registered function: ' +
            json['data']
        );
      }
    } else if (channelEvent[1] === 'unregister') {
      let idx = connections[senderConnectionId].registeredFunctions.indexOf(json['data']);
      if (idx > -1) {
        connections[senderConnectionId].registeredFunctions.splice(idx, 1);
        info.wb(senderConnectionId + '> Unregistered: ' + json['data']);
      } else {
        warn.wb(
          senderConnectionId +
            '> Attempted to unregister a non-registered function: ' +
            json['data']
        );
      }
    }
    return;
  }

  for (let k in connections) {
    if (senderConnectionId === k) {
      continue;
    }
    if (!connections.hasOwnProperty(k)) {
      continue;
    }
    if (connections[k].registeredFunctions.indexOf(json['event']) > -1) {
      setTimeout(() => {
        try {
          connections[k].connection.send(message);
        } catch (e) {
          // connection can close between check and send, ignore
        }
      }, 0);
    }
  }
}

function initRocketLeagueWebsocket(rocketLeagueHost) {
  wsClient = new WebSocket('ws://localhost:49122');

  wsClient.onopen = function open() {
    success.wb('Connected to Rocket League on ' + rocketLeagueHost);
  };
  wsClient.onmessage = function (message) {
    let sendMessage = message.data;
    if (sendMessage.substr(0, 1) !== '{') {
      sendMessage = atob(message.data);
    }
    setTimeout(() => {
      sendRelayMessage(0, sendMessage);
    }, relayMsDelay);
  };
  wsClient.onerror = function (err) {
    error.wb(
      `Error connecting to Rocket League on host "${rocketLeagueHost}"\n` +
        'Is the plugin loaded into Rocket League? Run the command "plugin load sos" from the BakkesMod console to make sure'
    );
  };
}

// --- FORWARD TO BOT SERVER (NO API KEY) ---
async function handleDiscord(jsonData, channelEvent) {
  const payload = { jsonData, channelEvent };

  const url = process.env.QRLS_BOT_URL || 'http://localhost:3210/discord-event';

  console.log('Relay: sending Discord event:', channelEvent);
  console.log('Relay: POST =>', url);

  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        // No X-API-Key header anymore
      },
      body: JSON.stringify(payload),
    });

    console.log('Relay: bot server response status:', res.status, res.statusText);

    if (!res.ok) {
      console.error(
        `Discord relay HTTP error: ${res.status} ${res.statusText}`
      );
    }
  } catch (err) {
    console.error('Failed to send Discord event to bot server:', err);
  }
}
