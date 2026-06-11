const crypto = require('crypto');
const https = require('https');

// 生产环境回调接口
const urlString = 'https://admin.comecomepay.com/api/v1/webhooks/3ds-callback';

// 生成 NotificationId
const nid = crypto.randomUUID ? crypto.randomUUID() : 'bio-test-' + Date.now();

// 获取时间戳
const now = Math.floor(Date.now() / 1000);
const exp = now + 585;

console.log(`NotificationId=${nid}  now=${now}`);

const payload = {
  "NotificationId": nid,
  "DelegateStatus": "Active",
  "Pubtoken": 609659162,
  "DelegateMethod": "push-confirmation",
  "FinancialInstitutionId": "9fb446af-e269-4488-8e89-09a85d09e567",
  "language": "en",
  "delegateScaId": "5d321cf4-8a3d-4855-9147-e2d7dcf504cc",
  "cardScheme": "visa",
  "CreatedMode": "PM",
  "Device": {
    "Channel": "BROWSER",
    "IP": "102.106.127.181",
    "Language": "en"
  },
  "MerchantInfo": {
    "ChallengePreference": "challenge-requested",
    "Country": "344",
    "Id": "134",
    "Name": "Flipkart",
    "RedirectAppUrl": null,
    "Url": "http://front-cow.biz"
  },
  "TransactionInfo": {
    "Amount": "0.01",
    "ChallengeExpiresAfter": 600,
    "ChallengeExpiry": exp,
    "ChallengeMethod": "delegate-sca-v1",
    "ChallengedAt": now,
    "Channel": "browser",
    "Currency": { "Code": "156", "Exponent": "2" },
    "Date": now,
    "DsTransactionId": "12daf9a5-a1c2-4df9-87c9-bc9988af2bb6",
    "Install": null,
    "ProtocolVersion": "2.2.0",
    "Recur": null,
    "Token": "9fc43923-5cb3-414e-9d1b-869142521184",
    "Type": "payment"
  },
  "status": 0
};

function sendCallback() {
  console.log('=== 发送到生产回调接口 ===');
  const startTime = Date.now();
  const payloadStr = JSON.stringify(payload);

  const options = {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(payloadStr)
    }
  };

  const req = https.request(urlString, options, (res) => {
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    res.on('end', () => {
      const duration = Date.now() - startTime;
      console.log(data); // 可能是 ok
      console.log(`[HTTP ${res.statusCode}  耗时 ${duration / 1000}s]`);
    });
  });

  req.on('error', (error) => {
    console.error('❌ Error sending callback:', error.message);
  });

  req.write(payloadStr);
  req.end();
}

sendCallback();
